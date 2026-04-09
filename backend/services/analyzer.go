// Package services contains the core business logic of TrustGuard.
// This file defines the Analyzer interface — the contract that every
// AI backend (Gemini, HuggingFace, etc.) must satisfy.
//
// Using an interface here is the key architectural decision:
//   - Controllers depend only on this interface, never on a concrete implementation.
//   - Swapping the AI provider is a one-line change in main.go.
//   - Each provider can be tested independently with mocks.
package services

import "trustguard/models"

// Analyzer is the single abstraction for any content-moderation AI backend.
// Any struct that implements this interface can be dropped into the system.
//
// To add a new provider (e.g. HuggingFace):
//  1. Create huggingface_analyzer.go in this package.
//  2. Define type HuggingFaceAnalyzer struct { ... }.
//  3. Implement func (h *HuggingFaceAnalyzer) Analyze(text string) (models.AnalysisResult, error).
//  4. In main.go, replace GeminiAnalyzer{} with HuggingFaceAnalyzer{}.
//
// No other files need to change.
type Analyzer interface {
	// Analyze takes a piece of user-generated text and returns a structured
	// AnalysisResult. It returns an error only when the underlying AI call
	// fails entirely (network error, auth failure, etc.).
	Analyze(text string) (models.AnalysisResult, error)
}
