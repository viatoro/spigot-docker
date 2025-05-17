#!/bin/bash

# กำหนดโฟลเดอร์ต้นทางและปลายทาง
SOURCE_DIR="world"
DEST_DIR="worlds"

# สร้างโฟลเดอร์ปลายทางถ้ายังไม่มี
mkdir -p "$DEST_DIR"

# หาโฟลเดอร์ที่มีอยู่แล้วและเก็บหมายเลขสูงสุด
max_num=0
for dir in "$DEST_DIR"/w*; do
    if [ -d "$dir" ]; then
        num=$(basename "$dir" | sed 's/w//')
        if [ "$num" -gt "$max_num" ]; then
            max_num=$num
        fi
    fi
done

# สร้างหมายเลขโฟลเดอร์ใหม่
new_num=$((max_num + 1))
new_dir="$DEST_DIR/w$(printf "%05d" $new_num)"

# คัดลอกโฟลเดอร์
echo "กำลังคัดลอก $SOURCE_DIR ไปยัง $new_dir"
mkdir -p "$new_dir"
cp Dockerfile "$new_dir"
cp entrypoint.sh "$new_dir"
cp docker-compose.yml "$new_dir"

if [ $? -eq 0 ]; then
    echo "คัดลอกเสร็จสิ้น: $new_dir"
    
    # เริ่มต้น Docker Compose
    echo "กำลังเริ่มต้น Docker Compose..."
    cd "$new_dir" && docker-compose up -d
    
    if [ $? -eq 0 ]; then
        echo "Docker Compose เริ่มต้นสำเร็จ"
    else
        echo "เกิดข้อผิดพลาดในการเริ่มต้น Docker Compose"
        # docker restart "w$(printf "%05d" $new_num)-spigot-1"
        exit 1
    fi
else
    echo "เกิดข้อผิดพลาดในการคัดลอก"
    exit 1
fi 