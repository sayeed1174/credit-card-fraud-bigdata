-- Task 2: Amount > 10000 এমন High-Value transaction ফিল্টার করা

transactions = LOAD 'creditcard_2023.csv' USING PigStorage(',')
    AS (id:int, V1:double, V2:double, V3:double, V4:double, V5:double, V6:double,
        V7:double, V8:double, V9:double, V10:double, V11:double, V12:double,
        V13:double, V14:double, V15:double, V16:double, V17:double, V18:double,
        V19:double, V20:double, V21:double, V22:double, V23:double, V24:double,
        V25:double, V26:double, V27:double, V28:double, Amount:double, Class:int);

txn_clean = FILTER transactions BY id IS NOT NULL;

high_value = FILTER txn_clean BY Amount > 10000;

high_value_result = FOREACH high_value GENERATE id, Amount, Class;

STORE high_value_result INTO 'output/task2_high_value_transactions' USING PigStorage(',');
-- DUMP high_value_result;
