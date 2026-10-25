package services

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"strings"
)

type Metrics struct {
	TrustScore int `json:"trust_score"`
	Toxicity   int `json:"toxicity"`
	Spam       int `json:"spam"`
	Clickbait  int `json:"clickbait"`
}

type FlaggedSentence struct {
	Sentence string `json:"sentence"`
	Category string `json:"category"` // "unverified", "toxic", "clickbait", "sensational"
	Reason   string `json:"reason"`
}

type SourceCitation struct {
	Title string `json:"title"`
	URL   string `json:"url"`
}

type AIResponse struct {
	Prediction       string            `json:"prediction"`
	Confidence       int               `json:"confidence"`
	Reason           string            `json:"reason"`
	Metrics          Metrics           `json:"metrics"`
	FlaggedSentences []FlaggedSentence `json:"flagged_sentences"`
	Sources          []SourceCitation  `json:"sources"`
	SearchQueries    []string          `json:"search_queries"`
	ScrapedTitle     string            `json:"scraped_title,omitempty"`
	ScrapedURL       string            `json:"scraped_url,omitempty"`
}

func AnalyzeWithGemini(text string) (*AIResponse, error) {

	apiKey := os.Getenv("GEMINI_API_KEY")

	url := fmt.Sprintf(
		"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=%s",
		apiKey,
	)

	prompt := `
You are an advanced AI misinformation and content safety detector with live web grounding.
Use Google Search to fact-check any claims against credible news, scientific consensus, or primary sources.

Analyze the following text and return a JSON object with:
1. "prediction": Choose the single most accurate category from:
   - "Verified / Real" (factually accurate and trustworthy)
   - "Common Myth / Misconception" (harmless factual inaccuracy, urban legend, or popular misconception)
   - "Fake News / Misinformation" (misleading or false news article)
   - "Dangerous Scam" (phishing, malicious scam, or dangerous health/security threat)
2. "confidence": confidence score (0-100)
3. "reason": short overall summary of the analysis explaining why the text is or is not trustworthy
4. "metrics": object containing:
   - "trust_score": integer score 0-100 (100 = completely trustworthy, ~30-40 = myth/misconception, 0 = severe scam)
   - "toxicity": integer score 0-100 (100 = highly toxic/harmful)
   - "spam": integer score 0-100 (100 = definite spam)
   - "clickbait": integer score 0-100 (100 = highly exaggerated/clickbait)
5. "flagged_sentences": array of objects for suspicious or problematic sentences in the text:
   - "sentence": exact substring of sentence from the text
   - "category": one of ["unverified", "toxic", "clickbait", "sensational"]
   - "reason": concise explanation why this sentence was flagged

Return ONLY raw valid JSON (no markdown formatting, no text before or after):

{
  "prediction": "Fake News / Misinformation",
  "confidence": 85,
  "reason": "Contains unverified claims and clickbait wording.",
  "metrics": {
    "trust_score": 25,
    "toxicity": 10,
    "spam": 15,
    "clickbait": 75
  },
  "flagged_sentences": [
    {
      "sentence": "exact sentence here",
      "category": "clickbait",
      "reason": "Exaggerated headline wording"
    }
  ]
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
		"tools": []map[string]interface{}{
			{
				"google_search": map[string]interface{}{},
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

	firstCandidate, ok := candidates[0].(map[string]interface{})
	if !ok {
		return nil, fmt.Errorf("invalid candidate structure")
	}

	content, ok := firstCandidate["content"].(map[string]interface{})
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

	// Initialize slices to empty rather than nil for clean JSON responses
	if aiResp.FlaggedSentences == nil {
		aiResp.FlaggedSentences = []FlaggedSentence{}
	}
	aiResp.Sources = []SourceCitation{}
	aiResp.SearchQueries = []string{}

	// Step 4: Extract Google Search Grounding Metadata & Citations
	if groundingMeta, ok := firstCandidate["groundingMetadata"].(map[string]interface{}); ok {
		// Extract live web search queries
		if queriesRaw, ok := groundingMeta["webSearchQueries"].([]interface{}); ok {
			for _, q := range queriesRaw {
				if qStr, ok := q.(string); ok && qStr != "" {
					aiResp.SearchQueries = append(aiResp.SearchQueries, qStr)
				}
			}
		}

		// Extract authoritative sources cited
		if chunksRaw, ok := groundingMeta["groundingChunks"].([]interface{}); ok {
			seenURLs := make(map[string]bool)
			for _, chunk := range chunksRaw {
				if chunkMap, ok := chunk.(map[string]interface{}); ok {
					if webMap, ok := chunkMap["web"].(map[string]interface{}); ok {
						uri, _ := webMap["uri"].(string)
						title, _ := webMap["title"].(string)
						if uri != "" && !seenURLs[uri] {
							seenURLs[uri] = true
							if title == "" {
								title = uri
							}
							aiResp.Sources = append(aiResp.Sources, SourceCitation{
								Title: title,
								URL:   uri,
							})
						}
					}
				}
			}
		}
	}

	return &aiResp, nil
}