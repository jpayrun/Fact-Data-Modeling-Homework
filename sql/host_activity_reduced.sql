create table host_activity_reduced (month date, host text, hit_array int[], unique_visitors int[]);

insert into host_activity_reduced
                with today as (
                select 
                    host,
                    count(*) as visitors,
                    count(distinct user_id) unique_visitors 
                from events
                where
                    event_time::date = '{date}'::date
                group by 
                    host)
                
                select
                    date_trunc('day', '{date}'::date),
                    t.host,
                    case
                        when har.host is null then array_fill(0, array[Date('{date}'::date) - Date('{first_month}'::date)]) || Array[t.visitors]
                        else har.hit_array || Array[t.visitors]
                    end hit_array,
                    case
                    when har.host is null then array_fill(0, Array[date('{date}'::date) - Date('{first_month}'::date)]) || Array[t.unique_visitors]
                    else har.unique_visitors || Array[t.unique_visitors]
                    end unique_visitors
                from today t
                    full outer join host_activity_reduced har
                        on t.host = har.host
                        and date_trunc('day', '{date}'::date) = har.month
