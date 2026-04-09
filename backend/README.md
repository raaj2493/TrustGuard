# TrustGuard — AI-Powered Content Moderation API

TrustGuard is a production-ready Go backend that analyzes user-generated text for **toxicity**, **spam**, and **trustworthiness** using the Google Gemini AI API.

---

## 📁 Project Structure

```
backend/
├── config/
│   └── config.go               # Loads .env variables into a Config struct
├── controllers/
│   └── analyze_controller.go   # HTTP handler for POST /analyze
├── models/
│   └── models.go               # All request/response/Gemini data structs
├── routes/
│   └── routes.go               # Registers URL paths on the Gin engine
├── services/
│   ├── analyzer.go             # Analyzer interface (the extension point)
│   ├── gemini_analyzer.go      # Concrete Gemini implementation
│   └── huggingface_analyzer.go # Stub for future HuggingFace implementation
├── utils/
│   └── parser.go               # Parses AI text response → AnalysisResult
├── main.go                     # Wires dependencies and starts the server
├── go.mod                      # Go module definition
├── .env.example                # Template — copy to .env and fill in keys
└── .gitignore
```

---

## ⚙️ Setup

### 1. Prerequisites

- Go 1.21+ installed → https://go.dev/dl/
- A Google Gemini API key (free) → https://aistudio.google.com/app/apikey

### 2. Clone / Download

```bash
cd backend/   # navigate into the backend folder
```

### 3. Configure Environment

```bash
cp .env.example .env
```

Open `.env` and fill in your key:

```env
GEMINI_API_KEY=AIza...your_key_here
PORT=8080
```

### 4. Install Dependencies

```bash
go mod tidy
```

This downloads Gin and godotenv into your module cache.

### 5. Run the Server

```bash
go run main.go
```

You should see:

```
TrustGuard starting on port 8080
[GIN-debug] POST   /analyze
[GIN-debug] GET    /health
[GIN-debug] Listening and serving HTTP on :8080
```

---

## 🧪 Testing the API

### Health Check

```bash
curl http://localhost:8080/health
```

Expected response:
```json
{ "status": "ok", "service": "TrustGuard" }
```

---

### Analyze Text — Postman / Thunder Client

**Method:** `POST`  
**URL:** `http://localhost:8080/analyze`  
**Headers:** `Content-Type: application/json`  
**Body (raw JSON):**

```json
{
  "text": "You are absolutely worthless and should disappear."
}
```

**Expected Response:**

```json
{
  "status": "success",
  "analysis": {
    "toxicity": "high",
    "spam": false,
    "trust_score": 0.1,
    "summary": "The text contains direct personal attacks and is highly toxic."
  }
}
```

---

### Test with curl

```bash
# Toxic text
curl -X POST http://localhost:8080/analyze \
  -H "Content-Type: application/json" \
  -d '{"text": "I hate you, you are disgusting!"}'

# Spam text
curl -X POST http://localhost:8080/analyze \
  -H "Content-Type: application/json" \
  -d '{"text": "CLICK HERE NOW! WIN $1000 FREE! Limited time offer!!!"}'

# Normal text
curl -X POST http://localhost:8080/analyze \
  -H "Content-Type: application/json" \
  -d '{"text": "The quarterly report shows a 12% increase in revenue."}'

# Empty text (should return 400)
curl -X POST http://localhost:8080/analyze \
  -H "Content-Type: application/json" \
  -d '{"text": ""}'
```

---

## 🔌 Adding a New AI Provider

The service layer uses an interface so swapping providers is a one-line change.

1. Implement `services.Analyzer` in a new file (see `services/huggingface_analyzer.go` for the pattern).
2. In `main.go`, change:
   ```go
   var analyzer services.Analyzer = services.NewGeminiAnalyzer(cfg.GeminiAPIKey)
   ```
   to:
   ```go
   var analyzer services.Analyzer = services.NewHuggingFaceAnalyzer(cfg.HuggingFaceToken)
   ```
3. Done. Zero other files need to change.

---

## 📐 Architecture Overview

```
HTTP Request
     │
     ▼
 routes.go          — maps URL paths to handlers
     │
     ▼
 analyze_controller.go  — validates input, calls service, writes response
     │
     ▼
 services/Analyzer (interface)
     │
     ├──▶ GeminiAnalyzer     — calls Gemini REST API
     └──▶ HuggingFaceAnalyzer — (stub, ready to implement)
               │
               ▼
         utils/parser.go     — parses raw AI text → AnalysisResult
               │
               ▼
         models.AnalysisResult → JSON response to client
```

---

## 🔒 Security Notes

- Never commit your `.env` file. It is listed in `.gitignore`.
- In production, inject `GEMINI_API_KEY` via environment secrets (Docker, K8s, etc.).
- Rate-limit the `/analyze` endpoint with middleware before exposing publicly.
