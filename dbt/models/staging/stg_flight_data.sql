with raw as (
  select
    airline,
    flight as flight_number,
    lower(trim(source_city)) as source_city,
    lower(trim(destination_city)) as destination_city,
    lower(replace(trim(departure_time), ' ', '_')) as departure_time,
    lower(replace(trim(arrival_time), ' ', '_')) as arrival_time,
    lower(replace(trim(stops), ' ', '_')) as stops,
    lower(replace(trim(class), ' ', '_')) as travel_class,
    duration,
    safe_cast(days_left as int64) as days_left,
    round(safe_cast(price as float64) * 0.012, 2) as price_usd,
    date_add(current_date(), interval safe_cast(days_left as int64) day) as flight_date
  from {{ source('raw_flight_data', 'raw_flights') }}
)

select * from raw
