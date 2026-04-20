{{ config(
    materialized='table',
    partition_by={'field': 'flight_date', 'data_type': 'date'},
    cluster_by=['source_city', 'destination_city', 'airline']
) }}

with staging as (
  select * from {{ ref('stg_flight_data') }}
)

select
  flight_date,
  source_city,
  destination_city,
  airline,
  travel_class,
  avg(price_usd) as avg_price,
  min(price_usd) as min_price,
  max(price_usd) as max_price,
  count(*) as total_flights
from staging
where flight_date is not null
group by
  flight_date,
  source_city,
  destination_city,
  airline,
  travel_class
