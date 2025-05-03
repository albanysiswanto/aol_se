package routes

import (
	"lapar_backend/handlers"
	"lapar_backend/middleware"

	"github.com/gofiber/fiber/v2"
)

func SetupRoutes(app *fiber.App) {
	auth := app.Group("/auth")
	api := app.Group("/api", middleware.JWTMiddleware())

	auth.Post("/register", handlers.RegisterHandler)
	auth.Post("/login", handlers.LoginHandler)
	auth.Post("/register-child", handlers.RegisterChildHandler)

	api.Post("/invite", handlers.InviteChildHandler)
	api.Get("/parent/children", handlers.GetChildrenByParent)
	api.Get("/quiz/child", handlers.GetQuizzesByChildParent)
	api.Get("/quiz/:id/questions", handlers.GetQuestionsByQuizID)

	quizGroup := app.Group("/quiz", middleware.JWTMiddleware())
	quizGroup.Post("/create", handlers.CreateQuiz)
	quizGroup.Post("/add-question", handlers.AddQuestionToQuiz)
}
