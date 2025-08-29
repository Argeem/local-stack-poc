# Stage 1: Build the Go binary
# ใช้ Go image ที่มีเครื่องมือ build ครบ
FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY go.mod ./
COPY main.go ./

# Build Go binary โดยปิด CGO เพื่อให้เข้ากันได้กับ Alpine และทำให้ไฟล์เล็กลง
RUN CGO_ENABLED=0 GOOS=linux go build -o /main .

# Stage 2: Create the final, small image
# ใช้ Alpine image ซึ่งเป็น Linux ขนาดเล็กมาก
FROM alpine:latest
WORKDIR /root/

# คัดลอกเฉพาะ binary ที่ build เสร็จแล้วจาก stage 'builder'
COPY --from=builder /main .

# ตั้งค่า Environment Variable สำหรับเวอร์ชัน (สามารถ override ได้ตอนรัน)
ENV APP_VERSION="v1.0.0"

# บอก Docker ว่า Container จะ listen ที่ port 8080
EXPOSE 8080

# คำสั่งที่จะรันเมื่อ Container เริ่มทำงาน
CMD ["./main"]

# ใช้ multi-stage build เพื่อลดขนาดของ image และเพิ่มความปลอดภัย