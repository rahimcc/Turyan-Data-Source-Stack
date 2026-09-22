# Source stack

| Service    | URL / Port                     | Login                                  |
|------------|--------------------------------|----------------------------------------|
| Twenty CRM | http://localhost:3001          | create workspace on first visit        |
| ERPNext    | http://localhost:8082          | Administrator / `ERPNEXT_ADMIN_PASSWORD` |
| PostgreSQL | localhost:5433 (`shop`, `twenty`) | `POSTGRES_USER` / `POSTGRES_PASSWORD` |
| MariaDB    | localhost:3307 (ERPNext)       | root / `ERPNEXT_DB_ROOT_PASSWORD`      |

## Start
    make init      # network + .env  -> edit passwords in .env
    make up        # first start takes a few minutes (ERPNext creates its site)
    make logs s=erpnext-create-site   # watch until it finishes

## Platform users (created automatically, same on every DB)
- `debezium`: CDC. Postgres publication `dbz_shop`; MariaDB binlog in ROW mode.
- `airbyte_reader`: read-only for batch extraction.

Other stacks connect by container name on the `data-platform` network:
`postgres:5432` and `erpnext-db:3306`. Run `make erp-db-name` to get ERPNext's database name.
