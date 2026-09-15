# Lab Final Project 2: Credit Card Fraud Data Analysis using Hadoop MapReduce & Apache Pig

## ডাটাসেট বর্ণনা (creditcard_2023.csv)

এটা একটা Credit Card Fraud Detection ডাটাসেট, মোট **568,630 টা transaction**।

| Column | Description |
|---|---|
| id | ইউনিক transaction আইডি |
| V1 - V28 | PCA দিয়ে anonymized feature (গোপনীয়তার জন্য আসল মানে রূপান্তরিত সংখ্যাসূচক কলাম) |
| Amount | Transaction-এর পরিমাণ |
| Class | 0 = Legitimate (স্বাভাবিক), 1 = Fraud (জালিয়াতি) |

Class distribution: **284,315 Legitimate + 284,315 Fraud** (সমান ভাগে বিভক্ত dataset)।

সাথে আরেকটা ছোট lookup ফাইল `class_labels.csv` দেওয়া হয়েছে (PIG JOIN task-এর জন্য):
```
Class,Label,RiskLevel
0,Legitimate,Low
1,Fraud,High
```

---

## প্রজেক্ট স্ট্রাকচার

```
project2/
├── dataset/
│   ├── creditcard_2023.csv
│   └── class_labels.csv
├── mapreduce/
│   ├── Task1_TransactionCountByClass.java
│   ├── Task2_TotalAmountByClass.java
│   ├── Task3_AverageAmountByClass.java
│   ├── Task4_MaxAmountByClass.java
│   └── Task5_AmountRangeDistribution.java
├── pig/
│   ├── task1_filter_fraud.pig
│   ├── task2_filter_high_value.pig
│   ├── task3_count_by_class.pig
│   ├── task4_amount_stats_by_class.pig
│   ├── task5_top20_transactions.pig
│   ├── task6_join_class_labels.pig
│   ├── task7_amount_range_distribution.pig
│   └── task8_fraud_rate.pig
└── README.md
```

---

## অংশ ১: MapReduce Tasks (Java)

### Step 1: HDFS-এ ডাটা আপলোড
```cmd
hdfs dfs -mkdir -p /fraud_project/input
hdfs dfs -put dataset\creditcard_2023.csv /fraud_project/input/
```
⚠️ ফাইলটা ৩১০ MB, তাই আপলোড হতে কিছুটা সময় লাগবে।

### Step 2: কম্পাইল করা
```cmd
mkdir classes
for /f "delims=" %i in ('hadoop classpath') do set HADOOP_CLASSPATH=%i
javac -encoding UTF-8 -classpath %HADOOP_CLASSPATH% -d classes mapreduce\*.java
jar -cvf FraudProject.jar -C classes .
```

### Step 3: প্রতিটা Task রান করা

**Task 1: Class অনুযায়ী Transaction Count**
```cmd
hdfs dfs -rm -r /fraud_project/output/task1
hadoop jar FraudProject.jar Task1_TransactionCountByClass /fraud_project/input/creditcard_2023.csv /fraud_project/output/task1
hdfs dfs -cat /fraud_project/output/task1/part-r-00000
```

**Task 2: Class অনুযায়ী Total Amount**
```cmd
hdfs dfs -rm -r /fraud_project/output/task2
hadoop jar FraudProject.jar Task2_TotalAmountByClass /fraud_project/input/creditcard_2023.csv /fraud_project/output/task2
hdfs dfs -cat /fraud_project/output/task2/part-r-00000
```

**Task 3: Class অনুযায়ী Average Amount**
```cmd
hdfs dfs -rm -r /fraud_project/output/task3
hadoop jar FraudProject.jar Task3_AverageAmountByClass /fraud_project/input/creditcard_2023.csv /fraud_project/output/task3
hdfs dfs -cat /fraud_project/output/task3/part-r-00000
```

**Task 4: Class অনুযায়ী Max Amount**
```cmd
hdfs dfs -rm -r /fraud_project/output/task4
hadoop jar FraudProject.jar Task4_MaxAmountByClass /fraud_project/input/creditcard_2023.csv /fraud_project/output/task4
hdfs dfs -cat /fraud_project/output/task4/part-r-00000
```

**Task 5: Amount Range Distribution**
```cmd
hdfs dfs -rm -r /fraud_project/output/task5
hadoop jar FraudProject.jar Task5_AmountRangeDistribution /fraud_project/input/creditcard_2023.csv /fraud_project/output/task5
hdfs dfs -cat /fraud_project/output/task5/part-r-00000
```

