// Package routes is responsible solely for wiring URL paths to handler functions.
// Keeping routing in its own package means you can see every endpoint at a glance
// without scrolling through business logic, and adding new routes never touches
// controller or service code.
package routes

import (
	"trustguard/controllers"

	"github.com/gin-gonic/gin"
)

// RegisterRoutes attaches all application routes to the provided Gin engine.
// It receives the controller (already wired with its dependencies) so this
// function stays decoupled from how the controller was constructed.
//
// Call this function once from main.go after creating the engine.
func RegisterRoutes(r *gin.Engine, analyzeCtrl *controllers.AnalyzeController) {
	// Health-check endpoint — useful for Docker/Kubernetes liveness probes and
	// smoke-testing that the server is up without consuming AI quota.
	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"status":  "ok",
			"service": "TrustGuard",
		})
	})

	// Group all API routes under /api/v1 so future versions (/api/v2) can
	// coexist without breaking existing clients.
	v1 := r.Group("/api/v1")
	{
		// POST /api/v1/analyze — main content moderation endpoint.
		// The handler is defined in controllers/analyze_controller.go.
		v1.POST("/analyze", analyzeCtrl.Analyze)
	}

	// Keep the original /analyze path as an alias for convenience during
	// local development and Postman testing (matches the spec in the README).
	r.POST("/analyze", analyzeCtrl.Analyze)
}
