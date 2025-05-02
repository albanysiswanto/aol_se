package utils

import (
	"lapar_backend/config"
	"log"

	"gopkg.in/gomail.v2"
)

func SendInvitationEmail(toEmail, inviteToken string) error {
	m := gomail.NewMessage()
	m.SetHeader("From", config.SMTPUser)
	m.SetHeader("To", toEmail)
	m.SetHeader("Subject", "Undangan untuk Bergabung di Aplikasi Lapar")
	m.SetBody("text/html", `
    <div style="font-family: 'Segoe UI', sans-serif; padding: 20px; background-color: #f9f9f9; color: #333;">
        <div style="max-width: 600px; margin: auto; background-color: #fff; border-radius: 8px; padding: 30px; box-shadow: 0 4px 12px rgba(0,0,0,0.05);">
            <h2 style="color: #2e7d32;">👋 Halo!</h2>
            <p style="font-size: 16px;">
                Kamu diundang untuk bergabung dalam aplikasi <strong style="color: #ef6c00;">Lapar</strong>, platform parenting digital yang membantu orang tua dan anak dalam mengelola waktu dan teknologi.
            </p>
            <p style="font-size: 16px;">
                Untuk mendaftar, silakan klik atau gunakan link unik di bawah ini:
            </p>
            <div style="margin: 20px 0; padding: 15px; background-color: #f1f8e9; border-left: 4px solid #66bb6a; font-weight: bold; word-break: break-all;">
                `+inviteToken+`
            </div>
            <p style="font-size: 16px;">
                Jika kamu tidak merasa mengenal aplikasi ini, abaikan saja email ini.
            </p>
            <p style="margin-top: 30px;">
                Salam hangat,<br/>
                <strong>Tim Lapar</strong>
            </p>
        </div>
        <div style="text-align: center; font-size: 12px; margin-top: 20px; color: #888;">
            &copy; 2025 Lapar. All rights reserved.
        </div>
    </div>
`)

	d := gomail.NewDialer(config.SMTPHost, config.SMTPPort, config.SMTPUser, config.SMTPPassword)

	err := d.DialAndSend(m)
	if err != nil {
		log.Printf("Failed to send email to %s: %v", toEmail, err)
		return err
	}

	log.Printf("Email successfully sent to %s", toEmail)
	return nil
}
