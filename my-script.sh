#!/bin/bash

#quit on fail
#set -euo pipefail

#create
if [[ "$1" == "create" ]]; then
    #CREATE USER 'admin'@'localhost' IDENTIFIED BY 'my very strong password';

    docker exec mysql bash -c '
    mysql -u root -pexample -e "   
    CREATE DATABASE test; USE test;
    CREATE TABLE costs (id VARCHAR(20) PRIMARY KEY, name VARCHAR(20), price DECIMAL);
    CREATE TABLE products (id VARCHAR(20) PRIMARY KEY, name VARCHAR(20), status VARCHAR(20), quantity CHAR(1), priceId VARCHAR(20));"
    '

    docker exec -d postgres bash -c '
    createuser -U postgres postgres_user;
    createdb -U postgres -O postgres_user test;
    psql -U postgres -d test -c "
    CREATE TABLE costs ( id VARCHAR PRIMARY KEY, name VARCHAR ( 20 ) UNIQUE NOT NULL, price DECIMAL);
    CREATE TABLE products ( id VARCHAR PRIMARY KEY, name VARCHAR ( 20 ) UNIQUE NOT NULL, status VARCHAR ( 20 ), quantity CHAR( 1 ), priceId VARCHAR ( 20 ));
    "'
fi

#autoinsert
if [[ "$1" == "autoinsert" ]]; then
    docker exec -d postgres bash -c '
    psql -U postgres_user -d test -c "INSERT INTO costs VALUES(RANDOM(), RANDOM();)"
    '
fi

#migrate-10
#if [[ "$1" == "migrate-10" ]]; then
    #mysql -u root -pexample -e "CREATE DATABASE test; USE test; "
#fi

#clean
if [[ "$1" == "clean" ]]; then
    docker-compose down;
    docker-compose rm postgres mysql;
    docker container prune -f;
    docker volume prune -f;
fi
