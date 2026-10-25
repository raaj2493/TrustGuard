package services

import (
	"errors"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strings"
	"time"

	"golang.org/x/net/html"
)

type ScrapeResult struct {
	URL         string `json:"url"`
	Title       string `json:"title"`
	Description string `json:"description"`
	Content     string `json:"content"`
	WordCount   int    `json:"word_count"`
}

// ScrapeURL fetches a web page and extracts its title, meta description, and article body text.
func ScrapeURL(targetURL string) (*ScrapeResult, error) {
	parsedURL, err := url.ParseRequestURI(strings.TrimSpace(targetURL))
	if err != nil || (parsedURL.Scheme != "http" && parsedURL.Scheme != "https") {
		return nil, errors.New("invalid URL: must start with http:// or https://")
	}

	client := &http.Client{
		Timeout: 12 * time.Second,
	}

	req, err := http.NewRequest("GET", parsedURL.String(), nil)
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %w", err)
	}

	// Set browser user-agent to avoid automated-bot 403 blocks on news sites
	req.Header.Set("User-Agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36")
	req.Header.Set("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8")
	req.Header.Set("Accept-Language", "en-US,en;q=0.9")

	resp, err := client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("failed to fetch URL: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode >= 400 {
		return nil, fmt.Errorf("received HTTP status %d from %s", resp.StatusCode, parsedURL.Host)
	}

	contentType := resp.Header.Get("Content-Type")
	if !strings.Contains(strings.ToLower(contentType), "text/html") &&
		!strings.Contains(strings.ToLower(contentType), "application/xhtml+xml") {
		return nil, fmt.Errorf("URL does not point to an HTML web page (Content-Type: %s)", contentType)
	}

	// Limit reader to 5MB to prevent memory exhaustion
	limitReader := io.LimitReader(resp.Body, 5*1024*1024)
	doc, err := html.Parse(limitReader)
	if err != nil {
		return nil, fmt.Errorf("failed to parse HTML: %w", err)
	}

	result := &ScrapeResult{
		URL: parsedURL.String(),
	}

	var textParts []string
	var walk func(*html.Node)
	walk = func(n *html.Node) {
		if n.Type == html.ElementNode {
			tag := strings.ToLower(n.Data)

			// Skip non-content elements
			if tag == "script" || tag == "style" || tag == "noscript" ||
				tag == "nav" || tag == "footer" || tag == "header" ||
				tag == "svg" || tag == "iframe" || tag == "form" {
				return
			}

			// Extract title
			if tag == "title" && result.Title == "" && n.FirstChild != nil {
				result.Title = strings.TrimSpace(n.FirstChild.Data)
			}

			// Extract meta description or og:description
			if tag == "meta" && result.Description == "" {
				var name, property, content string
				for _, attr := range n.Attr {
					switch strings.ToLower(attr.Key) {
					case "name":
						name = strings.ToLower(attr.Val)
					case "property":
						property = strings.ToLower(attr.Val)
					case "content":
						content = strings.TrimSpace(attr.Val)
					}
				}
				if (name == "description" || property == "og:description") && content != "" {
					result.Description = content
				}
			}

			// Extract readable content from article, paragraph, and heading tags
			if tag == "p" || tag == "h1" || tag == "h2" || tag == "h3" || tag == "h4" || tag == "li" || tag == "blockquote" {
				extracted := strings.TrimSpace(extractText(n))
				if len(extracted) > 25 { // filter out tiny button texts/snippets
					textParts = append(textParts, extracted)
				}
				return
			}
		}

		for c := n.FirstChild; c != nil; c = c.NextSibling {
			walk(c)
		}
	}

	walk(doc)

	combinedText := strings.Join(textParts, "\n\n")
	combinedText = strings.TrimSpace(combinedText)

	// If no <p> tags were found, fallback to body text
	if len(combinedText) < 50 && result.Description != "" {
		combinedText = result.Description
	}

	if len(combinedText) < 40 {
		return nil, errors.New("could not extract enough readable text from the page (it may be behind a paywall, require login, or render via client-side JavaScript)")
	}

	// Limit to ~5,000 characters for optimal LLM processing
	if len(combinedText) > 5000 {
		combinedText = combinedText[:5000] + "\n\n[...content truncated for analysis...]"
	}

	result.Content = combinedText
	words := strings.Fields(combinedText)
	result.WordCount = len(words)

	return result, nil
}

func extractText(n *html.Node) string {
	if n.Type == html.TextNode {
		return n.Data
	}
	var sb strings.Builder
	for c := n.FirstChild; c != nil; c = c.NextSibling {
		if c.Type == html.ElementNode {
			tag := strings.ToLower(c.Data)
			if tag == "script" || tag == "style" {
				continue
			}
		}
		sb.WriteString(extractText(c))
		sb.WriteString(" ")
	}
	return sb.String()
}
