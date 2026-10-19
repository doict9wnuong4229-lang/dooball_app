# Dooball App ⚽

แอพพลิเคชันดูบอลสด ถ่ายทอดสดฟุตบอล เชื่อมต่อเว็บไซต์ Dooball แบบ Fullscreen รองรับแนวนอน และมีระบบป้องกันหน้าจอดับ (Keep Screen On)

## คุณสมบัติเด่น
- 📺 **WebView เต็มหน้าจอ**: ตัดแถบรกตา ให้พื้นที่รับชมเต็มจอ
- 🔄 **สลับแนวนอน/แนวตั้ง (Landscape Mode)**: กดปุ่มเดียวเพื่อรับชมแบบเต็มจอแนวนอน Immersive Sticky
- 💡 **Wakelock (ไม่พักหน้าจอ)**: หน้าจอไม่ดับระหว่างรับชมการแข่งขัน
- ⚽ **เมนูช่องด่วน (Drawer Navigation)**:
  - Dooball TV (ดูบอลสด)
  - หน้าหลัก Dooball
  - ตารางแข่งขันวันนี้
  - ผลบอลสด LiveScore
  - ใส่ลิงก์เว็บเอง (Custom URL)
- 🚀 **GitHub Actions Automated APK Build**: สร้าง APK อัตโนมัติเมื่อ Push ขึ้น GitHub

## วิธีบิลด์ APK ผ่าน GitHub
1. สร้าง New Repository บน GitHub (เช่น `dooball_app`)
2. รันคำสั่งใน Termux:
   ```bash
   cd /storage/emulated/0/Documents/dooball_app
   ./push_to_github.sh https://github.com/<YOUR_USER>/dooball_app.git
   ```
3. เปิดไปที่แท็บ **Actions** บน GitHub รอประมาณ 2-3 นาที แล้วดาวน์โหลดไฟล์ APK ในหมวด **Artifacts**
