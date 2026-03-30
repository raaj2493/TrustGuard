# 🛡️ TrustGuard --- AI-Powered Content Safety & Trust Analysis API

> 🤖 Analyze user-generated content in real-time for toxicity, spam, and
> trustworthiness using AI.

------------------------------------------------------------------------

## 🚀 Overview

TrustGuard is a high-performance backend API built with ⚡ Go (Golang)
that leverages AI to evaluate the safety and reliability of text.

It helps developers build 🔐 secure and trustworthy platforms by
detecting:

-   🚫 Toxic content\
-   📩 Spam messages\
-   ⚠️ Harmful or suspicious text\
-   🔍 Trustworthiness score

Perfect for 💬 chat apps, 🌐 social media platforms, 📝 review systems,
and more.

------------------------------------------------------------------------

## ✨ Features

-   ⚡ Fast and lightweight REST API (Go + Gin)
-   🧠 AI-powered text analysis
-   🚫 Toxicity detection
-   📩 Spam classification
-   🔍 Trust scoring system
-   📊 Clean JSON responses
-   🔐 Secure `.env` configuration
-   🧩 Scalable project architecture
-   🔄 Easy frontend integration

------------------------------------------------------------------------

## 🏗️ Tech Stack

  Layer        Technology
  ------------ ------------------------
  Backend      Go (Golang)
  Framework    Gin
  AI Service   Google Gemini API
  Config       godotenv (.env)
  Testing      Thunder Client/Postman

------------------------------------------------------------------------

## 📁 Project Structure

TrustGuard/ ├── backend/ │ ├── controllers/ │ ├── routes/ │ ├──
services/ │ ├── config/ │ ├── models/ │ ├── utils/ │ ├── main.go │ └──
go.mod ├── frontend/ ├── .env └── README.md

------------------------------------------------------------------------

## ⚙️ Prerequisites

-   🐹 Go (v1.20+)
-   🔑 Gemini API Key
-   📦 Git

------------------------------------------------------------------------

## 🔑 Environment Setup

Create a `.env` file:

GEMINI_API_KEY=your_api_key_here\
PORT=8080

------------------------------------------------------------------------

## 🚀 Installation

git clone https://github.com/raajgiri/TrustGuard.git\
cd trustguard/backend\
go mod tidy\
go run main.go

------------------------------------------------------------------------

## 📡 API

POST /analyze

Request: { "text": "Hello world" }

Response: { "status": "success", "analysis": { "toxicity": "low",
"spam": false, "trust_score": 0.87 } }

------------------------------------------------------------------------

## ⭐ Support

Give a ⭐ if you like the project!

------------------------------------------------------------------------

## 📜 License

MIT License
