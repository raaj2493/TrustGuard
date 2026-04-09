// Package mock provides test doubles (fakes/mocks) for the services package.
// Using mocks means our controller and route tests never hit the real Gemini API,
// making them fast, free, and deterministic.
package mock

import (
	"trustguard/models"
)

// MockAnalyzer is a test double that implements services.Analyzer.
// Tests can configure it to return a fixed result or a fixed error.
type MockAnalyzer struct {
	// Result is returned by Analyze() when Err is nil.
	Result models.AnalysisResult

	// Err is returned by Analyze() when non-nil (simulates AI failure).
	Err error

	// CallCount records how many times Analyze() was called.
	// Useful for asserting the handler only calls the service once.
	CallCount int

	// LastText records the most-recent text argument passed to Analyze().
	// Useful for asserting the controller passed the right input.
	LastText string
}

// Analyze satisfies the services.Analyzer interface.
// It stores the call for later inspection and returns the pre-configured response.
func (m *MockAnalyzer) Analyze(text string) (models.AnalysisResult, error) {
	m.CallCount++
	m.LastText = text
	return m.Result, m.Err
}
