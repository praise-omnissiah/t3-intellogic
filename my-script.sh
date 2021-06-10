#!/bin/bash

#quit on fail
set -euo pipefail

#create
if [[ "$1" == "create" ]]; then
    #CREATE USER 'admin'@'localhost' IDENTIFIED BY 'my very strong password';

    docker exec mysql bash -c '
    mysql -u root -pexample -e "   
    USE test;
    CREATE TABLE costs (id INT NOT NULL AUTO_INCREMENT, name VARCHAR(20) UNIQUE NOT NULL, price NUMERIC(19,4), PRIMARY KEY (id));
    CREATE TABLE products (
        id INT NOT NULL AUTO_INCREMENT,
        name VARCHAR(20) UNIQUE NOT NULL,
        status VARCHAR(20), quantity INTEGER,
        priceId INT NOT NULL,
        PRIMARY KEY (id),
        CONSTRAINT fk_price
            FOREIGN KEY(priceId) 
	            REFERENCES costs(id));
    "'

    docker exec -d postgres bash -c '
    psql -U postgres_user -d test -c "
    CREATE TABLE costs ( id SERIAL PRIMARY KEY, name VARCHAR ( 20 ) UNIQUE NOT NULL, price NUMERIC(19,4));
    "
    psql -U postgres_user -d test -c "
    CREATE TABLE products ( 
        id SERIAL PRIMARY KEY, name VARCHAR ( 20 ) UNIQUE NOT NULL,
        status VARCHAR ( 20 ),
        quantity INTEGER,
        priceId INTEGER,
        CONSTRAINT fk_price
            FOREIGN KEY(priceId) 
	            REFERENCES costs(id));
    "'
fi

#autoinsert
# [99] ERROR:  syntax error at or near "FROM" at character 211
if [[ "$1" == "autoinsert" ]]; then
    docker exec -d postgres bash -c '
    psql -U postgres_user -d test -c "
    INSERT INTO costs (id, name, price)
    SELECT md5(random()::text), md5(random()::text), (random()::int)
    FROM generate_series(1, 20);
    INSERT INTO products (id, name, status, quantity, priceId)
    FROM generate_series(1, 20)
    SELECT md5(random()::text), md5(random()::text), (random()::text), (random()::text), (random()::text);
    "'
fi

#increase Costs.price x 10 and insert to mysql test
#need to output .sql from postgres container to mysql container

#migrate-10
if [[ "$1" == "migrate-10" ]]; then
    docker exec -d postgres bash -c '
    pg_dump -t -a costs products > postres-tables.sql;
    mysql -u root -pexample test < postres-tables.sql
    ' 
fi

#clean
if [[ "$1" == "clean" ]]; then
    docker-compose down;
    docker-compose rm postgres mysql;
    docker container prune -f;
    docker volume prune -f;
fi
