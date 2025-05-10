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
	api.Get("/quiz/:id/questions", handlers.GetQuizWithQuestions)
	api.Post("/quiz/:id/submit", handlers.SubmitQuizResult)
	api.Get("/profile/child", handlers.GetChildProfile)
	api.Get("/profile/parent", handlers.GetParentProfile)
	api.Get("/progress", handlers.GetChildProgress)
	api.Get("/screen-time", handlers.GetScreenTime)

	quizGroup := app.Group("/quiz", middleware.JWTMiddleware())
	quizGroup.Post("/create", handlers.CreateQuiz)
	quizGroup.Post("/add-question", handlers.AddQuestionToQuiz)
}
