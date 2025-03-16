package models

type User struct {
	ID        string  `json:"id" db:"id"`
	FullName  string  `json:"full_name" db:"full_name"`
	Email     string  `json:"email" db:"email"`
	Password  string  `json:"password" db:"password"`
	BirthDate string  `json:"birth_date" db:"birth_date"`
	Role      string  `json:"role" db:"role"`
	ParentID  *string `json:"parent_id" db:"parent_id"` // NULL jika user adalah Parent
}

type RegisterRequest struct {
	FullName    string `json:"full_name"`
	Email       string `json:"email"`
	Password    string `json:"password"`
	BirthDate   string `json:"birth_date"`
	InviteToken string `json:"invite_token,omitempty"`
}

type LoginRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}
