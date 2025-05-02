package handlers

import (
	"log"
	"net/http"
	"time"

	"lapar_backend/config"
	"lapar_backend/utils"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
)

// InviteChildHandler godoc
// @Summary Invite a child
// @Description Send an invitation link to a child via email
// @Tags Invitations
// @Accept json
// @Produce json
// @Param request body map[string]string true "Child Email Request"
// @Success 200 {object} map[string]string "Invitation sent successfully"
// @Failure 400 {object} map[string]string "Invalid request"
// @Failure 401 {object} map[string]string "Unauthorized"
// @Failure 409 {object} map[string]string "Email already registered"
// @Failure 500 {object} map[string]string "Internal server error"
// @Router /api/invite [post]
func InviteChildHandler(c *fiber.Ctx) error {
	parentID, ok := c.Locals("userID").(string)
	if !ok || parentID == "" {
		return c.Status(http.StatusUnauthorized).JSON(fiber.Map{"error": "Unauthorized"})
	}

	type InviteRequest struct {
		ChildEmail string `json:"child_email"`
	}
	req := new(InviteRequest)
	if err := c.BodyParser(req); err != nil {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": "Invalid request"})
	}

	var existingEmail string
	err := config.DB.QueryRowx("SELECT email FROM profile WHERE email = $1", req.ChildEmail).Scan(&existingEmail)

	if err == nil {
		return c.Status(http.StatusConflict).JSON(fiber.Map{"error": "Email already registered"})
	} else if err.Error() != "sql: no rows in result set" {
		log.Println("Database error:", err)
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": "Database error"})
	}

	inviteToken := uuid.New().String()

	_, err = config.DB.NamedExec(`
		INSERT INTO invitations (parent_id, child_email, invite_token, created_at)
		VALUES (:parent_id, :child_email, :invite_token, :created_at)`,
		map[string]interface{}{
			"parent_id":    parentID,
			"child_email":  req.ChildEmail,
			"invite_token": inviteToken,
			"created_at":   time.Now(),
		})

	if err != nil {
		log.Println("Error inserting invitation:", err)
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to create invitation"})
	}

	if req.ChildEmail == "" {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{"error": "Email is required"})
	}

	// inviteLink := fmt.Sprintf("%s/auth/register-child?invite=%s", config.AppURL, inviteToken)

	// (TODO: Kirim email ke anak dengan inviteLink)
	if err := utils.SendInvitationEmail(req.ChildEmail, inviteToken); err != nil {
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to send email"})
	}

	log.Printf("Generated invite token for %s: %s", req.ChildEmail, inviteToken)
	return c.JSON(fiber.Map{"invite_token": inviteToken})
}
