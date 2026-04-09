// Package config handles all environment variable loading and application configuration.
// It uses the godotenv library to read from a .env file so sensitive keys
// like API credentials are never hard-coded in source code.
package config

import (
	"log"
	"os"

	"github.com/joho/godotenv"
)

// Config holds all configuration values loaded from the environment.
type Config struct {
	GroqAPIKey string // Your Groq API key
	Port       string // The port the HTTP server will listen on
}

// Load reads the .env file and returns a populated Config struct.
func Load() *Config {
	if err := godotenv.Load(); err != nil {
		log.Println("Warning: .env file not found, reading from system environment")
	}

	cfg := &Config{
		GroqAPIKey: os.Getenv("GROQ_API_KEY"),
		Port:       os.Getenv("PORT"),
	}

	if cfg.GroqAPIKey == "" {
		log.Fatal("FATAL: GROQ_API_KEY is not set. Please add it to your .env file.")
	}

	if cfg.Port == "" {
		cfg.Port = "8080"
	}

	return cfg
}
