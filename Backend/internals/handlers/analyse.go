package handlers

import (
	"log"

	"github.com/gin-gonic/gin"
	"trustguard/internals/services"
)

type Request struct {
	Text string `json:"text"`
}

func AnalyzedNews(c *gin.Context){
	var req Request

	// Bind JSON request
	if err := c.BindJSON(&req); err != nil {
		c.JSON(400, gin.H{"error": "Invalid request"})
		return
	}

	// Call Gemini service
	result, err := services.AnalyzeWithGemini(req.Text)

	if err != nil {
		log.Println("AI Error:", err)
		c.JSON(500, gin.H{"error": "AI service failed"})
		return
	}

	// Return raw Gemini response
	c.JSON(200, result)

}