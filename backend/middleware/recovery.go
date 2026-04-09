// Recovery middleware catches any panic that occurs in a handler or downstream
// middleware, logs a stack trace, and returns a structured 500 JSON response
// instead of crashing the entire server process.
//
// Gin's built-in Recovery() does the same thing but returns an HTML page,
// which is inappropriate for a JSON API. This version always returns JSON.
package middleware

import (
	"fmt"
	"net/http"
	"runtime/debug"
	"trustguard/models"

	"github.com/gin-gonic/gin"
)

// Recovery returns a Gin middleware that recovers from panics.
// It logs the panic value and full stack trace to stdout, then responds
// with a 500 Internal Server Error in the standard ErrorResponse format.
func Recovery() gin.HandlerFunc {
	return func(c *gin.Context) {
		defer func() {
			if err := recover(); err != nil {
				// Print the panic value and a full stack trace for debugging.
				fmt.Printf("[TrustGuard] PANIC recovered: %v\n%s\n", err, debug.Stack())

				// Respond with a clean JSON 500 so clients get a usable error shape.
				c.JSON(http.StatusInternalServerError, models.ErrorResponse{
					Status:  "error",
					Message: "An unexpected internal error occurred. Please try again later.",
				})

				// Abort the chain so no further handlers or middleware run.
				c.Abort()
			}
		}()

		c.Next()
	}
}
