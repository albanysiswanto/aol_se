package main

import (
	"log"
	"os"

	"github.com/gofiber/swagger"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"

	//"github.com/gofiber/swagger" // Fiber Swagger middleware
	"lapar_backend/config"
	_ "lapar_backend/docs" // Import docs yang akan dibuat nanti
	"lapar_backend/routes"

	"github.com/joho/godotenv"
)

// @title Lapar Backend API
// @version 1.1
// @description Dokumentasi API untuk aplikasi parenting Lapar.
// @host localhost:2020
// @BasePath /

func main() {
	// Load environment variables
	config.LoadConfig()
	config.LoadSMTPConfig()
	err := godotenv.Load()
	if err != nil {
		log.Fatal("Error loading .env file")
	}

	config.ConnectDatabase()

	app := fiber.New()

	app.Get("/swagger/*", swagger.HandlerDefault)

	app.Use(cors.New(cors.Config{
		AllowOrigins: "*",                   // Izinkan semua asal
		AllowMethods: "GET,POST,PUT,DELETE", // Metode yang diizinkan
		AllowHeaders: "*",                   // Izinkan semua header
	}))

	routes.SetupRoutes(app)

	port := os.Getenv("PORT")
	if port == "" {
		port = "2020"
	}
	log.Fatal(app.Listen(":" + port))
}
