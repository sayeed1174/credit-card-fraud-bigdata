-- Task 6: transactions কে class_labels.csv এর সাথে JOIN করে readable label (Legitimate/Fraud, RiskLevel) দেখানো

transactions = LOAD 'creditcard_2023.csv' USING PigStorage(',')
    AS (id:int, V1:double, V2:double, V3:double, V4:double, V5:double, V6:double,
        V7:double, V8:double, V9:double, V10:double, V11:double, V12:double,
        V13:double, V14:double, V15:double, V16:double, V17:double, V18:double,
        V19:double, V20:double, V21:double, V22:double, V23:double, V24:double,
        V25:double, V26:double, V27:double, V28:double, Amount:double, Class:int);

txn_clean = FILTER transactions BY id IS NOT NULL;
txn_selected = FOREACH txn_clean GENERATE id, Amount, Class;

class_labels = LOAD 'class_labels.csv' USING PigStorage(',')
    AS (Class:int, Label:chararray, RiskLevel:chararray);

class_labels_clean = FILTER class_labels BY Class IS NOT NULL;

-- Class কলামের উপর ভিত্তি করে JOIN
joined_data = JOIN txn_selected BY Class, class_labels_clean BY Class;

joined_result = FOREACH joined_data GENERATE
    txn_selected::id AS id,
    txn_selected::Amount AS Amount,
    class_labels_clean::Label AS Label,
    class_labels_clean::RiskLevel AS RiskLevel;

-- ফলাফলের একটা ছোট অংশ দেখা (পুরো ৫ লক্ষ+ রেকর্ড না দেখিয়ে প্রথম ৫০টা)
joined_sample = LIMIT joined_result 50;

STORE joined_sample INTO 'output/task6_joined_with_labels' USING PigStorage(',');
-- DUMP joined_sample;
