create table user_devices_cumulated (user_id text, browser_type text, dates date[], current_date date);

insert into user_devices_cumulated
with today_dupe as (
select
    e.user_id,
    d.device_id,
    d.browser_type,
    row_number() over (partition by e.user_id, d.device_id) rn
from events e
    left join devices d 
        on d.device_id = e.device_id
where
    user_id is not null
            and event_time::date = '2023/1/1/'),
today as (
select
    *
from today_dupe
where
    rn = 1), mapped_cols as (
select
    user_id,
    browser_type,
    ['2023/1/1'::date] as date,
    '2023/1/1'::date current_date
from today
where
    browser_type is not null),
yesterday as (
select
    *
from user_devices_cumulated
where
    current_date = '2022/12/31'
            ),
historical as (
select
    *
from yesterday y
where
    not exists (select * from mapped_cols mc where mc.user_id = y.user_id and mc.browser_type = y.browser_type)),
new as (
select
    *
from mapped_cols mc
where
    not exists (select * from yesterday y where mc.user_id = y.user_id and mc.browser_type = y.browser_type)),
updated as (
select
    user_id,
    browser_type,
    dates || ['2023/1/1'::Date],
    '2023/1/1'::Date current_date
from yesterday y
where
    exists (select * from mapped_cols mc where mc.user_id = y.user_id and mc.browser_type = y.browser_type))
            
                   
select * from historical
union all
select * from new
union all
select * from updated
