SET 'auto.offset.reset'='earliest';

CREATE TABLE customers (
    CUSTOMER_ID INTEGER PRIMARY KEY,
    FIRST_NAME VARCHAR,
    LAST_NAME VARCHAR,
    EMAIL VARCHAR,
    GENDER VARCHAR,
    INCOME INTEGER,
    FICO INTEGER
) WITH (
    KAFKA_TOPIC = 'CUSTOMERS_TABLE',
    VALUE_FORMAT = 'JSON',
    PARTITIONS = 6
);

CREATE TABLE offers (
    OFFER_ID INTEGER PRIMARY KEY,
    OFFER_NAME VARCHAR,
    OFFER_URL VARCHAR
) WITH (
    KAFKA_TOPIC = 'OFFERS_STREAM',
    VALUE_FORMAT = 'JSON',
    PARTITIONS = 6
);

CREATE STREAM customer_activity_stream (
    CUSTOMER_ID INTEGER KEY,
    ACTIVITY_ID INTEGER,
    IP_ADDRESS VARCHAR,
    ACTIVITY_TYPE VARCHAR,
    PROPENSITY_TO_BUY DOUBLE
   ) WITH (
    KAFKA_TOPIC = 'CUSTOMER_ACTIVITY_STREAM',
    VALUE_FORMAT = 'JSON',
    PARTITIONS = 6
);

-- Application logic
CREATE STREAM next_best_offer
WITH (
    KAFKA_TOPIC = 'NEXT_BEST_OFFER',
    VALUE_FORMAT = 'JSON',
    PARTITIONS = 6
) AS
SELECT 
    cask.CUSTOMER_ID as CUSTOMER_ID,
    cask.ACTIVITY_ID,
    cask.PROPENSITY_TO_BUY,
    cask.ACTIVITY_TYPE,
    ct.INCOME,
    ct.FICO,
    CASE
        WHEN ct.INCOME > 100000 AND ct.FICO < 700 AND cask.PROPENSITY_TO_BUY < 0.9 THEN 1
        WHEN ct.INCOME < 50000 AND cask.PROPENSITY_TO_BUY < 0.9 THEN 2
        WHEN ct.INCOME >= 50000 AND ct.FICO >= 600 AND cask.PROPENSITY_TO_BUY < 0.9 THEN 3
        WHEN ct.INCOME > 100000 AND ct.FICO >= 700 AND cask.PROPENSITY_TO_BUY < 0.9 THEN 4
        ELSE 5
    END AS OFFER_ID 
FROM customer_activity_stream cask
INNER JOIN customers ct ON cask.CUSTOMER_ID = ct.CUSTOMER_ID;

CREATE STREAM next_best_offer_lookup
WITH (
    KAFKA_TOPIC = 'NEXT_BEST_OFFER_LOOKUP',
    VALUE_FORMAT = 'JSON',
    PARTITIONS = 6
) AS
SELECT
    nbo.CUSTOMER_ID,
    nbo.ACTIVITY_ID,
    nbo.OFFER_ID,
    nbo.PROPENSITY_TO_BUY,
    nbo.ACTIVITY_TYPE,
    nbo.INCOME,
    nbo.FICO,
    ot.OFFER_NAME,
    ot.OFFER_URL
FROM next_best_offer nbo
INNER JOIN offers ot
ON nbo.OFFER_ID = ot.OFFER_ID;
