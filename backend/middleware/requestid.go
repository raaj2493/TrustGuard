// RequestID middleware attaches a unique identifier to every HTTP request.
// This makes it possible to trace a single request across all log lines,
// even in a high-traffic environment where logs from many requests interleave.
//
// The ID is passed back to the client in the X-Request-ID response header
// so they can include it in bug reports.
package middleware

import (
	"crypto/rand"
	"encoding/hex"

	"github.com/gin-gonic/gin"
)

// requestIDKey is the key used to store the request ID in Gin's context.
// Using a typed constant prevents accidental key collisions.
const requestIDKey = "RequestID"

// RequestID returns middleware that generates a unique hex ID for every request,
// stores it in the Gin context, and echoes it back in the X-Request-ID header.
func RequestID() gin.HandlerFunc {
	return func(c *gin.Context) {
		// Honour an existing X-Request-ID header if the client (or a proxy) sent one.
		// This allows end-to-end tracing across multiple services.
		id := c.GetHeader("X-Request-ID")

		if id == "" {
			// Generate a 16-byte (32 hex char) random ID.
			id = generateID()
		}

		// Store the ID so handlers can log it with c.GetString(requestIDKey).
		c.Set(requestIDKey, id)

		// Echo the ID back so the client can reference it in support requests.
		c.Header("X-Request-ID", id)

		c.Next()
	}
}

// GetRequestID retrieves the request ID from the Gin context.
// Use this in controllers/services when you want to include the ID in logs.
func GetRequestID(c *gin.Context) string {
	return c.GetString(requestIDKey)
}

// generateID returns a cryptographically random 32-character hex string.
func generateID() string {
	b := make([]byte, 16)
	if _, err := rand.Read(b); err != nil {
		// Extremely unlikely; fall back to a static string rather than panicking.
		return "unknown-request-id"
	}
	return hex.EncodeToString(b)
}
