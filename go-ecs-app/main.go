package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
)

// Struct สำหรับข้อมูลที่จะตอบกลับเป็น JSON
type ResponseData struct {
	Message string `json:"message"`
	Version string `json:"version"`
}

func main() {
	// ดึงค่าเวอร์ชันจาก Environment Variable ถ้าไม่มีให้ใช้ "v1.0.0"
	appVersion := os.Getenv("APP_VERSION")
	if appVersion == "" {
		appVersion = "v1.0.0" // เวอร์ชันตั้งต้น
	}

	// สร้าง Handler สำหรับ endpoint "/"
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		log.Println("Received request on /")

		data := ResponseData{
			Message: "Hello from Amazon ECS!",
			Version: appVersion,
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(data)
	})

	log.Println("Starting server on port 8080...")
	// เริ่มรันเซิร์ฟเวอร์ที่ port 8080
	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatalf("could not start server: %s\n", err)
	}
}