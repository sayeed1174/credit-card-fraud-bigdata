@echo off
REM ============================================================
REM   Lab Final Demo Script - Credit Card Fraud Project
REM   এই স্ক্রিপ্টটা project2 রুট ফোল্ডার থেকে রান করতে হবে
REM   (যেখানে mapreduce, pig, dataset ফোল্ডার আছে, এবং FraudProject.jar বানানো আছে)
REM ============================================================

echo.
echo ================================================
echo   MAPREDUCE TASK 1: Transaction Count by Class
echo ================================================
call hdfs dfs -rm -r /fraud_project/output/task1
call hadoop jar FraudProject.jar Task1_TransactionCountByClass /fraud_project/input/creditcard_2023.csv /fraud_project/output/task1
echo.
echo ---- OUTPUT ----
call hdfs dfs -cat /fraud_project/output/task1/part-r-00000
pause

echo.
echo ================================================
echo   MAPREDUCE TASK 2: Total Amount by Class
echo ================================================
call hdfs dfs -rm -r /fraud_project/output/task2
call hadoop jar FraudProject.jar Task2_TotalAmountByClass /fraud_project/input/creditcard_2023.csv /fraud_project/output/task2
echo.
echo ---- OUTPUT ----
call hdfs dfs -cat /fraud_project/output/task2/part-r-00000
pause

echo.
echo ================================================
echo   MAPREDUCE TASK 3: Average Amount by Class
echo ================================================
call hdfs dfs -rm -r /fraud_project/output/task3
call hadoop jar FraudProject.jar Task3_AverageAmountByClass /fraud_project/input/creditcard_2023.csv /fraud_project/output/task3
echo.
echo ---- OUTPUT ----
call hdfs dfs -cat /fraud_project/output/task3/part-r-00000
pause

echo.
echo ================================================
echo   MAPREDUCE TASK 4: Max Amount by Class
echo ================================================
call hdfs dfs -rm -r /fraud_project/output/task4
call hadoop jar FraudProject.jar Task4_MaxAmountByClass /fraud_project/input/creditcard_2023.csv /fraud_project/output/task4
echo.
echo ---- OUTPUT ----
call hdfs dfs -cat /fraud_project/output/task4/part-r-00000
pause

echo.
echo ================================================
echo   MAPREDUCE TASK 5: Amount Range Distribution
echo ================================================
call hdfs dfs -rm -r /fraud_project/output/task5
call hadoop jar FraudProject.jar Task5_AmountRangeDistribution /fraud_project/input/creditcard_2023.csv /fraud_project/output/task5
echo.
echo ---- OUTPUT ----
call hdfs dfs -cat /fraud_project/output/task5/part-r-00000
pause

echo.
echo ================================================
echo   Switching to PIG tasks (pig folder)...
echo ================================================
cd pig

echo.
echo ================================================
echo   PIG TASK 1: Filter Fraud Transactions
echo ================================================
rmdir /s /q output\task1_fraud_transactions 2>nul
call pig -x local task1_filter_fraud.pig
echo.
echo ---- OUTPUT (first 20 lines) ----
powershell -command "Get-Content output\task1_fraud_transactions\part-m-00000 -TotalCount 20"
pause

echo.
echo ================================================
echo   PIG TASK 2: Filter High Value Transactions (Amount greater than 10000)
echo ================================================
rmdir /s /q output\task2_high_value_transactions 2>nul
call pig -x local task2_filter_high_value.pig
echo.
echo ---- OUTPUT (first 20 lines) ----
powershell -command "Get-Content output\task2_high_value_transactions\part-m-00000 -TotalCount 20"
pause

echo.
echo ================================================
echo   PIG TASK 3: Count by Class
echo ================================================
rmdir /s /q output\task3_count_by_class 2>nul
call pig -x local task3_count_by_class.pig
echo.
echo ---- OUTPUT ----
type output\task3_count_by_class\part-r-00000
pause

echo.
echo ================================================
echo   PIG TASK 4: Amount Stats (Sum, Avg, Max, Min) by Class
echo ================================================
rmdir /s /q output\task4_amount_stats_by_class 2>nul
call pig -x local task4_amount_stats_by_class.pig
echo.
echo ---- OUTPUT ----
type output\task4_amount_stats_by_class\part-r-00000
pause

echo.
echo ================================================
echo   PIG TASK 5: Top 20 Highest Amount Transactions
echo ================================================
rmdir /s /q output\task5_top20_transactions 2>nul
call pig -x local task5_top20_transactions.pig
echo.
echo ---- OUTPUT ----
type output\task5_top20_transactions\part-r-00000
pause

echo.
echo ================================================
echo   PIG TASK 6: Join with Class Labels
echo ================================================
rmdir /s /q output\task6_joined_with_labels 2>nul
call pig -x local task6_join_class_labels.pig
echo.
echo ---- OUTPUT (first 20 lines) ----
powershell -command "Get-Content output\task6_joined_with_labels\part-r-00000 -TotalCount 20"
pause

echo.
echo ================================================
echo   PIG TASK 7: Amount Range Distribution
echo ================================================
rmdir /s /q output\task7_amount_range_distribution 2>nul
call pig -x local task7_amount_range_distribution.pig
echo.
echo ---- OUTPUT ----
type output\task7_amount_range_distribution\part-r-00000
pause

echo.
echo ================================================
echo   PIG TASK 8: Overall Fraud Rate Percentage
echo ================================================
rmdir /s /q output\task8_fraud_rate 2>nul
call pig -x local task8_fraud_rate.pig
echo.
echo ---- OUTPUT ----
type output\task8_fraud_rate\part-r-00000
pause

echo.
echo ================================================
echo   DEMO COMPLETE - All 5 MapReduce + 8 Pig tasks shown
echo ================================================
pause
