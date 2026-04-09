// Package middleware contains reusable Gin middleware functions.
// Middleware sits between the HTTP server and your handlers, intercepting
// every request so you can add cross-cutting concerns (logging, auth,
// rate-limiting, CORS) without touching any controller code.
package middleware

import (
	"fmt"
	"time"

	"github.com/gin-gonic/gin"
)

// Logger returns a Gin middleware that logs a structured, human-readable line
// for every HTTP request once it completes. It captures:
//   - Timestamp
//   - HTTP method and path
//   - Response status code (colour-coded)
//   - Request latency
//   - Client IP
//   - Error messages (if any handler called c.Error())
//
// This replaces Gin's default logger with a cleaner, more informative format.
func Logger() gin.HandlerFunc {
	return func(c *gin.Context) {
		// Record the time the request arrived.
		start := time.Now()
		path := c.Request.URL.Path
		rawQuery := c.Request.URL.RawQuery

		// c.Next() calls the remaining middleware chain and the final handler.
		// Everything after this line runs AFTER the handler returns.
		c.Next()

		// Calculate how long the handler took.
		latency := time.Since(start)

		// Append query string to the path if present.
		if rawQuery != "" {
			path = path + "?" + rawQuery
		}

		// Choose a colour for the status code to make logs scannable at a glance.
		statusCode := c.Writer.Status()
		statusColor := statusColor(statusCode)
		methodColor := methodColor(c.Request.Method)
		resetColor := "\033[0m"

		// Collect any errors that handlers attached via c.Error().
		errMsg := c.Errors.ByType(gin.ErrorTypePrivate).String()

		// Print one line per request to stdout.
		fmt.Printf("[TrustGuard] %v |%s %3d %s| %13v | %15s |%s %-7s %s %s %s\n",
			start.Format("2006/01/02 - 15:04:05"),
			statusColor, statusCode, resetColor,
			latency,
			c.ClientIP(),
			methodColor, c.Request.Method, resetColor,
			path,
			errMsg,
		)
	}
}

// statusColor returns an ANSI escape code that colours status codes:
// green for 2xx, yellow for 3xx/4xx, red for 5xx.
func statusColor(code int) string {
	switch {
	case code >= 200 && code < 300:
		return "\033[97;42m" // white text on green background
	case code >= 300 && code < 500:
		return "\033[90;43m" // dark text on yellow background
	default:
		return "\033[97;41m" // white text on red background
	}
}

// methodColor returns an ANSI colour for the HTTP method so GET/POST/DELETE
// are visually distinct in terminal output.
func methodColor(method string) string {
	switch method {
	case "GET":
		return "\033[97;44m" // blue
	case "POST":
		return "\033[97;46m" // cyan
	case "PUT":
		return "\033[97;43m" // yellow
	case "DELETE":
		return "\033[97;41m" // red
	default:
		return "\033[0m"
	}
}
