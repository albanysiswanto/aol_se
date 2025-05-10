package handlers

import (
	"database/sql"
	"lapar_backend/config"
	"lapar_backend/models"
	"log"

	"github.com/gofiber/fiber/v2"
)

func GetChildProfile(c *fiber.Ctx) error {
	userID := c.Locals("userID").(string)

	var profile models.Profile
	err := config.DB.QueryRow(
		"SELECT id, full_name, email, role, parent_id FROM profile WHERE id = $1", userID).Scan(&profile.ID, &profile.FullName, &profile.Email, &profile.Role, &profile.ParentID)

	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to retrieve profile",
		})
	}

	if profile.Role != "Child" {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"error": "Not authorized to view child profile",
		})
	}

	var parentName string
	if profile.ParentID != "" {
		err = config.DB.QueryRow(
			"SELECT full_name FROM profile WHERE id = $1", profile.ParentID).Scan(&parentName)
		if err != nil {
			return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"error": "Failed to retrieve parent information",
			})
		}
	}

	return c.JSON(fiber.Map{
		"full_name": profile.FullName,
		"email":     profile.Email,
		"role":      profile.Role,
		"parent":    parentName,
	})
}
func GetParentProfile(c *fiber.Ctx) error {
	userID := c.Locals("userID").(string)

	var profile models.Profile
	var parentID sql.NullString

	err := config.DB.QueryRow(`
		SELECT id, full_name, email, role, parent_id
		FROM profile
		WHERE id = $1
	`, userID).Scan(&profile.ID, &profile.FullName, &profile.Email, &profile.Role, &parentID)

	if err != nil {
		log.Println("Query error (parent):", err)
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to retrieve profile",
		})
	}

	if parentID.Valid {
		profile.ParentID = parentID.String
	}

	if profile.Role != "Parent" {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"error": "Not authorized to view parent profile",
		})
	}

	rows, err := config.DB.Query(`
		SELECT id, full_name, birth_date
		FROM profile
		WHERE parent_id = $1
	`, profile.ID)

	if err != nil {
		log.Println("Query error (children):", err)
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to retrieve children",
		})
	}
	defer rows.Close()

	var children []fiber.Map
	for rows.Next() {
		var child models.Profile
		err := rows.Scan(&child.ID, &child.FullName, &child.BirthDate)
		if err != nil {
			log.Println("Row scan error:", err)
			continue
		}
		children = append(children, fiber.Map{
			"id":         child.ID,
			"full_name":  child.FullName,
			"birth_date": child.BirthDate,
		})
	}

	return c.JSON(fiber.Map{
		"id":        profile.ID,
		"full_name": profile.FullName,
		"email":     profile.Email,
		"role":      profile.Role,
		"children":  children,
	})
}

func GetChildProgress(c *fiber.Ctx) error {
	userID := c.Locals("userID").(string)

	var role string
	err := config.DB.QueryRow("SELECT role FROM profile WHERE id = $1", userID).Scan(&role)
	if err != nil || role != "Child" {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "Unauthorized"})
	}

	var total int
	err = config.DB.QueryRow("SELECT COUNT(*) FROM quiz").Scan(&total)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to get total quiz"})
	}

	var done int
	err = config.DB.QueryRow("SELECT COUNT(*) FROM quiz_results WHERE child_id = $1", userID).Scan(&done)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to get done quiz"})
	}

	percent := 0
	if total > 0 {
		percent = int(float64(done) / float64(total) * 100)
	}

	return c.JSON(fiber.Map{
		"total_quiz": total,
		"done_quiz":  done,
		"remaining":  total - done,
		"percentage": percent,
	})
}
