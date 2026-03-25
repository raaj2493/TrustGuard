package main

import (
	"github.com/gin-gonic/gin"
)

func main(){
	r := gin.Default()
	// Test route
	r.GET("/", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"message": "TrustGuard Backend Running 🚀",
		})
	})

	r.POST("/analyse" , func( c *gin.Context)){
		var req struct {
			Text string `json:"text"`
		}

		if err := c.BindJSON(&req); err != nil {
			c.JSON(400, gin.H{"error": err.Error()})
			return
		}

		c.json(200 , gin.H{
			"prediction" : "false",
			"confidence" : 90,
		})
	}

	r.Run(":8080")
}