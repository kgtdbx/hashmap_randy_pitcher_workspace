{{ config(tags=["snowflake_usage", "daily"]) }}

WITH 

HISTORY AS (
  SELECT 
    START_TIME_CENTRAL_TIME,
    END_TIME_CENTRAL_TIME,
    USER_NAME,
    ROLE_NAME,
    WAREHOUSE_NAME,
    WAREHOUSE_SIZE,
    TOTAL_ELAPSED_TIME,
    CREDITS_USED_CLOUD_SERVICES

  FROM 
    {{ ref('stg_hashmap_snowflake_query_history') }}
),

USER_CREDIT_EQUIVALENT AS (
  SELECT 
    START_TIME_CENTRAL_TIME,
    END_TIME_CENTRAL_TIME,
    USER_NAME,
    ROLE_NAME,
    WAREHOUSE_NAME,
    WAREHOUSE_SIZE,
    TOTAL_ELAPSED_TIME,
    CREDITS_USED_CLOUD_SERVICES,

    CASE
      WHEN "WAREHOUSE_SIZE" IS NULL    THEN 0
      WHEN "WAREHOUSE_SIZE"='Small'    THEN 1
      WHEN "WAREHOUSE_SIZE"='X-Small'  THEN 2
      WHEN "WAREHOUSE_SIZE"='Medium'   THEN 4
      WHEN "WAREHOUSE_SIZE"='Large'    THEN 8
      WHEN "WAREHOUSE_SIZE"='X-Large'  THEN 16
      WHEN "WAREHOUSE_SIZE"='2X-Large' THEN 32
      WHEN "WAREHOUSE_SIZE"='3X-Large' THEN 64
      WHEN "WAREHOUSE_SIZE"='4X-Large' THEN 128
      WHEN "WAREHOUSE_SIZE"='5X-Large' THEN 256
    END AS WAREHOUSE_NODE_SIZE,

    WAREHOUSE_NODE_SIZE * TOTAL_ELAPSED_TIME / 1000 AS NODE_SECONDS_OF_EXECUTION,

    NODE_SECONDS_OF_EXECUTION / 60 / 60 AS USER_CREDIT_EQUIVALENT_USAGE

  FROM 
    HISTORY
)

SELECT * FROM USER_CREDIT_EQUIVALENT