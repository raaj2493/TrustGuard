package services

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestScrapeURL_InvalidURL(t *testing.T) {
	tests := []struct {
		name    string
		url     string
		wantErr bool
	}{
		{"empty url", "", true},
		{"ftp scheme", "ftp://example.com", true},
		{"relative path", "/test/page", true},
		{"invalid characters", "http:// invalid url", true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_, err := ScrapeURL(tt.url)
			if (err != nil) != tt.wantErr {
				t.Errorf("ScrapeURL(%q) error = %v, wantErr %v", tt.url, err, tt.wantErr)
			}
		})
	}
}

func TestScrapeURL_Success(t *testing.T) {
	// Mock HTTP server serving HTML article
	mockServer := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "text/html; charset=utf-8")
		html := `
<!DOCTYPE html>
<html>
<head>
    <title>NASA Discovers Water Ice on Distant Asteroid</title>
    <meta name="description" content="Astronomers confirm significant water ice deposits using advanced spectroscopy.">
</head>
<body>
    <header><nav><a href="/">Home</a></nav></header>
    <article>
        <h1>Asteroid Water Ice Discovery</h1>
        <p>In a groundbreaking observation published today, scientists confirmed extensive ice deposits.</p>
        <p>The findings could revolutionize our understanding of early planetary formation and deep space water distribution.</p>
    </article>
    <footer><p>Copyright 2026</p></footer>
</body>
</html>`
		w.WriteHeader(http.StatusOK)
		w.Write([]byte(html))
	}))
	defer mockServer.Close()

	result, err := ScrapeURL(mockServer.URL)
	if err != nil {
		t.Fatalf("unexpected error scraping mock server: %v", err)
	}

	if result.Title != "NASA Discovers Water Ice on Distant Asteroid" {
		t.Errorf("got title %q, want %q", result.Title, "NASA Discovers Water Ice on Distant Asteroid")
	}

	if !strings.Contains(result.Content, "groundbreaking observation") {
		t.Errorf("expected content to contain 'groundbreaking observation', got: %s", result.Content)
	}

	if result.WordCount < 10 {
		t.Errorf("expected word count >= 10, got %d", result.WordCount)
	}
}

func TestScrapeURL_NonHTML(t *testing.T) {
	mockServer := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		w.Write([]byte(`{"status": "ok"}`))
	}))
	defer mockServer.Close()

	_, err := ScrapeURL(mockServer.URL)
	if err == nil {
		t.Fatal("expected error when scraping non-HTML content, got nil")
	}
}
