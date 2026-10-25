package handlers

import (
	"fmt"
	"log"
	"strings"

	"github.com/gin-gonic/gin"
	"trustguard/internals/services"
)

type AnalyzeRequest struct {
	Text string `json:"text"`
	URL  string `json:"url"`
}

func AnalyzedNews(c *gin.Context) {
	var req AnalyzeRequest

	if err := c.BindJSON(&req); err != nil {
		c.JSON(400, gin.H{"error": "Invalid request body"})
		return
	}

	// If URL is supplied in /analyze, forward to URL scraping flow
	if strings.TrimSpace(req.URL) != "" && strings.TrimSpace(req.Text) == "" {
		handleURLAnalysis(c, req.URL)
		return
	}

	if strings.TrimSpace(req.Text) == "" {
		c.JSON(400, gin.H{"error": "Please provide text or a URL to analyze"})
		return
	}

	// Call Gemini service with Google Search Grounding
	result, err := services.AnalyzeWithGemini(req.Text)
	if err != nil {
		log.Println("AI Error:", err)
		c.JSON(500, gin.H{"error": fmt.Sprintf("AI service error: %v", err)})
		return
	}

	c.JSON(200, result)
}

func AnalyzeURL(c *gin.Context) {
	var req AnalyzeRequest
	if err := c.BindJSON(&req); err != nil || strings.TrimSpace(req.URL) == "" {
		c.JSON(400, gin.H{"error": "A valid 'url' field is required"})
		return
	}

	handleURLAnalysis(c, req.URL)
}

func handleURLAnalysis(c *gin.Context, targetURL string) {
	// 1. Scrape web page content
	scraped, err := services.ScrapeURL(targetURL)
	if err != nil {
		log.Printf("Scraping error for %s: %v\n", targetURL, err)
		c.JSON(422, gin.H{
			"error": fmt.Sprintf("Could not extract article content: %v", err),
		})
		return
	}

	// 2. Prepare analysis prompt text combining title and content
	textToAnalyze := fmt.Sprintf("Title: %s\n\nContent:\n%s", scraped.Title, scraped.Content)

	// 3. Analyze with Gemini & Google Search Grounding
	result, err := services.AnalyzeWithGemini(textToAnalyze)
	if err != nil {
		log.Println("AI Error during URL analysis:", err)
		c.JSON(500, gin.H{"error": "AI service failed to analyze scraped article"})
		return
	}

	result.ScrapedTitle = scraped.Title
	result.ScrapedURL = scraped.URL

	c.JSON(200, result)
}