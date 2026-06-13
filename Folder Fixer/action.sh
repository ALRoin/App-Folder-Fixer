#!/system/bin/sh

echo "======================================"
echo "     App Folder Fixer     "
echo "======================================"

STORAGE_BASE="/data/media/0/Android"
MOD_DIR="/data/adb/modules/folder-fixer"
CONFIG_FILE="$MOD_DIR/folder_fixer.txt"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "[*] Configuration registry missing. Instantiating: $CONFIG_FILE"
    echo "# App Folder Fixer User Configuration" > "$CONFIG_FILE"
    echo "# Add package names below (one per line) that need folder fixes." >> "$CONFIG_FILE"
    echo "# Example:" >> "$CONFIG_FILE"
    echo "# com.epicgames.portal" >> "$CONFIG_FILE"
    echo "# com.activision.callofduty.shooter" >> "$CONFIG_FILE"
    echo "# Remove '#' to enable an entry. Lines starting with '#' are treated as comments." >> "$CONFIG_FILE"
    chmod 666 "$CONFIG_FILE"
fi

PACKAGES=$(grep -v "^#" "$CONFIG_FILE" | tr -d '\r')
CREATED_COUNT=0

if [ -z "$PACKAGES" ]; then
    echo "[-] No app is selected. Please choose an app in the WebUI and save the configuration."
    exit 0
fi

for PKG in $PACKAGES; do
    if pm list packages | grep -q "package:$PKG$"; then
        echo "--------------------------------------"
        echo "[*] FULL DIAGNOSIS: $PKG"
        
        
        APP_UID=$(pm list packages -U | grep "package:$PKG " | awk '{print $2}' | cut -d: -f2)
        if [ -z "$APP_UID" ]; then
            APP_UID=$(stat -c "%u" "/data/data/$PKG" 2>/dev/null)
        fi
        
        if [ -z "$APP_UID" ]; then
            echo "[-] Critical: Failed to extract UID map layout for $PKG. Skipping app..."
            continue
        fi
        
        echo "[+] App UID Resolved: $APP_UID"

        for FOLDER in data obb media; do
            TARGET_DIR="$STORAGE_BASE/$FOLDER/$PKG"
            
            if [ "$FOLDER" = "obb" ]; then
                PERM=777
            else
                PERM=2777
            fi

            if [ ! -d "$TARGET_DIR" ]; then
                mkdir -p "$TARGET_DIR"
                echo "[+] Created Missing Structure: Android/$FOLDER/$PKG"
                CREATED_COUNT=$((CREATED_COUNT + 1))
            fi
            
            
            chown -R $APP_UID:$APP_UID "$TARGET_DIR" 2>/dev/null
            chmod $PERM "$TARGET_DIR" 2>/dev/null
            chcon -R u:object_r:media_rw_data_file:s0 "$TARGET_DIR" 2>/dev/null
        done
        

        am force-stop $PKG
        echo "[+] State synchronized and force-stopped: $PKG"
    else
        echo "[-] Skipped: $PKG (Not actively installed)"
    fi
done

echo "--------------------------------------"
if [ "$CREATED_COUNT" -eq 0 ]; then
    echo "Status: No issues found. Your app folder already exists."
else
    echo "Status: Successfully generated and fixed $CREATED_COUNT directories."
fi