CREATE SCHEMA k8sdemo;
CREATE TABLE k8sdemo.cryptoquotes (tick TIMESTAMP, symbol VARCHAR, quote FLOAT);
\! wget https://raw.githubusercontent.com/bryanherger/vertica-eon-toolkit/master/vultr-vke/ethusd_28feb2022.csv
COPY k8sdemo.cryptoquotes FROM LOCAL 'ethusd_28feb2022.csv' DELIMITER ',';
select symbol, date_trunc('HOUR',tick), min(quote), avg(quote), max(quote) from k8sdemo.cryptoquotes where date(tick) = '2022-02-28' group by 1,2 order by 1,2;
-- comment this line if you want to keep the demo data!
DROP SCHEMA k8sdemo CASCADE;

