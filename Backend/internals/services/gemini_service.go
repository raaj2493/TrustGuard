package services

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"strings"
)

type AIResponse struct {
	Prediction string `json:"prediction"`
	Confidence int    `json:"confidence"`
	Reason     string `json:"reason"`
}

func AnalyzeWithGemini(text string) (*AIResponse, error) {

	apiKey := os.Getenv("GEMINI_API_KEY")

	url := fmt.Sprintf(
		"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=%s",
		apiKey,
	)

	prompt := `
You are an AI misinformation detector.

Analyze the following text and determine:

1. Is it Fake News or Real News?
2. Confidence score (0-100)
3. Reason

Return ONLY JSON:

{
 "prediction": "Fake or Real",
 "confidence": number,
 "reason": "short explanation"
}

Text:
` + text

	requestBody := map[string]interface{}{
		"contents": []map[string]interface{}{
			{
				"parts": []map[string]string{
					{"text": prompt},
				},
			},
		},
	}

	jsonData, _ := json.Marshal(requestBody)

	req, _ := http.NewRequest("POST", url, bytes.NewBuffer(jsonData))
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	// Step 1: decode full response
	var raw map[string]interface{}
	err = json.NewDecoder(resp.Body).Decode(&raw)
	if err != nil {
		return nil, fmt.Errorf("failed to decode response: %v", err)
	}

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("API error: %v", raw)
	}

	// Step 2: extract text safely
	candidates, ok := raw["candidates"].([]interface{})
	if !ok || len(candidates) == 0 {
		return nil, fmt.Errorf("no candidates found in response")
	}

	content, ok := candidates[0].(map[string]interface{})["content"].(map[string]interface{})
	if !ok {
		return nil, fmt.Errorf("invalid content structure")
	}

	parts, ok := content["parts"].([]interface{})
	if !ok || len(parts) == 0 {
		return nil, fmt.Errorf("invalid parts structure")
	}

	textResponse, ok := parts[0].(map[string]interface{})["text"].(string)
	if !ok {
		return nil, fmt.Errorf("text response not found")
	}

	// Clean markdown JSON formatting if present
	textResponse = strings.TrimSpace(textResponse)
	textResponse = strings.TrimPrefix(textResponse, "```json")
	textResponse = strings.TrimPrefix(textResponse, "```")
	textResponse = strings.TrimSuffix(textResponse, "```")
	textResponse = strings.TrimSpace(textResponse)

	// Step 3: convert string JSON → struct
	var aiResp AIResponse
	err = json.Unmarshal([]byte(textResponse), &aiResp)
	if err != nil {
		return nil, fmt.Errorf("failed to parse AI JSON: %v, raw text: %s", err, textResponse)
	}

	return &aiResp, nil
}