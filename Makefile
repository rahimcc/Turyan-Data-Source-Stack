.PHONY: init up down ps logs erp-db-name clean

ENV_FILE := .env.dev
PROFILE := 


init:            ## create shared network and .env
	@docker network inspect data-platform >/dev/null 2>&1 || docker network create data-platform
	@test -f .env || (cp .env.example .env && echo "Created .env - edit the passwords before 'make up'")

up:              ## start the stack
	docker compose --env-file $(ENV_FILE) --profile $(PROFILE) up -d

down:            ## stop the stack (keeps data)
	docker compose --env-file $(ENV_FILE) --profile $(PROFILE) down


ps:
	docker compose --env-file $(ENV_FILE) --profile $(PROFILE) ps

logs:            ## usage: make logs s=twenty-server
	docker compose --env-file $(ENV_FILE) --profile $(PROFILE) logs -f $(s)

erp-db-name:     ## show ERPNext's database name (needed for Airbyte/Debezium)
	@docker compose --env-file $(ENV_FILE) --profile $(PROFILE) exec erpnext-backend cat sites/frontend/site_config.json | grep db_name

clean:           ## stop AND delete all data
	docker compose --env-file $(ENV_FILE) --profile $(PROFILE) down -v
