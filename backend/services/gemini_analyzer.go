// This file contains GroqAnalyzer — the concrete implementation of the
// Analyzer interface that calls the Groq API.
// Groq is extremely fast, has a generous free tier (14,400 req/day),
// and uses the standard OpenAI-compatible chat completions format.
package services

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"
	"trustguard/utils"
	"trustguard/models"
)

const groqAPIURL = "https://api.groq.com/openai/v1/chat/completions"
const groqModel   = "llama-3.3-70b-versatile" // Current free tier model

// GroqAnalyzer calls the Groq API and satisfies the Analyzer interface.
type GroqAnalyzer struct {
	APIKey     string
	HTTPClient *http.Client
}

// NewGroqAnalyzer returns a ready-to-use GroqAnalyzer.
func NewGroqAnalyzer(apiKey string) *GroqAnalyzer {
	return &GroqAnalyzer{
		APIKey: apiKey,
		HTTPClient: &http.Client{
			Timeout: 30 * time.Second,
		},
	}
}

// groqRequest is the payload sent to the Groq /chat/completions endpoint.
// It follows the standard OpenAI chat format.
type groqRequest struct {
	Model    string        `json:"model"`
	Messages []groqMessage `json:"messages"`
}

type groqMessage struct {
	Role    string `json:"role"`    // "system" or "user"
	Content string `json:"content"` // the actual text
}

// groqResponse mirrors the Groq API response envelope.
type groqResponse struct {
	Choices []struct {
		Message struct {
			Content string `json:"content"`
		} `json:"message"`
	} `json:"choices"`
}

// Analyze implements the Analyzer interface.
func (g *GroqAnalyzer) Analyze(text string) (models.AnalysisResult, error) {
	// Build the request with a system prompt + user message.
	reqBody := groqRequest{
		Model: groqModel,
		Messages: []groqMessage{
			{
				Role: "system",
				Content: `You are a content moderation AI. 
Always respond ONLY with a valid JSON object — no markdown, no explanation, no extra text.
The JSON must have exactly these fields:
{
  "toxicity": "<low|medium|high>",
  "spam": <true|false>,
  "trust_score": <float between 0.0 and 1.0>,
  "summary": "<one or two sentences explaining your classification>"
}
Definitions:
- toxicity: "low" = civil, "medium" = mildly offensive, "high" = hateful or threatening.
- spam: true if unsolicited advertising, phishing, or repetitive junk.
- trust_score: 1.0 = fully trustworthy, 0.0 = completely untrustworthy.
- summary: brief justification for your scores.`,
			},
			{
				Role:    "user",
				Content: fmt.Sprintf("Analyze this text:\n\"\"\"\n%s\n\"\"\"", text),
			},
		},
	}

	// Marshal to JSON.
	bodyBytes, err := json.Marshal(reqBody)
	if err != nil {
		return models.AnalysisResult{}, fmt.Errorf("failed to marshal request: %w", err)
	}

	// Create the HTTP POST request.
	req, err := http.NewRequest(http.MethodPost, groqAPIURL, bytes.NewBuffer(bodyBytes))
	if err != nil {
		return models.AnalysisResult{}, fmt.Errorf("failed to create request: %w", err)
	}

	// Groq uses Bearer token authentication in the Authorization header.
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+g.APIKey)

	// Execute the request.
	resp, err := g.HTTPClient.Do(req)
	if err != nil {
		return models.AnalysisResult{}, fmt.Errorf("Groq API call failed: %w", err)
	}
	defer resp.Body.Close()

	// Read the response body.
	respBytes, err := io.ReadAll(resp.Body)
	if err != nil {
		return models.AnalysisResult{}, fmt.Errorf("failed to read response: %w", err)
	}

	// Check for non-200 status.
	if resp.StatusCode != http.StatusOK {
		return models.AnalysisResult{}, fmt.Errorf(
			"Groq API returned status %d: %s", resp.StatusCode, string(respBytes),
		)
	}

	// Decode the Groq response envelope.
	var groqResp groqResponse
	if err := json.Unmarshal(respBytes, &groqResp); err != nil {
		return models.AnalysisResult{}, fmt.Errorf("failed to decode response: %w", err)
	}

	// Guard against empty choices.
	if len(groqResp.Choices) == 0 {
		return models.AnalysisResult{}, fmt.Errorf("Groq returned no choices")
	}

	// Extract the raw text and parse it into AnalysisResult.
	rawText := groqResp.Choices[0].Message.Content
	return utils.ParseAnalysisResult(rawText)
}
