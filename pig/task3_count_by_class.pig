-- Task 3: Class অনুযায়ী মোট Transaction Count বের করা

transactions = LOAD 'creditcard_2023.csv' USING PigStorage(',')
    AS (id:int, V1:double, V2:double, V3:double, V4:double, V5:double, V6:double,
        V7:double, V8:double, V9:double, V10:double, V11:double, V12:double,
        V13:double, V14:double, V15:double, V16:double, V17:double, V18:double,
        V19:double, V20:double, V21:double, V22:double, V23:double, V24:double,
        V25:double, V26:double, V27:double, V28:double, Amount:double, Class:int);

txn_clean = FILTER transactions BY id IS NOT NULL;

grouped_by_class = GROUP txn_clean BY Class;

class_count = FOREACH grouped_by_class GENERATE
    group AS Class,
    COUNT(txn_clean) AS TotalTransactions;

STORE class_count INTO 'output/task3_count_by_class' USING PigStorage(',');
-- DUMP class_count;
