# ──────────────────────────────────────────────────────────────────────────────
#  TrustGuard — Makefile
#  Run `make help` to see all available commands.
# ──────────────────────────────────────────────────────────────────────────────

# Binary name — the compiled output will be called "trustguard"
BINARY_NAME := trustguard

# Go command — can be overridden: make run GO=go1.21
GO := go

# ── Default target ────────────────────────────────────────────────────────────
.DEFAULT_GOAL := help

.PHONY: help
help:  ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

# ── Dependencies ──────────────────────────────────────────────────────────────
.PHONY: deps
deps:  ## Download and tidy Go module dependencies
	$(GO) mod download
	$(GO) mod tidy

# ── Build ─────────────────────────────────────────────────────────────────────
.PHONY: build
build:  ## Compile the binary to ./trustguard
	$(GO) build -o $(BINARY_NAME) .
	@echo "✅ Build complete: ./$(BINARY_NAME)"

# ── Run ───────────────────────────────────────────────────────────────────────
.PHONY: run
run:  ## Run the server directly (no compilation step)
	$(GO) run main.go

# ── Test ──────────────────────────────────────────────────────────────────────
.PHONY: test
test:  ## Run all unit tests with verbose output
	$(GO) test ./... -v

.PHONY: test-cover
test-cover:  ## Run tests and show coverage percentage
	$(GO) test ./... -coverprofile=coverage.out
	$(GO) tool cover -func=coverage.out
	@echo ""
	@echo "To view an HTML coverage report: make cover-html"

.PHONY: cover-html
cover-html: test-cover  ## Open HTML test coverage report in browser
	$(GO) tool cover -html=coverage.out

# ── Lint & Vet ────────────────────────────────────────────────────────────────
.PHONY: vet
vet:  ## Run go vet to catch common mistakes
	$(GO) vet ./...

.PHONY: lint
lint:  ## Run golangci-lint (must be installed: brew install golangci-lint)
	golangci-lint run ./...

# ── Clean ─────────────────────────────────────────────────────────────────────
.PHONY: clean
clean:  ## Remove the compiled binary and coverage files
	rm -f $(BINARY_NAME) coverage.out
	@echo "🧹 Cleaned"

# ── Production build ──────────────────────────────────────────────────────────
.PHONY: build-prod
build-prod:  ## Build a statically linked binary suitable for Docker/Linux
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
		$(GO) build -ldflags="-w -s" -o $(BINARY_NAME)-linux .
	@echo "✅ Production binary: ./$(BINARY_NAME)-linux"

# ── Docker helpers ────────────────────────────────────────────────────────────
.PHONY: docker-build
docker-build:  ## Build the Docker image tagged as trustguard:latest
	docker build -t trustguard:latest .

.PHONY: docker-run
docker-run:  ## Run the Docker container (requires .env file)
	docker run --env-file .env -p 8080:8080 trustguard:latest
