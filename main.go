package main

import (
	"github.com/gofiber/swagger"
	"log"
	"os"

	"github.com/gofiber/fiber/v2"
	//"github.com/gofiber/swagger" // Fiber Swagger middleware
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
	// Load environment variables
	config.LoadConfig()
	err := godotenv.Load()
	if err != nil {
		log.Fatal("Error loading .env file")
	}

	config.ConnectDatabase()

	app := fiber.New()

	app.Get("/swagger/*", swagger.HandlerDefault)

	routes.SetupRoutes(app)

	port := os.Getenv("PORT")
	if port == "" {
		port = "2020"
	}
	log.Fatal(app.Listen(":" + port))
}
