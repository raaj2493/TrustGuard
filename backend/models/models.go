// Package models defines all data transfer objects (DTOs) used across the application.
// Keeping models in their own package prevents import cycles and gives a single
// source of truth for what data looks like at every layer.
package models

// AnalyzeRequest is the JSON body the client sends to POST /analyze.
// The `binding:"required"` tag tells Gin's validator to reject requests
// that omit the "text" field, returning a 400 automatically.
type AnalyzeRequest struct {
	Text string `json:"text" binding:"required"` // The user-generated content to evaluate
}

// AnalysisResult contains the structured output produced by the AI analyzer.
// This is embedded inside AnalyzeResponse so the API shape is:
//
//	{ "status": "...", "analysis": { ... } }
type AnalysisResult struct {
	Toxicity   string  `json:"toxicity"`    // "low", "medium", or "high"
	Spam       bool    `json:"spam"`        // true if the text looks like spam
	TrustScore float64 `json:"trust_score"` // 0.0 (not trustworthy) → 1.0 (fully trustworthy)
	Summary    string  `json:"summary"`     // Human-readable explanation from the AI
}

// AnalyzeResponse is the top-level JSON object returned to the client on success.
type AnalyzeResponse struct {
	Status   string         `json:"status"`   // Always "success" on a 200 response
	Analysis AnalysisResult `json:"analysis"` // The nested analysis object
}

// ErrorResponse is returned whenever the API encounters an error.
// Using a consistent error shape makes it easy for clients to handle failures.
type ErrorResponse struct {
	Status  string `json:"status"`  // Always "error"
	Message string `json:"message"` // Human-readable description of what went wrong
}

// GeminiRequest is the payload we POST to the Google Gemini REST API.
// Gemini expects an array of "contents", each containing an array of "parts".
type GeminiRequest struct {
	Contents []GeminiContent `json:"contents"`
}

// GeminiContent represents one turn in the conversation (we only ever send one).
type GeminiContent struct {
	Parts []GeminiPart `json:"parts"`
}

// GeminiPart holds the actual text of a single content part.
type GeminiPart struct {
	Text string `json:"text"`
}

// GeminiResponse mirrors the top-level structure of Gemini's JSON reply.
// We only decode the fields we care about; Go silently ignores unknown fields.
type GeminiResponse struct {
	Candidates []GeminiCandidate `json:"candidates"`
}

// GeminiCandidate is one possible completion returned by Gemini.
// In practice, we always use the first candidate.
type GeminiCandidate struct {
	Content GeminiContent `json:"content"`
}
