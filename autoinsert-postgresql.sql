INSERT INTO costs (id, name, price)
SELECT md5(random()::text), md5(random()::text), (random()::int)
FROM generate_series(1, 20);
INSERT INTO products (id, name, status, quantity, priceId)
FROM generate_series(1, 20)
SELECT md5(random()::text), md5(random()::text), (random()::text), (random()::text), (random()::text);