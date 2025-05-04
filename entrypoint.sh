#!/bin/bash
set -e

PLUGIN_DIR="/data/plugins"
GEYSER_JAR="$PLUGIN_DIR/Geyser-Spigot.jar"
FLOODGATE_JAR="$PLUGIN_DIR/floodgate-spigot.jar"
GEYSER_URL="https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/spigot"
FLOODGATE_URL="https://download.geysermc.org/v2/projects/floodgate/versions/latest/builds/latest/downloads/spigot"
EULA_FILE="/data/eula.txt"
SERVER_PROPERTIES="/data/server.properties"

# สร้างโฟลเดอร์ plugins
mkdir -p "$PLUGIN_DIR"

# สร้าง eula.txt และเซ็ตค่า eula=true
if [ ! -f "$EULA_FILE" ]; then
    echo "eula=true" > "$EULA_FILE"
    echo "Created eula.txt with eula=true"
fi

# สร้างหรือแก้ไข server.properties เพื่อเปิดใช้งาน Keep Inventory
if [ ! -f "$SERVER_PROPERTIES" ]; then
    echo "Creating server.properties with keep inventory enabled..."
    echo "keep-inventory=true" > "$SERVER_PROPERTIES"
else
    echo "Updating server.properties to enable keep inventory..."
    if grep -q "keep-inventory=" "$SERVER_PROPERTIES"; then
        sed -i 's/keep-inventory=.*/keep-inventory=true/' "$SERVER_PROPERTIES"
    else
        echo "keep-inventory=true" >> "$SERVER_PROPERTIES"
    fi
fi

# ดาวน์โหลด GeyserMC และ Floodgate เวอร์ชันล่าสุดทุกครั้งที่ container เริ่มต้น
echo "Downloading GeyserMC..."
curl -fsSL "$GEYSER_URL" -o "$GEYSER_JAR"
echo "Downloading Floodgate..."
curl -fsSL "$FLOODGATE_URL" -o "$FLOODGATE_JAR"

# รัน Spigot server
exec java -jar -Xms${MEMORY:-2G} -Xmx${MEMORY:-2G} -XX:+UseG1GC /app/spigot.jar nogui 