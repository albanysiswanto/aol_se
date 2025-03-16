package config

import (
	"fmt"
	"log"
	"os"

	"github.com/jmoiron/sqlx"
	"github.com/joho/godotenv"
	_ "github.com/lib/pq"
)

var AppURL = os.Getenv("APP_URL")

var DB *sqlx.DB

var JWTSecret string

func LoadConfig() {
	// Load .env file (jika ada)
	err := godotenv.Load()
	if err != nil {
		log.Println("No .env file found, using default values")
	}

	// Ambil JWT_SECRET dari environment
	JWTSecret = os.Getenv("JWT_SECRET")
	if JWTSecret == "" {
		log.Println("JWT_SECRET is not set! Using default value (NOT SECURE)")
		JWTSecret = "QCkQy4sOjvlyURniSFrJSGkHM5zEBuS6"
	}
}

func ConnectDatabase() {
	err := godotenv.Load()
	if err != nil {
		log.Fatal("Error loading .env file")
	}

	dsn := os.Getenv("DB_URL")
	db, err := sqlx.Connect("postgres", dsn)
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}

	DB = db
	fmt.Println("Database connected successfully!")
}