### Expected Output (আগে থেকে ভেরিফাই করা)

**Task 1 (Count by Class):**
```
Fraud         284315
Legitimate    284315
```

**Task 2 (Total Amount by Class):**
```
Fraud         3428157045.35
Legitimate    3419261324.40
```

**Task 4 (Max Amount by Class):**
```
Fraud         24039.93
Legitimate    24039.93
```

**Task 5 (Amount Range Distribution):**
```
0-100          1190
100-1000       21320
1000-10000     213580
10000+         332540
```

---

## অংশ ২: Pig Tasks

### Step 1: csv ফাইলগুলো pig ফোল্ডারে কপি করা
```cmd
copy dataset\creditcard_2023.csv pig\
copy dataset\class_labels.csv pig\
cd pig
```

### Step 2: একে একে রান করা
```cmd
pig -x local task1_filter_fraud.pig
pig -x local task2_filter_high_value.pig
pig -x local task3_count_by_class.pig
pig -x local task4_amount_stats_by_class.pig
pig -x local task5_top20_transactions.pig
pig -x local task6_join_class_labels.pig
pig -x local task7_amount_range_distribution.pig
pig -x local task8_fraud_rate.pig
```

⚠️ ডাটাসেট ৩১০ MB এবং ৫ লক্ষের বেশি রো, তাই প্রতিটা script রান হতে ১-৩ মিনিট সময় লাগতে পারে (আগের ছোট ডাটাসেটের চেয়ে বেশি সময় লাগবে, এটা স্বাভাবিক)।

### আউটপুট দেখা

প্রতিটা Task রান হওয়ার পর, প্রথমে ফোল্ডারের ভেতরে ফাইলের নাম চেক করুন:
```cmd
dir output\taskX_xxx
```
তারপর সেই নাম দিয়ে দেখুন:
```cmd
type output\taskX_xxx\part-r-00000
```
(FILTER-only task যেমন Task1, Task2 এ Reduce phase নেই, তাই ফাইলের নাম হতে পারে `part-m-00000`; GROUP/ORDER/JOIN থাকা task গুলোতে `part-r-00000`)

### Pig Task সংক্ষিপ্ত বিবরণ

| Task | কাজ | ব্যবহৃত Pig অপারেটর |
|------|-----|----------------------|
| Task 1 | Fraud (Class=1) transaction ফিল্টার | LOAD, FILTER |
| Task 2 | Amount > 10000 এমন high-value transaction ফিল্টার | FILTER |
| Task 3 | Class অনুযায়ী Transaction Count | GROUP, COUNT |
| Task 4 | Class অনুযায়ী Sum/Avg/Max/Min Amount | GROUP, SUM, AVG, MAX, MIN |
| Task 5 | Amount অনুযায়ী Top 20 transaction | ORDER, LIMIT |
| Task 6 | class_labels.csv এর সাথে JOIN করে readable label বসানো | JOIN |
| Task 7 | Amount কে Range-এ ভাগ করে distribution বের করা | Nested bincond (ternary), GROUP, COUNT |
| Task 8 | সামগ্রিক Fraud Rate (%) বের করা | GROUP ALL, CROSS, nested computation |

### Expected Output (আগে থেকে ভেরিফাই করা)

**Task 3 (Count by Class):**
```
0,284315
1,284315
```

**Task 8 (Fraud Rate):**
```
568630,284315,50.0
```
(মানে মোট ৫৬৮,৬৩০ transaction-এর মধ্যে ৫০% Fraud — যেহেতু dataset টাই সমান ভাগে balanced করা)

---

## প্রেজেন্টেশনের জন্য টিপস

1. প্রথমে বলুন এটা একটা **real-world Kaggle credit card fraud dataset**, ৫ লাখ+ রেকর্ড — বড় ডাটাতে Hadoop/Pig কেন দরকার সেটা বোঝানোর ভালো উদাহরণ।
2. V1-V28 কলাম যে PCA (Principal Component Analysis) দিয়ে anonymize করা — গোপনীয়তার কারণে আসল transaction detail (যেমন location, merchant) দেখানো হয়নি, সেটা উল্লেখ করুন।
3. dataset পুরোপুরি balanced (৫০-৫০ Fraud/Legitimate) — এটা বলে দিলে স্যার বুঝবেন আপনি ডাটা ভালোভাবে explore করেছেন।
4. Task 8 (Fraud Rate with CROSS) — এটা তুলনামূলক advanced একটা Pig টেকনিক, এটা আলাদাভাবে হাইলাইট করলে ভালো ইমপ্রেশন হবে।
