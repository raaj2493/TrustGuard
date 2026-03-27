package services

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
)

func AnalysewithGemini(text string)(map[string]interface{} , error){
   
	apiKey := os.Getenv("GEMINI_API_KEY")

	url := fmt.Sprintf(
		"https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=%s",
		apiKey,
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
`
+ text:

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

	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)

	return result, nil
}
