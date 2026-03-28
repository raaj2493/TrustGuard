package main

import (
	"log"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
	"trustguard/internals/handlers"
)

func main() {

	// Load environment variables
	err := godotenv.Load(".env")
	if err != nil {
		err = godotenv.Load("../.env")
	}
	if err != nil {
		log.Println("No .env file found, using system env variables")
	}

	r := gin.Default()

	// Add CORS middleware so Flutter Web can access it
	r.Use(cors.Default())

	r.GET("/", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"message": "TrustGuard Backend Running 🚀",
		})
	})

	r.POST("/analyze", handlers.AnalyzedNews)

	r.Run(":8080")
}