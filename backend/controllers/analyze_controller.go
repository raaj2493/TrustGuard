// Package controllers contains Gin HTTP handler functions.
// Controllers are intentionally thin — they:
//   1. Parse and validate the incoming request.
//   2. Call the appropriate service.
//   3. Write the HTTP response.
//
// Business logic (AI calls, parsing) lives in the services and utils packages,
// not here. This separation makes controllers easy to unit-test and keeps them
// from becoming unmaintainable "god functions".
package controllers

import (
	"net/http"
	"strings"
	"trustguard/models"
	"trustguard/services"

	"github.com/gin-gonic/gin"
)

// AnalyzeController handles requests to the POST /analyze endpoint.
// It holds a reference to the Analyzer interface so the concrete AI provider
// (Gemini, HuggingFace, …) is injected at startup rather than hard-coded here.
type AnalyzeController struct {
	analyzer services.Analyzer // Injected dependency — satisfies the Analyzer interface
}

// NewAnalyzeController is a constructor that wires the controller to its
// analyzer dependency. Using a constructor (vs. a global) enables easy
// testing with mock analyzers.
func NewAnalyzeController(analyzer services.Analyzer) *AnalyzeController {
	return &AnalyzeController{analyzer: analyzer}
}

// Analyze is the Gin handler for POST /analyze.
// Gin injects the *gin.Context which provides access to the request and
// lets us write the HTTP response.
func (ac *AnalyzeController) Analyze(c *gin.Context) {
	// Step 1 — bind and validate the JSON request body.
	// ShouldBindJSON returns an error if the body is malformed OR if any
	// field tagged `binding:"required"` is missing (see models.AnalyzeRequest).
	var req models.AnalyzeRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		// 400 Bad Request: the client sent an unusable payload.
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Status:  "error",
			Message: "Invalid request body. Please provide a JSON object with a 'text' field.",
		})
		return
	}

	// Step 2 — reject empty text after trimming whitespace.
	// binding:"required" only checks for field presence, not content.
	if strings.TrimSpace(req.Text) == "" {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Status:  "error",
			Message: "'text' field must not be empty or whitespace only.",
		})
		return
	}

	// Step 3 — call the AI service. The controller doesn't care whether
	// this calls Gemini, HuggingFace, or a mock — it only speaks the interface.
	result, err := ac.analyzer.Analyze(req.Text)
	if err != nil {
		// 502 Bad Gateway: the upstream AI service failed.
		// We wrap the error message so the client knows it's not their fault.
		c.JSON(http.StatusBadGateway, models.ErrorResponse{
			Status:  "error",
			Message: "AI analysis failed: " + err.Error(),
		})
		return
	}

	// Step 4 — return the successful analysis result.
	c.JSON(http.StatusOK, models.AnalyzeResponse{
		Status:   "success",
		Analysis: result,
	})
}
