// Package utils provides reusable helper functions that don't belong to any
// single layer of the application. Keeping them here avoids duplication and
// makes unit-testing individual helpers straightforward.
package utils

import (
	"encoding/json"
	"fmt"
	"strings"
	"trustguard/models"
)

// ParseAnalysisResult takes the raw text response from the AI model and
// attempts to decode it into a structured AnalysisResult.
//
// Strategy:
//  1. Strip any markdown code fences (``` json ... ```) that the model might add.
//  2. Attempt a strict JSON unmarshal.
//  3. If that fails, fall back to BuildFallbackResult so we always return something.
func ParseAnalysisResult(rawText string) (models.AnalysisResult, error) {
	// Step 1 — strip markdown fences that Gemini sometimes wraps around JSON.
	cleaned := StripMarkdownFences(rawText)

	// Step 2 — try to unmarshal the cleaned string as JSON.
	var result models.AnalysisResult
	if err := json.Unmarshal([]byte(cleaned), &result); err != nil {
		// Step 3 — JSON parsing failed; build a safe fallback result so the
		// API still returns a usable (if degraded) response instead of a 500.
		fmt.Printf("Warning: could not parse AI JSON response: %v\nRaw text: %s\n", err, rawText)
		return BuildFallbackResult(rawText), nil
	}

	// Normalise the toxicity field to one of the three allowed values so
	// callers never have to handle unexpected strings.
	result.Toxicity = NormalizeToxicity(result.Toxicity)

	return result, nil
}

// StripMarkdownFences removes the ```json ... ``` wrapper that language models
// sometimes add around JSON output, leaving only the raw JSON string.
func StripMarkdownFences(s string) string {
	// Trim surrounding whitespace first.
	s = strings.TrimSpace(s)

	// Handle both ```json\n...\n``` and ```\n...\n``` variants.
	if strings.HasPrefix(s, "```json") {
		s = strings.TrimPrefix(s, "```json")
	} else if strings.HasPrefix(s, "```") {
		s = strings.TrimPrefix(s, "```")
	}

	// Remove the closing fence if present.
	s = strings.TrimSuffix(s, "```")

	return strings.TrimSpace(s)
}

// NormalizeToxicity maps any toxicity string the AI returns to one of the
// three canonical values: "low", "medium", or "high".
// Unknown values are treated as "medium" to err on the side of caution.
func NormalizeToxicity(t string) string {
	switch strings.ToLower(strings.TrimSpace(t)) {
	case "low":
		return "low"
	case "high":
		return "high"
	default:
		// "medium" or anything unexpected becomes "medium".
		return "medium"
	}
}

// BuildFallbackResult constructs a conservative AnalysisResult when the AI
// response cannot be parsed as JSON. It signals clearly that something went
// wrong via the Summary field while still conforming to the response schema.
func BuildFallbackResult(rawText string) models.AnalysisResult {
	return models.AnalysisResult{
		Toxicity:   "medium",           // Assume medium risk when uncertain
		Spam:       false,              // Default to non-spam to avoid false positives
		TrustScore: 0.5,               // Neutral trust score
		Summary:    "Analysis could not be fully parsed. Raw response: " + rawText,
	}
}
