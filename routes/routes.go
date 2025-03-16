package routes

import (
	"github.com/gofiber/fiber/v2"
	"lapar_backend/handlers"
	"lapar_backend/middleware"
)

func SetupRoutes(app *fiber.App) {
	auth := app.Group("/auth")
	api := app.Group("/api", middleware.JWTMiddleware())

	auth.Post("/register", handlers.RegisterHandler)
	auth.Post("/login", handlers.LoginHandler)
	auth.Post("/register-child", handlers.RegisterChildHandler)

	api.Post("/invite", handlers.InviteChildHandler)
}
