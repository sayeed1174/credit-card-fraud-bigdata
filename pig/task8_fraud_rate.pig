-- Task 8: সামগ্রিক Fraud Rate (%) বের করা = (মোট Fraud Transaction / মোট Transaction) * 100

transactions = LOAD 'creditcard_2023.csv' USING PigStorage(',')
    AS (id:int, V1:double, V2:double, V3:double, V4:double, V5:double, V6:double,
        V7:double, V8:double, V9:double, V10:double, V11:double, V12:double,
        V13:double, V14:double, V15:double, V16:double, V17:double, V18:double,
        V19:double, V20:double, V21:double, V22:double, V23:double, V24:double,
        V25:double, V26:double, V27:double, V28:double, Amount:double, Class:int);

txn_clean = FILTER transactions BY id IS NOT NULL;

-- মোট Transaction সংখ্যা বের করা
grouped_all = GROUP txn_clean ALL;
total_count = FOREACH grouped_all GENERATE COUNT(txn_clean) AS TotalTxns;

-- শুধু Fraud Transaction ফিল্টার করে তার সংখ্যা বের করা
fraud_txns = FILTER txn_clean BY Class == 1;
grouped_fraud = GROUP fraud_txns ALL;
fraud_count = FOREACH grouped_fraud GENERATE COUNT(fraud_txns) AS FraudTxns;

-- দুইটা ছোট রেজাল্টকে (এক-রেকর্ডের রিলেশন) CROSS করে একসাথে আনা, তারপর Percentage বের করা
combined = CROSS total_count, fraud_count;

fraud_rate = FOREACH combined GENERATE
    total_count::TotalTxns AS TotalTransactions,
    fraud_count::FraudTxns AS FraudTransactions,
    ROUND((double)fraud_count::FraudTxns / (double)total_count::TotalTxns * 100) AS FraudRatePercentage;

STORE fraud_rate INTO 'output/task8_fraud_rate' USING PigStorage(',');
-- DUMP fraud_rate;
