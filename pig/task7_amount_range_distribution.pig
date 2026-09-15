-- Task 7: Amount কে Range/Bucket-এ ভাগ করে প্রতিটা Range-এ কতগুলো Transaction পড়ে তার Count বের করা

transactions = LOAD 'creditcard_2023.csv' USING PigStorage(',')
    AS (id:int, V1:double, V2:double, V3:double, V4:double, V5:double, V6:double,
        V7:double, V8:double, V9:double, V10:double, V11:double, V12:double,
        V13:double, V14:double, V15:double, V16:double, V17:double, V18:double,
        V19:double, V20:double, V21:double, V22:double, V23:double, V24:double,
        V25:double, V26:double, V27:double, V28:double, Amount:double, Class:int);

txn_clean = FILTER transactions BY id IS NOT NULL;

-- nested bincond (ternary condition) ব্যবহার করে প্রতিটা রেকর্ডে AmountRange কলাম বসানো
txn_with_range = FOREACH txn_clean GENERATE
    id, Amount, Class,
    (Amount < 100 ? '0-100' :
        (Amount < 1000 ? '100-1000' :
            (Amount < 10000 ? '1000-10000' : '10000+'))) AS AmountRange;

grouped_by_range = GROUP txn_with_range BY AmountRange;

range_distribution = FOREACH grouped_by_range GENERATE
    group AS AmountRange,
    COUNT(txn_with_range) AS TotalTransactions;

range_distribution_sorted = ORDER range_distribution BY TotalTransactions DESC;

STORE range_distribution_sorted INTO 'output/task7_amount_range_distribution' USING PigStorage(',');
-- DUMP range_distribution_sorted;
