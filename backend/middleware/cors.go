// CORS (Cross-Origin Resource Sharing) middleware allows browser-based
// frontends hosted on a different domain to call this API.
// Without this, browsers block cross-origin requests by default.
package middleware

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

// CORS returns a Gin middleware that sets the appropriate headers to allow
// cross-origin requests from browser clients.
//
// In production, replace the wildcard "*" origin with your actual frontend
// domain (e.g. "https://app.trustguard.io") for tighter security.
func CORS() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Header("Access-Control-Allow-Origin", "*")
		c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		c.Header("Access-Control-Allow-Headers", "Origin, Content-Type, Authorization, X-Request-ID")
		c.Header("Access-Control-Max-Age", "86400") // Cache preflight for 24 hours

		// Handle preflight OPTIONS request.
		// Browsers send OPTIONS before POST/PUT when custom headers are present.
		if c.Request.Method == http.MethodOptions {
			c.AbortWithStatus(http.StatusNoContent) // 204 — no body needed
			return
		}

		c.Next()
	}
}
