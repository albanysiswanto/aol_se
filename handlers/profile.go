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

	// Jika ada parent_id (untuk child), simpan ke profile
	if parentID.Valid {
		profile.ParentID = parentID.String
	}

	// Pastikan user adalah Parent
	if profile.Role != "Parent" {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"error": "Not authorized to view parent profile",
		})
	}

	// Ambil data anak-anaknya
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
