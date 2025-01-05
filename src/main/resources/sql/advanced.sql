-- ADVANCED
-- NOTE: Money.amount are specified in pennies.
--       Big Amount = Amount / 100.0

-- ------------------------------------------------------------------------------------------------
-- #11. EASY.
-- Update field 'finished_at' in the table 'students' for your ID or your name (nick).
-- WARNING! Do not use UPDATE without conditions (WHERE)!!!

-- Check your name:
SELECT *
FROM students
ORDER BY id;

UPDATE students
SET finished_at = NOW()
WHERE name = 'Yelyzaveta Lubenets'
-- id = 1
;

-- ------------------------------------------------------------------------------------------------
-- #12. MEDIUM
-- Calculate how long the warm-up was for each student, and display the TOP-3 most agile students.
-- Warning:
-- If "finished_at" is equal to "created_at", it means that the student is still in the process of completing the task,
-- it does not need to be taken into account.
-- Result: "id", "name", "minutes"

-- Notes:
-- 1) To get the difference between two timestamps, you need to use the formula:
--          [EXTRACT(EPOCH FROM (end_time - start_time)) / 60 AS "minutes"]
-- 2) Round the obtained time result in "minutes" to tenths. [15.788888 -> 15.8]
--              [ROUND(duration, 1) AS rounded_duration]

insert into students (name, age)
values ('student 1', 24),
       ('student 2', 30),
        ('sudent 3', 35);

UPDATE students
SET finished_at = NOW()
WHERE name in ('student 1', 'student 2');

SELECT s.name,
       round(extract(epoch from (s.finished_at - s.created_at)/ 60), 1) as minutes
FROM students s
where s.finished_at != s.created_at
order by minutes
limit 3;


-- ------------------------------------------------------------------------------------------------
-- #13. MEDIUM
-- Count the number of students in the table 'students' ("cnt"),
-- the amount of time spent from the start of the warm-up (created_at) to its end (finished_at)
-- for the entire group of students in the table ("minutes").
-- Also, additionally calculate the average warm-up time if all students worked in multithreaded mode:
--                 ["avg_minutes" = "minutes" / "cnt"]
-- Note: Round the obtained time result in "minutes" to tenths. [15.788888 -> 15.8]
-- Use the formula: ROUND(duration, 1) AS rounded_duration

SELECT count(s.id) as cnt,
       round(extract(epoch from (max(s.finished_at) - min(s.created_at))/ 60), 1) as minutes,
       round(extract(epoch from (max(s.finished_at) - min(s.created_at))/ 60), 1)/ count(s.id) as avg_minutes
FROM students s;
-- ------------------------------------------------------------------------------------------------
-- #14. MEDIUM.
-- What is the largest Big Amount in UAH equivalent on a non-overdue account ("max_curr_uah_eq")?
-- Result: "user_id", "acc_id", "max_curr_uah_eq"

-- Note: See the "end_date" field and compare with the current date.

SELECT *
-- TODO: Write your solution here
FROM accounts as a
;

-- ------------------------------------------------------------------------------------------------
-- #15. HARD.
-- Calculate the number of accounts ("cnt_acc") and credits ("cnt_cred") for EACH user
-- and the total Big Amount on accounts ("sum_uah_ba_acc") and credits ("sum_uah_ba_cred") in UAH equivalent.
-- Also, you need to calculate the difference ("diff") between "sum_uah_ba_acc" and "sum_uah_ba_cred".
-- Warning: The amount values of credits are negative. Thus, the difference ("diff") should be calculated as:
--                            ["diff" = "sum_uah_ba_acc" - "sum_uah_ba_cred"]
-- Result: "user_id", "name", "cnt_acc", "sum_uah_ba_acc", "cnt_cred", "sum_uah_ba_cred", "diff"

-- Note: use table 'nbu_rates' for rates for different types of currencies (rate for current day).


-- TODO: Write your solution here


-- ------------------------------------------------------------------------------------------------
-- #16. HARD (BONUS-LEVEL)
-- Based on task #15, do the same, but for non-overdue accounts and credits.
-- Calculate "diff" and identify customers whose total amount on accounts does not exceed
-- (i.e. is less than) the total Big Amount of their credits.
-- Result: "user_id", "name", "cnt_acc", "sum_uah_ba_acc", "cnt_cred", "sum_uah_ba_cred", "diff"

-- TODO: Write your solution here