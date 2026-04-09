// Unit tests for the utils/parser.go helpers.
// These tests run without any network calls or API keys.
// Run with: go test ./utils/...
package utils

import (
	"testing"
)

// ── StripMarkdownFences ────────────────────────────────────────────────────

func TestStripMarkdownFences_WithJsonFence(t *testing.T) {
	input := "```json\n{\"toxicity\":\"low\"}\n```"
	want := "{\"toxicity\":\"low\"}"
	got := StripMarkdownFences(input)
	if got != want {
		t.Errorf("StripMarkdownFences() = %q, want %q", got, want)
	}
}

func TestStripMarkdownFences_WithPlainFence(t *testing.T) {
	input := "```\n{\"spam\":true}\n```"
	want := "{\"spam\":true}"
	got := StripMarkdownFences(input)
	if got != want {
		t.Errorf("StripMarkdownFences() = %q, want %q", got, want)
	}
}

func TestStripMarkdownFences_WithoutFence(t *testing.T) {
	input := "{\"trust_score\":0.9}"
	want := "{\"trust_score\":0.9}"
	got := StripMarkdownFences(input)
	if got != want {
		t.Errorf("StripMarkdownFences() = %q, want %q", got, want)
	}
}

func TestStripMarkdownFences_WithWhitespace(t *testing.T) {
	input := "  \n  {\"foo\":\"bar\"}  \n  "
	want := "{\"foo\":\"bar\"}"
	got := StripMarkdownFences(input)
	if got != want {
		t.Errorf("StripMarkdownFences() = %q, want %q", got, want)
	}
}

// ── NormalizeToxicity ──────────────────────────────────────────────────────

func TestNormalizeToxicity_Low(t *testing.T) {
	for _, input := range []string{"low", "Low", "LOW", "  low  "} {
		got := NormalizeToxicity(input)
		if got != "low" {
			t.Errorf("NormalizeToxicity(%q) = %q, want \"low\"", input, got)
		}
	}
}

func TestNormalizeToxicity_High(t *testing.T) {
	for _, input := range []string{"high", "High", "HIGH"} {
		got := NormalizeToxicity(input)
		if got != "high" {
			t.Errorf("NormalizeToxicity(%q) = %q, want \"high\"", input, got)
		}
	}
}

func TestNormalizeToxicity_MediumAndUnknown(t *testing.T) {
	for _, input := range []string{"medium", "Medium", "MEDIUM", "unknown", "", "extreme"} {
		got := NormalizeToxicity(input)
		if got != "medium" {
			t.Errorf("NormalizeToxicity(%q) = %q, want \"medium\"", input, got)
		}
	}
}

// ── ParseAnalysisResult ────────────────────────────────────────────────────

func TestParseAnalysisResult_ValidJSON(t *testing.T) {
	raw := `{"toxicity":"high","spam":true,"trust_score":0.2,"summary":"Hateful content."}`
	result, err := ParseAnalysisResult(raw)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if result.Toxicity != "high" {
		t.Errorf("Toxicity = %q, want \"high\"", result.Toxicity)
	}
	if !result.Spam {
		t.Errorf("Spam = false, want true")
	}
	if result.TrustScore != 0.2 {
		t.Errorf("TrustScore = %v, want 0.2", result.TrustScore)
	}
	if result.Summary != "Hateful content." {
		t.Errorf("Summary = %q, want \"Hateful content.\"", result.Summary)
	}
}

func TestParseAnalysisResult_JSONWrappedInFences(t *testing.T) {
	raw := "```json\n{\"toxicity\":\"low\",\"spam\":false,\"trust_score\":0.9,\"summary\":\"Fine.\"}\n```"
	result, err := ParseAnalysisResult(raw)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if result.Toxicity != "low" {
		t.Errorf("Toxicity = %q, want \"low\"", result.Toxicity)
	}
}

func TestParseAnalysisResult_InvalidJSON_ReturnsFallback(t *testing.T) {
	// When JSON can't be parsed, ParseAnalysisResult should return a fallback,
	// not an error — so the API degrades gracefully.
	raw := "This is not JSON at all"
	result, err := ParseAnalysisResult(raw)
	if err != nil {
		t.Fatalf("expected no error on invalid JSON, got: %v", err)
	}
	// Fallback should be conservative (medium toxicity, 0.5 trust).
	if result.Toxicity != "medium" {
		t.Errorf("fallback Toxicity = %q, want \"medium\"", result.Toxicity)
	}
	if result.TrustScore != 0.5 {
		t.Errorf("fallback TrustScore = %v, want 0.5", result.TrustScore)
	}
}

// ── BuildFallbackResult ────────────────────────────────────────────────────

func TestBuildFallbackResult_ContainsRawText(t *testing.T) {
	raw := "some unparseable AI output"
	result := BuildFallbackResult(raw)
	if result.TrustScore != 0.5 {
		t.Errorf("TrustScore = %v, want 0.5", result.TrustScore)
	}
	if result.Toxicity != "medium" {
		t.Errorf("Toxicity = %q, want \"medium\"", result.Toxicity)
	}
	// The summary should contain the raw text so engineers can debug.
	if len(result.Summary) == 0 {
		t.Error("Summary should not be empty in fallback result")
	}
}
