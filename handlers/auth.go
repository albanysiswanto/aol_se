package handlers

import (
	"database/sql"
	"errors"
	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
	"log"
	"net/http"
	"net/mail"
	"strings"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"lapar_backend/config"
)

func calculateAge(birthDateStr string) (int, error) {
	birthDate, err := time.Parse("2006-01-02", birthDateStr)
	if err != nil {
		return 0, err
	}

	today := time.Now()
	age := today.Year() - birthDate.Year()

	if today.Month() < birthDate.Month() || (today.Month() == birthDate.Month() && today.Day() < birthDate.Day()) {
		age--
	}

	return age, nil
}

func HashPassword(password string) (string, error) {
	bytes, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	return string(bytes), err
}

func GenerateJWT(userID, role string) (string, error) {
	claims := jwt.MapClaims{
		"user_id": userID,
		"role":    role,
		"exp":     time.Now().Add(time.Hour * 24).Unix(), // Token berlaku 24 jam
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(config.JWTSecret))
}

type LoginRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

// LoginHandler mengautentikasi pengguna.
//
// @Summary Login
// @Description Autentikasi pengguna dengan email dan password
// @Tags Auth
// @Accept json
// @Produce json
// @Param body body LoginRequest true "Data login pengguna"
// @Success 200 {object} map[string]interface{} "Login berhasil, mengembalikan token"
// @Failure 400 {object} map[string]string "Permintaan tidak valid"
// @Failure 401 {object} map[string]string "Email atau password salah"
// @Failure 500 {object} map[string]string "Kesalahan server"
// @Router /auth/login [post]
func LoginHandler(c *fiber.Ctx) error {
	//type LoginRequest struct {
	//	Email    string `json:"email"`
	//	Password string `json:"password"`
	//}

	var req LoginRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid request"})
	}

	var user struct {
		ID       string
		Password string
		Role     string
	}

	err := config.DB.QueryRow(
		"SELECT id, password, role FROM profile WHERE email = $1", req.Email).
		Scan(&user.ID, &user.Password, &user.Role)

	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "Invalid email or password"})
		}
		log.Println("Database error:", err)
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Database error"})
	}

	err = bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.Password))
	if err != nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "Invalid email or password"})
	}

	token, err := GenerateJWT(user.ID, user.Role)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Could not generate token"})
	}

	return c.JSON(fiber.Map{"token": token})
}

type RegisterRequest struct {
	FullName    string `json:"full_name"`
	Email       string `json:"email"`
	Password    string `json:"password"`
	BirthDate   string `json:"birth_date"`
	InviteToken string `json:"invite_token,omitempty"`
}

// RegisterHandler mendaftarkan akun orang tua.
//
// @Summary Register Parent
// @Description Mendaftarkan akun orang tua baru
// @Tags Auth
// @Accept json
// @Produce json
// @Param body body RegisterRequest true "Data pendaftaran orang tua"
// @Success 201 {object} map[string]string "Berhasil mendaftar"
// @Failure 400 {object} map[string]string "Permintaan tidak valid"
// @Failure 500 {object} map[string]string "Kesalahan server"
// @Router /auth/register [post]
func RegisterHandler(c *fiber.Ctx) error {
	var req RegisterRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid request"})
	}

	if _, err := mail.ParseAddress(req.Email); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid email address"})
	}

	hashedPassword, err := HashPassword(req.Password)
	if err != nil {
		log.Println("Error hashing password:", err)
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Could not hash password"})
	}

	role := "Parent"
	var parentID *string = nil

	age, err := calculateAge(req.BirthDate)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid birth date format. Use YYYY-MM-DD"})
	}

	if age < 18 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Parent must be at least 18 years old"})
	}

	if req.InviteToken != "" {
		role = "Child"
		parentID = &req.InviteToken
	}

	_, err = config.DB.Exec(`
		INSERT INTO profile (id, full_name, email, password, birth_date, role, parent_id) 
		VALUES ($1, $2, $3, $4, $5, $6, $7)`,
		uuid.New().String(), req.FullName, strings.ToLower(req.Email), hashedPassword, req.BirthDate, role, parentID,
	)

	if err != nil {
		log.Println("Error inserting user:", err)
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Could not create user"})
	}

	return c.Status(fiber.StatusCreated).JSON(fiber.Map{
		"message": "User registered successfully",
	})
}

//type RegisterRequest struct {
//	FullName  string `json:"full_name"`
//	Email     string `json:"email"`
//	Password  string `json:"password"`
//	BirthDate string `json:"birth_date"`
//}

// RegisterChildHandler mendaftarkan akun anak menggunakan token undangan.
//
// @Summary Register Child
// @Description Mendaftarkan anak berdasarkan undangan dari orang tua
// @Tags Auth
// @Accept json
// @Produce json
// @Param invite query string true "Token undangan"
// @Param body body RegisterRequest true "Data anak yang akan didaftarkan"
// @Success 201 {object} map[string]string
// @Failure 400 {object} map[string]string
// @Failure 500 {object} map[string]string
// @Router /auth/register-child [post]
func RegisterChildHandler(c *fiber.Ctx) error {
	// Ambil invite_token dari URL
	inviteToken := c.Query("invite")
	if inviteToken == "" {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": "Invite token is required"})
	}

	var req RegisterRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": "Invalid request"})
	}

	var parentID string
	err := config.DB.QueryRow(
		"SELECT parent_id FROM invitations WHERE invite_token = $1", inviteToken).
		Scan(&parentID)

	if err != nil {
		log.Println("Invalid invitation token:", err)
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": "Invalid invitation token"})
	}

	age, err := calculateAge(req.BirthDate)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid birth date format. Use YYYY-MM-DD"})
	}
	if age < 5 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Child must be at least 5 years old"})
	}

	hashedPassword, err := HashPassword(req.Password)
	if err != nil {
		log.Println("Error hashing password:", err)
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Could not hash password"})
	}

	_, err = config.DB.Exec(`
		INSERT INTO profile (id, full_name, email, password, birth_date, role, parent_id) 
		VALUES ($1, $2, $3, $4, $5, $6, $7)`,
		uuid.New().String(), req.FullName, strings.ToLower(req.Email), hashedPassword, req.BirthDate, "Child", parentID,
	)

	if err != nil {
		log.Println("Error inserting child user:", err)
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Could not register child"})
	}

	// Hapus token dari tabel invitations (Opsional)
	_, _ = config.DB.Exec("DELETE FROM invitations WHERE invite_token = $1", inviteToken)

	return c.Status(http.StatusCreated).JSON(fiber.Map{
		"message": "Child registered successfully",
	})
}
