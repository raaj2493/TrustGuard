// Integration tests for the analyze controller.
// These tests spin up a real Gin engine but inject a MockAnalyzer so no
// network calls are made. Every test runs in milliseconds.
//
// Run with: go test ./controllers/...
package controllers

import (
	"bytes"
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"testing"
	"trustguard/models"
	"trustguard/services/mock"

	"github.com/gin-gonic/gin"
)

// setupRouter creates a test Gin engine wired to the given mock analyzer.
// Using gin.TestMode suppresses debug output during test runs.
func setupRouter(m *mock.MockAnalyzer) *gin.Engine {
	gin.SetMode(gin.TestMode)
	r := gin.New() // No default middleware so tests are noise-free
	ctrl := NewAnalyzeController(m)
	r.POST("/analyze", ctrl.Analyze)
	return r
}

// postAnalyze is a helper that fires a POST /analyze request and returns
// the response recorder so tests can inspect the status and body.
func postAnalyze(r *gin.Engine, body any) *httptest.ResponseRecorder {
	b, _ := json.Marshal(body)
	req, _ := http.NewRequest(http.MethodPost, "/analyze", bytes.NewBuffer(b))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)
	return w
}

// ── Success path ───────────────────────────────────────────────────────────

func TestAnalyze_Success(t *testing.T) {
	m := &mock.MockAnalyzer{
		Result: models.AnalysisResult{
			Toxicity:   "low",
			Spam:       false,
			TrustScore: 0.95,
			Summary:    "Polite and informative.",
		},
	}
	r := setupRouter(m)
	w := postAnalyze(r, map[string]string{"text": "Hello, how are you?"})

	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d — body: %s", w.Code, w.Body.String())
	}

	var resp models.AnalyzeResponse
	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Fatalf("could not unmarshal response: %v", err)
	}

	if resp.Status != "success" {
		t.Errorf("Status = %q, want \"success\"", resp.Status)
	}
	if resp.Analysis.Toxicity != "low" {
		t.Errorf("Toxicity = %q, want \"low\"", resp.Analysis.Toxicity)
	}
	if resp.Analysis.TrustScore != 0.95 {
		t.Errorf("TrustScore = %v, want 0.95", resp.Analysis.TrustScore)
	}

	// Verify the controller passed the correct text to the service.
	if m.LastText != "Hello, how are you?" {
		t.Errorf("MockAnalyzer.LastText = %q, want \"Hello, how are you?\"", m.LastText)
	}
	if m.CallCount != 1 {
		t.Errorf("MockAnalyzer.CallCount = %d, want 1", m.CallCount)
	}
}

// ── Validation error paths ────────────────────────────────────────────────

func TestAnalyze_MissingTextField_Returns400(t *testing.T) {
	m := &mock.MockAnalyzer{}
	r := setupRouter(m)
	// Send a body that has no "text" field at all.
	w := postAnalyze(r, map[string]string{"wrong_field": "value"})

	if w.Code != http.StatusBadRequest {
		t.Errorf("expected 400, got %d", w.Code)
	}
	// The service should NOT have been called.
	if m.CallCount != 0 {
		t.Errorf("service was called unexpectedly")
	}
}

func TestAnalyze_EmptyText_Returns400(t *testing.T) {
	m := &mock.MockAnalyzer{}
	r := setupRouter(m)
	w := postAnalyze(r, map[string]string{"text": "   "}) // whitespace only

	if w.Code != http.StatusBadRequest {
		t.Errorf("expected 400, got %d — body: %s", w.Code, w.Body.String())
	}
}

func TestAnalyze_InvalidJSON_Returns400(t *testing.T) {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	r.POST("/analyze", NewAnalyzeController(&mock.MockAnalyzer{}).Analyze)

	// Send a deliberately malformed body.
	req, _ := http.NewRequest(http.MethodPost, "/analyze", bytes.NewBufferString("{not valid json"))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusBadRequest {
		t.Errorf("expected 400, got %d", w.Code)
	}
}

// ── Service error path ─────────────────────────────────────────────────────

func TestAnalyze_ServiceError_Returns502(t *testing.T) {
	m := &mock.MockAnalyzer{
		Err: errors.New("Gemini API returned status 429"),
	}
	r := setupRouter(m)
	w := postAnalyze(r, map[string]string{"text": "test input"})

	if w.Code != http.StatusBadGateway {
		t.Errorf("expected 502, got %d — body: %s", w.Code, w.Body.String())
	}

	var resp models.ErrorResponse
	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Fatalf("could not unmarshal error response: %v", err)
	}
	if resp.Status != "error" {
		t.Errorf("Status = %q, want \"error\"", resp.Status)
	}
}

// ── Response shape ─────────────────────────────────────────────────────────

func TestAnalyze_ResponseShape(t *testing.T) {
	// Verify the JSON keys in the response exactly match the API contract.
	m := &mock.MockAnalyzer{
		Result: models.AnalysisResult{Toxicity: "medium", Spam: true, TrustScore: 0.4, Summary: "Borderline."},
	}
	r := setupRouter(m)
	w := postAnalyze(r, map[string]string{"text": "buy now!"})

	// Decode into a generic map so we can check key names precisely.
	var raw map[string]any
	if err := json.Unmarshal(w.Body.Bytes(), &raw); err != nil {
		t.Fatalf("unmarshal error: %v", err)
	}

	if _, ok := raw["status"]; !ok {
		t.Error("response missing 'status' key")
	}
	analysis, ok := raw["analysis"].(map[string]any)
	if !ok {
		t.Fatal("response missing 'analysis' object")
	}
	for _, key := range []string{"toxicity", "spam", "trust_score", "summary"} {
		if _, ok := analysis[key]; !ok {
			t.Errorf("analysis object missing key %q", key)
		}
	}
}
