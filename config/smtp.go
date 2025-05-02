package config

import (
	"log"
	"os"
	"strconv"
)

var (
	SMTPHost     string
	SMTPPort     int
	SMTPUser     string
	SMTPPassword string
)

func LoadSMTPConfig() {
	host := os.Getenv("SMTP_HOST")
	portStr := os.Getenv("SMTP_PORT")
	user := os.Getenv("SMTP_USER")
	pass := os.Getenv("SMTP_PASSWORD")

	if host == "" || portStr == "" || user == "" || pass == "" {
		log.Fatal("SMTP configuration is missing in .env")
	}

	port, err := strconv.Atoi(portStr)
	if err != nil {
		log.Fatalf("Invalid SMTP_PORT: %v", err)
	}

	SMTPHost = host
	SMTPPort = port
	SMTPUser = user
	SMTPPassword = pass
}
