
create table date_list_int (host text, date_list_int integer[]);

insert into date_list_int
                with today as (
                select 
                    distinct host
                from events
                where
                    event_time::date = '{date}')
                
                select
                    t.host,
                    case
                        when dli.host is null then array_fill(0::bit, array[Date('{date}'::date) - Date('{date.replace(day=1)}'::date)]) || Array[1::bit]
                        when t.host is null then dli.date_list_int || Array[0::bit]
                        --when t.host is not null then dli.date_list_int || Array[1::bit]
                        else dli.date_list_int || Array[1::bit]
                    end as date_list_int
                from today t
                    full outer join date_list_int dli
                        on t.host = dli.host