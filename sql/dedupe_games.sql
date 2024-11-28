with dupes as (
           select
            *,
            row_number() over (partition by game_id, player_id) rn
           from game_details)
           
           select 
            * 
           from dupes 
           where 
            rn = 1