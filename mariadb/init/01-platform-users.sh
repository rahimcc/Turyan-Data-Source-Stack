#!/bin/bash
# First start only: platform users for ERPNext's MariaDB.
# ERPNext names its database randomly, so read access is granted server-wide.
set -euo pipefail

mariadb -uroot -p"${MARIADB_ROOT_PASSWORD}" <<-SQL
  CREATE USER 'debezium'@'%' IDENTIFIED BY '${DEBEZIUM_PASSWORD}';
  GRANT SELECT, RELOAD, SHOW DATABASES, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'debezium'@'%';
  CREATE USER 'airbyte_reader'@'%' IDENTIFIED BY '${AIRBYTE_READER_PASSWORD}';
  GRANT SELECT, SHOW VIEW ON *.* TO 'airbyte_reader'@'%';
  FLUSH PRIVILEGES;
SQL
