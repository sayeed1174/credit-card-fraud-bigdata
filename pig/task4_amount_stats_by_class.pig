-- Task 4: Class অনুযায়ী Total, Average, Max, Min Amount একসাথে বের করা

transactions = LOAD 'creditcard_2023.csv' USING PigStorage(',')
    AS (id:int, V1:double, V2:double, V3:double, V4:double, V5:double, V6:double,
        V7:double, V8:double, V9:double, V10:double, V11:double, V12:double,
        V13:double, V14:double, V15:double, V16:double, V17:double, V18:double,
        V19:double, V20:double, V21:double, V22:double, V23:double, V24:double,
        V25:double, V26:double, V27:double, V28:double, Amount:double, Class:int);

txn_clean = FILTER transactions BY id IS NOT NULL;

grouped_by_class = GROUP txn_clean BY Class;

amount_stats = FOREACH grouped_by_class GENERATE
    group AS Class,
    ROUND(SUM(txn_clean.Amount)) AS TotalAmount,
    ROUND(AVG(txn_clean.Amount)) AS AvgAmount,
    MAX(txn_clean.Amount) AS MaxAmount,
    MIN(txn_clean.Amount) AS MinAmount;

STORE amount_stats INTO 'output/task4_amount_stats_by_class' USING PigStorage(',');
-- DUMP amount_stats;
