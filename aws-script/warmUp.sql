-- warmUp.sql: modify to query all tables to cache in depot, that is, replace "t1" with actual table and copy the explain for each table to warm up
select * from session_subscriptions where is_participating order by node_name,shard_name ;
explain local select * from t1;
