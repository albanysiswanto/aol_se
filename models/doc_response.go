package models

// QUIZ
type QuizResponse struct {
	Message string `json:"message" example:"Quiz created successfully"`
	QuizID  string `json:"quiz_id" example:"12345"`
}

type QuizResponseInvalidInput struct {
	Error string `json:"error" example:"Invalid input"`
}

type QuizResponseUnauthorized struct {
	Error string `json:"error" example:"Unauthorized access"`
}

// QUIZ QUESTIONS
type QuestionResponseSuccess struct {
	Message string `json:"message" example:"Question added successfully"`
	QuizID  string `json:"quiz_id" example:"12345..."`
}

type QuestionResponseInvalidInput struct {
	Error string `json:"error" example:"Invalid input"`
}

type QuestionResponseUnauthorized struct {
	Error string `json:"error" example:"Unauthorized access"`
}
