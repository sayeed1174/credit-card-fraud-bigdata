-- Task 1: শুধু Fraud (Class = 1) ট্রানজেকশনগুলো ফিল্টার করে দেখা

transactions = LOAD 'creditcard_2023.csv' USING PigStorage(',')
    AS (id:int, V1:double, V2:double, V3:double, V4:double, V5:double, V6:double,
        V7:double, V8:double, V9:double, V10:double, V11:double, V12:double,
        V13:double, V14:double, V15:double, V16:double, V17:double, V18:double,
        V19:double, V20:double, V21:double, V22:double, V23:double, V24:double,
        V25:double, V26:double, V27:double, V28:double, Amount:double, Class:int);

-- হেডার লাইন বাদ দেওয়া
txn_clean = FILTER transactions BY id IS NOT NULL;

-- শুধু Fraud transaction ফিল্টার
fraud_txns = FILTER txn_clean BY Class == 1;

fraud_result = FOREACH fraud_txns GENERATE id, Amount, Class;

STORE fraud_result INTO 'output/task1_fraud_transactions' USING PigStorage(',');
-- DUMP fraud_result;
