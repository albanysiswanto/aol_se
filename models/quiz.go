package models

import "time"

type Quiz struct {
	ID          string `json:"id"`
	Title       string `json:"title"`
	Description string `json:"description"`
	CreatedAt   string `json:"created_at"`
	ParentName  string `json:"parent_name"`
	Reward      int    `json:"reward"`
	Timer       int    `json:"timer"`
}

type QuizQuestion struct {
	ID       string   `json:"id"`
	QuizID   string   `json:"quiz_id"`
	Question string   `json:"question"`
	Options  []string `json:"options"`
	Answer   string   `json:"answer"`
}

type QuizResult struct {
	ID        string    `json:"id" db:"id"`
	QuizID    string    `json:"quiz_id" db:"quiz_id"`
	ChildID   string    `json:"child_id" db:"child_id"`
	Score     int       `json:"score" db:"score"`
	CreatedAt time.Time `json:"created_at" db:"created_at"`
}
