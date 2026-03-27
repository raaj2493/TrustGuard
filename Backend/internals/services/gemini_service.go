package services

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
)

func AnalyzeWithGemini(text string) (map[string]interface{}, error) {

	apiKey := os.Getenv("GEMINI_API_KEY")

	// Correct URL
	url := fmt.Sprintf(
		"https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=%s",
		apiKey,
	)

	// Correct prompt
	prompt := `
You are an AI misinformation detector.

Analyze the following text and determine:

1. Is it Fake News or Real News?
2. Confidence score (0-100)
3. Reason

Return ONLY JSON in this format:

{
 "prediction": "Fake or Real",
 "confidence": number,
 "reason": "short explanation"
}

Text:
` + text

	// Request body
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

	// Create request
	req, _ := http.NewRequest("POST", url, bytes.NewBuffer(jsonData))
	req.Header.Set("Content-Type", "application/json")

	// Send request
	client := &http.Client{}
	resp, err := client.Do(req)

	if err != nil {
		return nil, err
	}

	defer resp.Body.Close()

	// Decode response
	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)

	return result, nil
}