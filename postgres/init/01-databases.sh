#!/bin/bash
# First start only: creates Twenty's database and the shop schema,
# plus platform users for CDC (debezium) and batch (airbyte_reader).
set -euo pipefail

psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d postgres <<-SQL
  CREATE DATABASE twenty;
  CREATE ROLE debezium WITH LOGIN REPLICATION PASSWORD '${DEBEZIUM_PASSWORD}';
  CREATE ROLE airbyte_reader WITH LOGIN PASSWORD '${AIRBYTE_READER_PASSWORD}';
  GRANT CONNECT ON DATABASE shop, twenty TO debezium, airbyte_reader;
SQL

psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d shop <<-SQL
  CREATE SCHEMA shop;
  CREATE TABLE shop.customers (
    id BIGSERIAL PRIMARY KEY,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    country TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
  );
  CREATE TABLE shop.products (
    id BIGSERIAL PRIMARY KEY,
    sku TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
  );
  CREATE TABLE shop.orders (
    id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT NOT NULL REFERENCES shop.customers(id),
    status TEXT NOT NULL DEFAULT 'pending',
    total_amount NUMERIC(12,2) NOT NULL DEFAULT 0,
    ordered_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
  );

  GRANT USAGE ON SCHEMA shop TO debezium, airbyte_reader;
  GRANT SELECT ON ALL TABLES IN SCHEMA shop TO debezium, airbyte_reader;
  ALTER DEFAULT PRIVILEGES IN SCHEMA shop GRANT SELECT ON TABLES TO debezium, airbyte_reader;
  CREATE PUBLICATION dbz_shop FOR TABLES IN SCHEMA shop;
SQL
