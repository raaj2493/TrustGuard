// RateLimiter middleware protects the API from abuse by capping the number of
// requests a single IP address can make within a rolling time window.
//
// This implementation uses a simple in-memory token-bucket per IP.
// For multi-instance deployments, swap the in-memory store with Redis
// (e.g. github.com/go-redis/redis_rate) — the middleware signature stays identical.
package middleware

import (
	"net/http"
	"sync"
	"time"
	"trustguard/models"

	"github.com/gin-gonic/gin"
)

// ipBucket tracks request timestamps for one IP address.
type ipBucket struct {
	mu         sync.Mutex // guards the timestamps slice
	timestamps []time.Time
}

// rateLimiterStore is the global in-memory map from IP → bucket.
// sync.Map is safe for concurrent reads/writes without a global lock.
var rateLimiterStore sync.Map

// RateLimiter returns a Gin middleware that allows at most `maxRequests`
// requests per `window` duration from a single IP address.
//
// Example — 10 requests per minute:
//
//	r.Use(middleware.RateLimiter(10, time.Minute))
func RateLimiter(maxRequests int, window time.Duration) gin.HandlerFunc {
	return func(c *gin.Context) {
		ip := c.ClientIP()

		// Load or create a bucket for this IP.
		val, _ := rateLimiterStore.LoadOrStore(ip, &ipBucket{})
		bucket := val.(*ipBucket)

		bucket.mu.Lock()

		now := time.Now()
		windowStart := now.Add(-window)

		// Prune timestamps that have fallen outside the current window.
		valid := bucket.timestamps[:0]
		for _, t := range bucket.timestamps {
			if t.After(windowStart) {
				valid = append(valid, t)
			}
		}
		bucket.timestamps = valid

		if len(bucket.timestamps) >= maxRequests {
			// Too many requests — reject with 429 and a helpful header.
			bucket.mu.Unlock()
			c.Header("Retry-After", window.String())
			c.JSON(http.StatusTooManyRequests, models.ErrorResponse{
				Status:  "error",
				Message: "Rate limit exceeded. Please slow down your requests.",
			})
			c.Abort() // Stop the middleware chain; don't call the handler.
			return
		}

		// Record this request and allow it through.
		bucket.timestamps = append(bucket.timestamps, now)
		bucket.mu.Unlock()

		c.Next()
	}
}
