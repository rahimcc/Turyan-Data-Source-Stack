.PHONY: init up down ps logs erp-db-name clean

init:            ## create shared network and .env
	@docker network inspect data-platform >/dev/null 2>&1 || docker network create data-platform
	@test -f .env || (cp .env.example .env && echo "Created .env - edit the passwords before 'make up'")

up:              ## start the stack
	docker compose up -d

down:            ## stop the stack (keeps data)
	docker compose down

ps:
	docker compose ps

logs:            ## usage: make logs s=twenty-server
	docker compose logs -f $(s)

erp-db-name:     ## show ERPNext's database name (needed for Airbyte/Debezium)
	@docker compose exec erpnext-backend cat sites/frontend/site_config.json | grep db_name

clean:           ## stop AND delete all data
	docker compose down -v
