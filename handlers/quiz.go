package handlers

import (
	"encoding/json"
	"fmt"
	"lapar_backend/config"
	"net/http"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"

	// "github.com/jackc/pgtype"

	"lapar_backend/models"
	"time"
)

type CreateQuizRequest struct {
	Title       string `json:"title" validate:"required"`
	Description string `json:"description"`
	Reward      int64  `json:"reward"`
	Timer       int64  `json:"timer"`
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
	parentID := c.Locals("userID")
	if parentID == nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"error": "Unauthorized access",
		})
	}

	var req CreateQuizRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid input",
		})
	}

	if req.Title == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Title is required",
		})
	}

	// Konversi menit ke detik
	rewardSeconds := req.Reward * 60
	timerSeconds := req.Timer * 60

	quizID := uuid.New()
	createdAt := time.Now()

	query := `
		INSERT INTO quiz (id, parent_id, title, description, reward, timer, created_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
	`
	_, err := config.DB.Exec(
		query,
		quizID,
		parentID,
		req.Title,
		req.Description,
		rewardSeconds,
		timerSeconds,
		createdAt,
	)
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

	// Query untuk mengambil data quiz
	rows, err := config.DB.Query(`
        SELECT q.id, q.title, q.description, q.created_at, p.full_name, q.reward, q.timer
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
		if err := rows.Scan(&quiz.ID, &quiz.Title, &quiz.Description, &quiz.CreatedAt, &quiz.ParentName, &quiz.Reward, &quiz.Timer); err != nil {
			continue
		}

		// Mengonversi detik ke menit
		quiz.Timer = quiz.Timer / 60

		quizzes = append(quizzes, quiz)
	}

	return c.JSON(quizzes)
}

// func GetQuizWithQuestions(c *fiber.Ctx) error {
// 	quizID := c.Params("id")

// 	// Ambil data quiz (timer, title, dll)
// 	var quiz models.Quiz
// 	err := config.DB.QueryRow(`
// 		SELECT id, title, description, timer
// 		FROM quiz
// 		WHERE id = $1
// 	`, quizID).Scan(&quiz.ID, &quiz.Title, &quiz.Description, &quiz.Timer)

// 	if err != nil {
// 		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
// 			"error": "Quiz not found",
// 		})
// 	}

// 	// Ambil data questions
// 	rows, err := config.DB.Query(`
// 		SELECT id, quiz_id, question, options, correct_answer
// 		FROM quiz_questions
// 		WHERE quiz_id = $1
// 	`, quizID)
// 	if err != nil {
// 		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
// 			"error": "Failed to fetch questions",
// 		})
// 	}
// 	defer rows.Close()

// 	var questions []models.QuizQuestion
// 	for rows.Next() {
// 		var q models.QuizQuestion
// 		var optionsJSON string

// 		err := rows.Scan(&q.ID, &q.QuizID, &q.Question, &optionsJSON, &q.Answer)
// 		if err != nil {
// 			continue
// 		}

// 		json.Unmarshal([]byte(optionsJSON), &q.Options)
// 		questions = append(questions, q)
// 	}

// 	return c.JSON(fiber.Map{
// 		"id":          quiz.ID,
// 		"title":       quiz.Title,
// 		"description": quiz.Description,
// 		"timer":       quiz.Timer,
// 		"questions":   questions,
// 	})
// }

func GetQuizWithQuestions(c *fiber.Ctx) error {
	quizID := c.Params("id")

	// Ambil data quiz (timer, title, dll)
	var quiz models.Quiz
	err := config.DB.QueryRow(`
		SELECT id, title, description, timer
		FROM quiz
		WHERE id = $1
	`, quizID).Scan(&quiz.ID, &quiz.Title, &quiz.Description, &quiz.Timer)

	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"error": "Quiz not found",
		})
	}

	// Ambil data questions
	rows, err := config.DB.Query(`
		SELECT id, quiz_id, question, options, correct_answer
		FROM quiz_questions
		WHERE quiz_id = $1
	`, quizID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to fetch questions",
		})
	}
	defer rows.Close()

	var questions []models.QuizQuestion
	for rows.Next() {
		var q models.QuizQuestion
		var optionsJSON string

		err := rows.Scan(&q.ID, &q.QuizID, &q.Question, &optionsJSON, &q.Answer)
		if err != nil {
			continue
		}

		// Pastikan optionsJSON bukan string kosong atau null
		if optionsJSON != "" {
			var options []string
			// Decode JSON options ke []string
			err := json.Unmarshal([]byte(optionsJSON), &options)
			if err == nil {
				// Assign ke q.Options setelah berhasil decode
				q.Options = options
			} else {
				// Tangani error jika JSON tidak bisa didecode
				continue
			}
		}

		questions = append(questions, q)
	}

	return c.JSON(fiber.Map{
		"id":          quiz.ID,
		"title":       quiz.Title,
		"description": quiz.Description,
		"timer":       quiz.Timer,
		"questions":   questions,
	})
}

