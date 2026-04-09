// This file shows exactly how to add a second AI provider without touching
// any other file in the codebase — the power of the Analyzer interface.
//
// To activate this provider:
//   1. Add HUGGINGFACE_TOKEN to your .env file.
//   2. Add HuggingFaceToken string to config.Config and load it in config/config.go.
//   3. In main.go, change:
//        var analyzer services.Analyzer = services.NewGeminiAnalyzer(cfg.GeminiAPIKey)
//      to:
//        var analyzer services.Analyzer = services.NewHuggingFaceAnalyzer(cfg.HuggingFaceToken)
//
// Nothing else changes — controllers, routes, models are untouched.
package services

import (
	"fmt"
	"trustguard/models"
)

// HuggingFaceAnalyzer is a stub implementation of the Analyzer interface.
// Replace the body of Analyze() with real HuggingFace Inference API calls
// when you're ready to use this provider.
type HuggingFaceAnalyzer struct {
	Token string // HuggingFace API token
}

// NewHuggingFaceAnalyzer constructs a HuggingFaceAnalyzer with the given token.
func NewHuggingFaceAnalyzer(token string) *HuggingFaceAnalyzer {
	return &HuggingFaceAnalyzer{Token: token}
}

// Analyze satisfies the Analyzer interface.
// Currently returns an error to make it clear this is a stub.
// Replace this with real HTTP calls to the HuggingFace Inference API.
//
// Suggested HuggingFace models to explore:
//   - facebook/roberta-hate-speech-dynabench-r4-target  (toxicity)
//   - mrm8488/bert-tiny-finetuned-sms-spam-detection    (spam)
func (h *HuggingFaceAnalyzer) Analyze(text string) (models.AnalysisResult, error) {
	// TODO: implement real HuggingFace API calls here.
	// The structure is the same as GeminiAnalyzer:
	//   1. Build a request body for the HF Inference API.
	//   2. POST to https://api-inference.huggingface.co/models/<model-name>
	//   3. Parse the response into models.AnalysisResult.
	return models.AnalysisResult{}, fmt.Errorf(
		"HuggingFaceAnalyzer is not yet implemented — use GeminiAnalyzer for now",
	)
}
