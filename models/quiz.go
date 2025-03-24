package models

import "time"

type Quiz struct {
	ID        string    `json:"id" db:"id"`
	ParentID  string    `json:"parent_id" db:"parent_id"`
	Title     string    `json:"title" db:"title"`
	CreatedAt time.Time `json:"created_at" db:"created_at"`
	UpdatedAt time.Time `json:"updated_at" db:"updated_at"`
}

type QuizQuestion struct {
	ID       string `json:"id" db:"id"`
	QuizID   string `json:"quiz_id" db:"quiz_id"`
	Question string `json:"question" db:"question"`
	Options  string `json:"options" db:"options"`
	Answer   string `json:"answer" db:"answer"`
}

type QuizResult struct {
	ID        string    `json:"id" db:"id"`
	QuizID    string    `json:"quiz_id" db:"quiz_id"`
	ChildID   string    `json:"child_id" db:"child_id"`
	Score     int       `json:"score" db:"score"`
	CreatedAt time.Time `json:"created_at" db:"created_at"`
}
