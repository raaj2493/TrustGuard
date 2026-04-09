// Unit tests for the rate limiter middleware.
// Run with: go test ./middleware/...
package middleware

import (
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/gin-gonic/gin"
)

func setupRateLimitRouter(maxReq int, window time.Duration) *gin.Engine {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	r.Use(RateLimiter(maxReq, window))
	r.GET("/ping", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"ok": true})
	})
	return r
}

func TestRateLimiter_AllowsRequestsUnderLimit(t *testing.T) {
	r := setupRateLimitRouter(5, time.Minute)

	for i := 0; i < 5; i++ {
		req, _ := http.NewRequest(http.MethodGet, "/ping", nil)
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)
		if w.Code != http.StatusOK {
			t.Errorf("request %d: expected 200, got %d", i+1, w.Code)
		}
	}
}

func TestRateLimiter_BlocksRequestsOverLimit(t *testing.T) {
	r := setupRateLimitRouter(3, time.Minute)

	// First 3 should succeed.
	for i := 0; i < 3; i++ {
		req, _ := http.NewRequest(http.MethodGet, "/ping", nil)
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)
		if w.Code != http.StatusOK {
			t.Errorf("request %d: expected 200, got %d", i+1, w.Code)
		}
	}

	// 4th should be rate-limited.
	req, _ := http.NewRequest(http.MethodGet, "/ping", nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)
	if w.Code != http.StatusTooManyRequests {
		t.Errorf("expected 429, got %d", w.Code)
	}
}

func TestRateLimiter_ResetsAfterWindow(t *testing.T) {
	// Use a very short window so the test doesn't take long.
	r := setupRateLimitRouter(1, 100*time.Millisecond)

	// First request — should pass.
	req1, _ := http.NewRequest(http.MethodGet, "/ping", nil)
	w1 := httptest.NewRecorder()
	r.ServeHTTP(w1, req1)
	if w1.Code != http.StatusOK {
		t.Fatalf("first request: expected 200, got %d", w1.Code)
	}

	// Second request immediately — should be blocked.
	req2, _ := http.NewRequest(http.MethodGet, "/ping", nil)
	w2 := httptest.NewRecorder()
	r.ServeHTTP(w2, req2)
	if w2.Code != http.StatusTooManyRequests {
		t.Fatalf("second request: expected 429, got %d", w2.Code)
	}

	// Wait for the window to expire.
	time.Sleep(150 * time.Millisecond)

	// Third request after window — should pass again.
	req3, _ := http.NewRequest(http.MethodGet, "/ping", nil)
	w3 := httptest.NewRecorder()
	r.ServeHTTP(w3, req3)
	if w3.Code != http.StatusOK {
		t.Fatalf("third request after window: expected 200, got %d", w3.Code)
	}
}
