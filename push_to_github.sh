#!/bin/bash
set -e
DIR="/storage/emulated/0/Documents/dooball_app"
cd "$DIR"

echo "=== เตรียม Push dooball_app ขึ้น GitHub ==="
if [ -z "$1" ]; then
    echo "วิธีใช้: ./push_to_github.sh <URL_ของ_GitHub_Repo>"
    echo "ตัวอย่าง: ./push_to_github.sh https://github.com/your-username/dooball_app.git"
    exit 1
fi

REPO_URL="$1"
git --git-dir=.git --work-tree=. remote remove origin 2>/dev/null || true
git --git-dir=.git --work-tree=. remote add origin "$REPO_URL"
git --git-dir=.git --work-tree=. branch -M main
echo "กำลัง Push ไปที่ $REPO_URL ..."
git --git-dir=.git --work-tree=. push -u origin main
echo "Push สำเร็จ! ไปที่แท็บ Actions บน GitHub เพื่อรอรับไฟล์ APK ได้เลย"
