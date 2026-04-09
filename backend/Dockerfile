# ──────────────────────────────────────────────────────────────────────────────
#  TrustGuard — Multi-stage Dockerfile
#
#  Stage 1 (builder): compiles the Go binary in a full Go environment.
#  Stage 2 (runner):  copies only the binary into a tiny distroless image.
#
#  The final image is ~10 MB with no shell, no package manager, and no
#  unnecessary attack surface. Perfect for production deployments.
# ──────────────────────────────────────────────────────────────────────────────

# ── Stage 1: Build ────────────────────────────────────────────────────────────
FROM golang:1.21-alpine AS builder

# Install git (needed by go mod download for some indirect deps).
RUN apk add --no-cache git

# Set the working directory inside the container.
WORKDIR /app

# Copy dependency files first so Docker can cache the download layer.
# If go.mod/go.sum don't change, Docker won't re-download dependencies.
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the source code.
COPY . .

# Build a statically linked binary.
# -w -s strips debug info to reduce binary size.
# CGO_ENABLED=0 ensures no C library dependencies.
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o trustguard .

# ── Stage 2: Run ──────────────────────────────────────────────────────────────
# gcr.io/distroless/static contains only the absolute minimum to run
# a statically linked binary — no shell, no libc, no package manager.
FROM gcr.io/distroless/static:nonroot

WORKDIR /app

# Copy only the compiled binary from the builder stage.
COPY --from=builder /app/trustguard .

# Expose the port the application listens on.
EXPOSE 8080

# Run as a non-root user (uid 65532 = "nonroot" in distroless).
USER nonroot:nonroot

# Start the server.
# Environment variables (GEMINI_API_KEY, PORT) must be injected at runtime
# via --env-file or -e flags — never bake secrets into the image.
ENTRYPOINT ["/app/trustguard"]
