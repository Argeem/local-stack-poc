# แผนการ Deploy Go Application ไปยัง ECS บน LocalStack ด้วย Terraform และ CI/CD

นี่คือแผนการทั้งหมด 5 เฟส สำหรับการสร้าง CI/CD Pipeline เพื่อ deploy แอปพลิเคชันที่เขียนด้วยภาษา Go ไปยัง Amazon ECS ที่จำลองการทำงานบน LocalStack โดยใช้ Terraform ในการจัดการ Infrastructure

---

## ⚙️ **Phase 1: การตั้งค่าโปรเจกต์และ Environment (Project & Local Environment Setup)**

เฟสนี้คือการเตรียมทุกอย่างบนเครื่องของคุณให้พร้อมสำหรับ CI/CD

1.  **สร้าง Application จำลอง:** เขียนเว็บแอปพลิเคชันง่ายๆ ด้วย Go ที่มี Endpoint เดียวที่คืนค่าข้อความเช่น `{"message": "Hello from ECS", "version": "v1.0"}`
2.  **สร้าง Dockerfile:** เขียน `Dockerfile` เพื่อบรรจุ (Containerize) แอปพลิเคชันในข้อ 1 ให้เป็น Docker image ที่สามารถรันได้
3.  **สร้างไฟล์ docker-compose.yml:** สร้างไฟล์นี้เพื่อกำหนดค่าและสั่งรัน **LocalStack**
4.  **ติดตั้งเครื่องมือที่จำเป็น:**
    - Docker และ Docker Compose
    - AWS CLI (และตั้งค่าให้ชี้ไปที่ LocalStack)
    - `act` (ถ้าจะใช้ GitHub Actions เพื่อทดสอบ Pipeline ในเครื่อง)
    - Git สำหรับ Version Control

---

## 🏗️ **Phase 2: การสร้าง Infrastructure ด้วย Terraform (Infrastructure Bootstrap)**

เฟสนี้เราจะใช้ Terraform เพื่อสร้างทรัพยากรที่จำเป็นบน LocalStack

5.  **สร้างไฟล์ Configuration ของ Terraform (`providers.tf`):** สร้างไฟล์เพื่อกำหนดค่าให้ Terraform เชื่อมต่อไปยัง Endpoint ของ LocalStack แทน AWS จริง
6.  **สร้างไฟล์นิยาม Resource (`ecs.tf`, `task-definition.tf`):** สร้างไฟล์ `.tf` เพื่อนิยามทรัพยากรทั้งหมดด้วยโค้ด ซึ่งจะรวมถึง:
    - ECR Repository
    - ECS Cluster
    - Security Group และ Rules ที่จำเป็น
    - IAM Role สำหรับ ECS Task Execution
    - ECS Task Definition (เวอร์ชันแรก โดยใช้ Image ชั่วคราวไปก่อน)
    - ECS Service ที่เชื่อมโยงทุกอย่างเข้าด้วยกัน
7.  **สั่ง Apply Infrastructure (`terraform apply`):** รันคำสั่ง `terraform init` และ `terraform apply` เพื่อสร้างทรัพยากรทั้งหมดบน LocalStack ตามที่นิยามไว้ในโค้ด

---

## 🚀 **Phase 3: การตั้งค่า Pipeline (CI/CD Pipeline Configuration)**

ขั้นตอนนี้คือการกำหนด "พิมพ์เขียว" ของกระบวนการ Automate ทั้งหมด

8.  **สร้าง Git Repository:** นำโค้ดแอป, Dockerfile, และ **โฟลเดอร์ Terraform** จากเฟสก่อนหน้าทั้งหมดใส่เข้าไปใน Git Repo
9.  **สร้างไฟล์ Workflow ของ Pipeline:** สร้างไฟล์ YAML สำหรับ CI/CD (เช่น `.github/workflows/deploy.yml`) เพื่อกำหนดขั้นตอนการทำงานทั้งหมด

---

## 💨 **Phase 4: รายละเอียดขั้นตอนใน Pipeline (Pipeline Execution Steps)**

นี่คือสิ่งที่ Pipeline จะทำโดยอัตโนมัติทุกครั้งที่เรา Push Code ใหม่

10. **ขั้นตอนที่ 1 - Build:** Pipeline จะ `docker build` Image จาก `Dockerfile`
11. **ขั้นตอนที่ 2 - Push:** Pipeline จะ Tag image ที่ build เสร็จแล้ว และ `docker push` ไปยัง ECR บน LocalStack
12. **ขั้นตอนที่ 3 - Deploy:**
    - Pipeline จะดึง Task Definition ตัวล่าสุดลงมา
    - สร้าง Task Definition Revision ใหม่ โดย **เปลี่ยนแค่ Image URI** ให้เป็นตัวที่เพิ่ง Push ไป
    - สั่ง **Update ECS Service** ให้ใช้ Task Definition Revision ใหม่ล่าสุดนี้

---

## ✅ **Phase 5: การตรวจสอบและทดสอบ (Verification & Testing)**

ขั้นตอนสุดท้ายหลังจาก Pipeline ทำงานเสร็จ คือการยืนยันว่าการ Deploy สำเร็จจริง

13. **ตรวจสอบสถานะ ECS Service:** ใช้ AWS CLI (`awslocal`) เพื่อตรวจสอบว่า Service ได้อัปเดต Task เป็นเวอร์ชันใหม่เรียบร้อยแล้ว
14. **ทดสอบ Endpoint ของแอปพลิเคชัน:** ใช้คำสั่ง `curl` ยิง Request ไปยังแอปพลิเคชันเพื่อตรวจสอบว่า Response ที่ได้กลับมาเป็นของเวอร์ชันใหม่จริง
