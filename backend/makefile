PACKAGED_TEMPLATE = packaged.yaml
PORT = 9000

.PHONY: fmt-go
fmt-go:
	@go fmt ./...

.PHONY: install-go
install-go:
	go mod vendor

.PHONY: build-go
build-go: install-go
	GOARCH=amd64 CGO_ENABLED=0 GOOS=linux go build -o ./bin/ ./cmd/...

.PHONY: clean
clean:
	rm -f $(OUTPUT) $(PACKAGED_TEMPLATE)

.PHONY: build
build: clean fmt-go build-go

.PHONY: run
run: build
	sam local start-api -p $(PORT)