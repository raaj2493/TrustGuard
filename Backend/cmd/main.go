package main

import (
	"log"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
	"internals/handlers"
)

func main() {

	// Load environment variables
	err := godotenv.Load()
	if err != nil {
		log.Fatal("Error loading .env file")
	}

	r := gin.Default()

	r.GET("/", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"message": "TrustGuard Backend Running 🚀",
		})
	})

	r.POST("/analyze", handlers.AnalyzeNews)

	r.Run(":8080")
}