{{ config(tags=["google_analytics", "daily"]) }}

WITH

TRAFFIC AS (
  SELECT 
    *
  FROM
    {{ ref('cur_minutely_site_traffic_by_campaign') }}
)

SELECT * FROM TRAFFIC