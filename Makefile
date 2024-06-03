.SILENT:

docker_compose_file := docker-compose.yml
db_volume := rails_modular_monolith_db_data3
ollama_volume := rails_modular_monolith_ollama

help:
	grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-11s\033[0m %s\033[0m\n", $$1, $$2}'


### DOCKER

up: ## Start container services
	@echo "\n\033[93m--> Starting containers and services....\033[0m\n"
	docker compose -f $(docker_compose_file) up -d

down: ## Stop container services
	@echo "\n\033[93m--> Stopping containers and services....\033[0m\n"
	docker compose down

build: ## Rebuild container services with no cache
	@echo "\n\033[93m--> Building containers and services....\033[0m\n"
	docker compose -f $(docker_compose_file) build

rebuild: ## Rebuild & start container services with no cache
	make down || true
	make clearvolumes || true
	@echo "\n\033[93m--> Building containers and services with no cache....\033[0m\n"
	docker compose -f $(docker_compose_file) build --no-cache
	make up || true

clearvolumes: ## Clear volumes (requires containers to not be using the volume)
	@echo "\n\033[93m--> Clearing volumes....\033[0m\n"
	docker volume rm $(db_volume) || true
	docker volume rm $(ollama_volume) || true