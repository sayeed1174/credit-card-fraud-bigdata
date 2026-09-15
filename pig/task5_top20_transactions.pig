-- Task 5: সবচেয়ে বেশি Amount-এর Top 20 transaction বের করা (descending order)

transactions = LOAD 'creditcard_2023.csv' USING PigStorage(',')
    AS (id:int, V1:double, V2:double, V3:double, V4:double, V5:double, V6:double,
        V7:double, V8:double, V9:double, V10:double, V11:double, V12:double,
        V13:double, V14:double, V15:double, V16:double, V17:double, V18:double,
        V19:double, V20:double, V21:double, V22:double, V23:double, V24:double,
        V25:double, V26:double, V27:double, V28:double, Amount:double, Class:int);

txn_clean = FILTER transactions BY id IS NOT NULL;

txn_selected = FOREACH txn_clean GENERATE id, Amount, Class;

-- Amount অনুযায়ী descending order এ সাজানো
txn_sorted = ORDER txn_selected BY Amount DESC;

-- শুধু প্রথম ২০টা রেকর্ড নেওয়া
top20_txns = LIMIT txn_sorted 20;

STORE top20_txns INTO 'output/task5_top20_transactions' USING PigStorage(',');
-- DUMP top20_txns;
