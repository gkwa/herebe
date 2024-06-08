BIN := herebe

GOVERSION := $(shell go version)
GOPATH := $(shell go env GOPATH)

export GOVERSION

ifeq ($(OS),Windows_NT)
    GO_FILES := $(shell dir /S /B *.go)
    GO_DEPS := $(shell dir /S /B go.mod go.sum)
    CLEAN := del
    GOOS = windows
    GOARCH = amd64
    EXEEXT = .exe
else ifeq ($(shell uname),Linux)
    GOOS = linux
    GOARCH = amd64
    EXEEXT =
else ifeq ($(shell uname),Darwin)
    GOOS = darwin
    GOARCH = amd64
    EXEEXT =
else
    GO_FILES := $(shell find . -name '*.go')
    GO_DEPS := $(shell find . -name go.mod -o -name go.sum)
    CLEAN := rm -f
endif

APP := herebe$(EXEEXT)
TARGET := ./dist/herebe_$(GOOS)_$(GOARCH)_v1/$(APP)

$(APP): $(TARGET)
	cp $< $@

$(BIN): $(GO_FILES) $(GO_DEPS)
	go mod tidy
	gofumpt -w $(GO_FILES)
	golangci-lint run
	go build -o $(BIN) main.go


$(TARGET): $(SOURCES)
	gofumpt -w $(SOURCES)
	goreleaser build --single-target --snapshot --clean
	go vet ./...

all:
	goreleaser build --snapshot --clean

.PHONY: clean
clean:
	rm -f herebe
	rm -f $(TARGET)
	rm -rf dist
