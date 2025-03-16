package main

import (
	"log"
	"os"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/swagger"
	"github.com/joho/godotenv"
	"lapar_backend/config"
	_ "lapar_backend/docs" // Import docs yang akan dibuat nanti
	"lapar_backend/routes"
)

// @title Lapar Backend API
// @version 1.0
// @description Dokumentasi API untuk aplikasi parenting Lapar.
// @host localhost:2020
// @BasePath /

func main() {
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, using Railway environment variables")
	}

	config.LoadConfig()
	config.ConnectDatabase()

	app := fiber.New()

	// Swagger Docs
	app.Get("/swagger/*", swagger.HandlerDefault)

	// Setup Routes
	routes.SetupRoutes(app)

	// Baca port dari environment variable
	port := os.Getenv("PORT")
	if port == "" {
		port = "2020"
	}
	log.Println("Server running on port:", port)
	log.Fatal(app.Listen(":" + port))
}
