#!/bin/bash

docker-compose exec -T db psql -U happy_twitter -d template1 -c "DROP DATABASE IF EXISTS happy_twitter;"
docker-compose exec -T db psql -U happy_twitter -d template1 -c "CREATE DATABASE happy_twitter;"

docker-compose exec -T db psql -U happy_twitter -d happy_twitter -f /docker-entrypoint-initdb.d/schema.sql
