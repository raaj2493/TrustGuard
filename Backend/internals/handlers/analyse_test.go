package handlers

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
)

func setupTestRouter() *gin.Engine {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	r.POST("/analyze", AnalyzedNews)
	r.POST("/analyze-url", AnalyzeURL)
	return r
}

func TestAnalyzedNews_EmptyRequest(t *testing.T) {
	r := setupTestRouter()

	reqBody, _ := json.Marshal(map[string]string{"text": ""})
	req, _ := http.NewRequest("POST", "/analyze", bytes.NewBuffer(reqBody))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()

	r.ServeHTTP(w, req)

	if w.Code != http.StatusBadRequest {
		t.Errorf("expected status 400 for empty text, got %d", w.Code)
	}
}

func TestAnalyzeURL_MissingURL(t *testing.T) {
	r := setupTestRouter()

	reqBody, _ := json.Marshal(map[string]string{"url": ""})
	req, _ := http.NewRequest("POST", "/analyze-url", bytes.NewBuffer(reqBody))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()

	r.ServeHTTP(w, req)

	if w.Code != http.StatusBadRequest {
		t.Errorf("expected status 400 for empty url, got %d", w.Code)
	}
}

func TestAnalyzeURL_InvalidScheme(t *testing.T) {
	r := setupTestRouter()

	reqBody, _ := json.Marshal(map[string]string{"url": "not-a-valid-url"})
	req, _ := http.NewRequest("POST", "/analyze-url", bytes.NewBuffer(reqBody))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()

	r.ServeHTTP(w, req)

	// Should return 422 Unprocessable Entity because URL cannot be parsed/scraped
	if w.Code != http.StatusUnprocessableEntity {
		t.Errorf("expected status 422 for invalid URL scheme, got %d", w.Code)
	}
}
