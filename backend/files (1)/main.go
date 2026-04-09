// main.go is the entry point for TrustGuard.
// Its only job is to wire the application together:
//   1. Load configuration from the environment.
//   2. Construct the dependency graph (config → service → controller → router).
//   3. Attach middleware.
//   4. Start the HTTP server.
//
// main.go intentionally contains NO business logic — all logic lives in the
// packages it imports. This makes the wiring easy to read and change.
package main

import (
	"log"
	"time"
	"trustguard/config"
	"trustguard/controllers"
	"trustguard/middleware"
	"trustguard/routes"
	"trustguard/services"

	"github.com/gin-gonic/gin"
)

func main() {
	// ── 1. Load configuration ──────────────────────────────────────────────
	// config.Load() reads .env (or system environment) and crashes early with
	// a clear message if required variables like GEMINI_API_KEY are missing.
	cfg := config.Load()
	log.Printf("TrustGuard starting on port %s", cfg.Port)

	// ── 2. Build the service layer ─────────────────────────────────────────
	// Swapping providers means changing only this one line.
	var analyzer services.Analyzer = services.NewGroqAnalyzer(cfg.GroqAPIKey)

	// ── 3. Build the controller layer ──────────────────────────────────────
	analyzeCtrl := controllers.NewAnalyzeController(analyzer)

	// ── 4. Create Gin engine — no default middleware ───────────────────────
	// We use gin.New() so we can attach custom middleware that always returns
	// structured JSON (Gin's default Recovery returns HTML, which breaks API clients).
	r := gin.New()

	// ── 5. Attach global middleware (order matters!) ───────────────────────
	r.Use(middleware.Recovery())              // First: catch panics from every other layer
	r.Use(middleware.RequestID())             // Stamp X-Request-ID before logging
	r.Use(middleware.Logger())                // Log after handler so we have the status code
	r.Use(middleware.CORS())                  // Allow browser clients cross-origin access
	r.Use(middleware.RateLimiter(20, time.Minute)) // 20 req/min per IP

	// ── 6. Register all routes ─────────────────────────────────────────────
	routes.RegisterRoutes(r, analyzeCtrl)

	// ── 7. Start the server ────────────────────────────────────────────────
	if err := r.Run(":" + cfg.Port); err != nil {
		log.Fatalf("Server failed to start: %v", err)
	}
}