// GET Question yang lama
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

func FetchQuizQuestionsWithAnswers(db *sqlx.DB, quizID string) ([]models.QuizQuestion, error) {
	rows, err := db.DB.Query(`
		SELECT id, quiz_id, question, options, correct_answer
		FROM quiz_questions
		WHERE quiz_id = $1
	`, quizID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var questions []models.QuizQuestion
	for rows.Next() {
		var q models.QuizQuestion
		var optionsJSON string

		err := rows.Scan(&q.ID, &q.QuizID, &q.Question, &optionsJSON, &q.Answer)
		if err != nil {
			continue
		}

		if optionsJSON != "" {
			var options []string
			if err := json.Unmarshal([]byte(optionsJSON), &options); err == nil {
				q.Options = options
			}
		}

		questions = append(questions, q)
	}

	return questions, nil
}

type SubmitQuizPayload struct {
	Answers map[string]int `json:"answers"`
}

func SubmitQuizResult(c *fiber.Ctx) error {
	quizID := c.Params("id")
	userID := c.Locals("userID").(string)
	var payload SubmitQuizPayload

	fmt.Println("Received payload:", payload)
	fmt.Println("Parsed answers:", payload.Answers)

	if err := c.BodyParser(&payload); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid request",
		})
	}

	questions, err := FetchQuizQuestionsWithAnswers(config.DB, quizID)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"error": "Gagal mengambil soal"})
	}

	correct := 0
	for _, q := range questions {
		selected, ok := payload.Answers[q.ID]
		if ok {
			if selected >= 0 && selected < len(q.Options) && q.Options[selected] == q.Answer {
				correct++
			}
		}
	}

	score := float64(correct) / float64(len(questions)) * 100

	_, err = config.DB.Exec(`
    INSERT INTO quiz_results (quiz_id, child_id, score, submitted_at)
    VALUES ($1, $2, $3, NOW())
  `, quizID, userID, score)

	if err != nil {
		fmt.Println("Error inserting quiz result:", err)
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to insert quiz result",
		})
	}

	var rewardQuiz int
	err = config.DB.QueryRow("SELECT reward FROM quiz WHERE id = $1", quizID).Scan(&rewardQuiz)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Gagal mengambil reward kuis",
		})
	}

	minutesReward := rewardQuiz
	_, err = config.DB.Exec(`
    INSERT INTO user_rewards (child_id, total_time, updated_at)
    VALUES ($1, $2, NOW())
    ON CONFLICT (child_id) DO UPDATE
    SET total_time = user_rewards.total_time + EXCLUDED.total_time,
        updated_at = EXCLUDED.updated_at
  `, userID, minutesReward)

	if err != nil {
		fmt.Println("Error updating rewards:", err)
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to update rewards",
		})
	}

	return c.JSON(fiber.Map{
		"message":        "Quiz result submitted",
		"score":          score,
		"reward_minutes": minutesReward,
	})
}
