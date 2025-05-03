package handlers

import (
	"encoding/json"
	"lapar_backend/config"
	"net/http"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"

	// "github.com/jackc/pgtype"

	"lapar_backend/models"
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

// CreateQuizHandler godoc
// @Summary Create a new quiz
// @Description This endpoint allows a logged-in parent to create a new quiz.
// @Tags Quizzes
// @Accept json
// @Produce json
// @Param body body CreateQuizRequest true "Menambahkan Kuis"
// @Success 201 {object} models.QuizResponse "Quiz created successfully"
// @Failure 400 {object} models.QuizResponseInvalidInput "Invalid input"
// @Failure 401 {object} models.QuizResponseUnauthorized "Unauthorized"
// @Security BearerAuth
// @Router /quiz/create [post]
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

// AddQuizQuestionHandler godoc
// @Summary Add a question to a quiz
// @Description This endpoint allows a logged-in parent to add a question to an existing quiz.
// @Tags Quiz Questions
// @Accept json
// @Produce json
// @Param body body AddQuestionRequest true "Menambahkan Pertanyaan berdasarkan Kuis ID"
// @Success 201 {object} models.QuestionResponseSuccess "Question added successfully"
// @Failure 400 {object} models.QuestionResponseInvalidInput "Invalid input"
// @Failure 401 {object} models.QuestionResponseUnauthorized "Unauthorized"
// @Security BearerAuth
// @Router /quiz/add-question [post]
func AddQuestionToQuiz(c *fiber.Ctx) error {
	var req AddQuestionRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid input",
		})
	}

	if req.QuizID == "" || req.Question == "" || len(req.Options) == 0 || req.CorrectAnswer == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "All fields are required",
		})
	}

	questionID := uuid.New()

	optionsJSON, err := json.Marshal(req.Options)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to process options",
		})
	}

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

func GetQuizzesByChildParent(c *fiber.Ctx) error {
	childID, ok := c.Locals("userID").(string)
	if !ok || childID == "" {
		return c.Status(http.StatusUnauthorized).JSON(fiber.Map{
			"error": "User ID tidak ditemukan di context",
		})
	}

	var parentID string
	err := config.DB.QueryRow(`
		SELECT parent_id FROM profile WHERE id = $1 AND role = 'Child'
	`, childID).Scan(&parentID)

	if err != nil || parentID == "" {
		return c.Status(http.StatusNotFound).JSON(fiber.Map{
			"error": "Child or parent not found",
		})
	}

	rows, err := config.DB.Query(`
		SELECT q.id, q.title, q.description, q.created_at, p.full_name
		FROM quiz q
		JOIN profile p ON q.parent_id = p.id
		WHERE q.parent_id = $1
	`, parentID)
	if err != nil {
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to fetch quizzes",
		})
	}
	defer rows.Close()

	var quizzes []models.Quiz
	for rows.Next() {
		var quiz models.Quiz
		if err := rows.Scan(&quiz.ID, &quiz.Title, &quiz.Description, &quiz.CreatedAt, &quiz.ParentName); err != nil {
			continue
		}
		quizzes = append(quizzes, quiz)
	}

	return c.JSON(quizzes)
}

func GetQuestionsByQuizID(c *fiber.Ctx) error {
	quizID := c.Params("id")

	rows, err := config.DB.Query(
		`SELECT id, question, options, correct_answer FROM quiz_questions WHERE quiz_id = $1`, quizID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to fetch questions",
		})
	}
	defer rows.Close()

	var questions []map[string]interface{}
	for rows.Next() {
		var id, question, correctAnswer string
		var optionsRaw []byte

		err := rows.Scan(&id, &question, &optionsRaw, &correctAnswer)
		if err != nil {
			return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"error": "Failed to scan question data",
			})
		}

		var options []string
		err = json.Unmarshal(optionsRaw, &options)
		if err != nil {
			return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"error": "Failed to parse options JSON",
			})
		}

		questions = append(questions, fiber.Map{
			"id":             id,
			"question":       question,
			"options":        options,
			"correct_answer": correctAnswer,
		})
	}

	return c.JSON(questions)
}
