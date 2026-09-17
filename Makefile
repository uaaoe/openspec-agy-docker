# -----------------------------------------------------------------------------
# Antigravity & OpenSpec Containerized Environment Makefile
# -----------------------------------------------------------------------------

SHELL := /bin/bash
UID ?= $(shell id -u)
GID ?= $(shell id -g)
COMPOSE := UID=$(UID) GID=$(GID) docker compose -f docker-compose.yaml

.PHONY: help install new-project build agy agy-cmd openspec validate shell clean

help: ## Display available targets
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-18s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: ## Install create-agy-project CLI tool into ~/.local/bin
	@chmod +x install.sh bin/create-agy-project
	@./install.sh

new-project: ## Scaffold a new project (Usage: make new-project DIR=../my-agent-project)
	@if [ -z "$(DIR)" ]; then \
		echo "Error: Please specify DIR (e.g. make new-project DIR=../my-project)"; \
		exit 1; \
	fi
	@chmod +x bin/create-agy-project
	@./bin/create-agy-project "$(DIR)"

build: ## Build the sandboxed container image
	$(COMPOSE) build

agy: ## Launch interactive Antigravity CLI session in the sandbox
	$(COMPOSE) run --rm agy

agy-cmd: ## Run a single prompt headlessly (Usage: make agy-cmd PROMPT="...")
	@if [ -z "$(PROMPT)" ]; then \
		echo "Error: Please specify PROMPT (e.g. make agy-cmd PROMPT=\"review code\")"; \
		exit 1; \
	fi
	$(COMPOSE) run --rm agy -p "$(PROMPT)"

openspec: ## Run OpenSpec commands inside container (Usage: make openspec ARGS="...")
	$(COMPOSE) run --rm agy openspec $(ARGS)

validate: ## Validate OpenSpec specifications and changes
	$(COMPOSE) run --rm agy openspec validate --all --no-interactive

shell: ## Open an interactive bash shell inside the container sandbox
	$(COMPOSE) run --rm agy bash

clean: ## Remove dangling sandbox docker images and stopped containers
	$(COMPOSE) down --remove-orphans
