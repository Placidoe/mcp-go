#!/usr/bin/env bash
# Run in the mcp-go checkout at the patch commit from manifest.json.
# Go 1.25.5 or later is required. No model provider or credentials needed.
set -euo pipefail
go test ./mcp ./client ./server -run 'Test(ListToolsSchemaTypeArray|SchemaTypeArray)' -count=1 -v
go test ./... -race -count=1
go vet ./...
go build ./...
go generate ./...
test -z "$(git status --porcelain)"
go run github.com/golangci/golangci-lint/v2/cmd/golangci-lint@v2.8.0 run
(
  cd otel
  go test ./... -race -count=1
  go vet ./...
  go run github.com/golangci/golangci-lint/v2/cmd/golangci-lint@v2.8.0 run
)
python3 -m unittest discover -s scripts -p 'test_*.py'
# For conformance, separately start:
# CONFORMANCE_ADDR=127.0.0.1:33175 go run ./examples/conformance
# Then run:
# python3 scripts/check_conformance.py --url http://127.0.0.1:33175/mcp --baseline conformance/server/expected-failures.yml
