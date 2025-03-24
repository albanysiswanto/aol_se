package handlers

import (
	"encoding/json"
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"lapar_backend/config"
	"time"
)

type CreateQuizRequest struct {
	Title       string `json:"title" validate:"required"`
	Description string `json:"description"`
}

type AddQuestionRequest struct {
	QuizID        string   `json:"quiz_id" validate:"required"`
	Question      string   `json:"question" validate:"required"`
	Options       []string `json:"options" validate:"required"`
	CorrectAnswer string   `json:"correct_answer" validate:"required"`
}

func CreateQuiz(c *fiber.Ctx) error {
	// Ambil user_id dari token (disimpan di context ketika login berhasil)
	parentID := c.Locals("userID")
	if parentID == nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"error": "Unauthorized access",
		})
	}

	// Parse input dari client
	var req CreateQuizRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid input",
		})
	}

	// Validasi input
	if req.Title == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Title is required",
		})
	}

	// Generate UUID untuk quiz_id
	quizID := uuid.New()

	// Simpan ke database
	query := `
		INSERT INTO quiz (id, parent_id, title, description, created_at)
		VALUES ($1, $2, $3, $4, $5)
	`
	_, err := config.DB.Exec(query, quizID, parentID, req.Title, req.Description, time.Now())
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to create quiz",
		})
	}

	return c.Status(fiber.StatusCreated).JSON(fiber.Map{
		"message": "Quiz created successfully",
		"quiz_id": quizID,
	})
}

func AddQuestionToQuiz(c *fiber.Ctx) error {
	// Parse input dari client
	var req AddQuestionRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid input",
		})
	}

	// Validasi input
	if req.QuizID == "" || req.Question == "" || len(req.Options) == 0 || req.CorrectAnswer == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "All fields are required",
		})
	}

	// Generate UUID untuk question_id
	questionID := uuid.New()

	// Konversi options menjadi JSON
	optionsJSON, err := json.Marshal(req.Options)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to process options",
		})
	}

	// Simpan ke database
	query := `
    INSERT INTO quiz_questions (id, quiz_id, question, options, correct_answer, created_at)
    VALUES ($1, $2, $3, $4, $5, $6)
`
	_, err = config.DB.Exec(query, questionID, req.QuizID, req.Question, optionsJSON, req.CorrectAnswer, time.Now())
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to add question",
		})
	}

	return c.Status(fiber.StatusCreated).JSON(fiber.Map{
		"message":     "Question added successfully",
		"question_id": questionID,
	})
}
