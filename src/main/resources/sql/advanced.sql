-- ADVANCED
-- NOTE: Money.amount are specified in pennies.
--       Big Amount = Amount / 100.0

-- ------------------------------------------------------------------------------------------------
-- #11. EASY.
-- Update field 'finished_at' in the table 'students' for your ID or your name (nick).
-- WARNING! Do not use UPDATE without conditions (WHERE)!!!

-- Check your name:
select *
from students
order by id;

update students
set finished_at = NOW()
where name = 'Yelyzaveta Lubenets'
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

update students
set finished_at = NOW()
where name in ('student 1', 'student 2');

select s.name,
       round(extract(epoch from (s.finished_at - s.created_at)/ 60), 1) as minutes
from students s
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

select count(s.id) as cnt,
       round(extract(epoch from (max(s.finished_at) - min(s.created_at))/ 60), 1) as minutes,
       round(extract(epoch from (max(s.finished_at) - min(s.created_at))/ 60), 1)/ count(s.id) as avg_minutes
from students s;
-- ------------------------------------------------------------------------------------------------
-- #14. MEDIUM.
-- What is the largest Big Amount in UAH equivalent on a non-overdue account ("max_curr_uah_eq")?
-- Result: "user_id", "acc_id", "max_curr_uah_eq"

-- Note: See the "end_date" field and compare with the current date.
drop table if exists temporary_nbu_rates;
create temp table temporary_nbu_rates
(
    currency text primary key,
    rate     NUMERIC(6, 2)
);

insert into temporary_nbu_rates
select r.ccy, r.rate
from nbu_rates r
where r.ccy_date = current_date;

select a.user_id as user_id,
       a.id as acc_id,
       (a.amount * tnr.rate) / 100.0 as max_curr_uah_eq
from accounts as a
join pg_temp.temporary_nbu_rates tnr on a.currency = tnr.currency
and a.end_date >= current_date
order by max_curr_uah_eq desc
limit 1
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
drop table if exists temporary_nbu_rates;
create temp table temporary_nbu_rates
(
    currency text primary key,
    rate     numeric(6, 2)
);

insert into temporary_nbu_rates
select r.ccy, r.rate
from nbu_rates r
where r.ccy_date = current_date;

drop table if exists temp_account_stat;
create temp table temp_account_stat
(
    cnt_acc        integer,
    user_id        integer,
    user_name varchar(50),
    sum_uah_ba_acc integer
);

insert into temp_account_stat
select count(a.id), u.id, u.name, sum((a.amount * tnr.rate) / 100.0)
from accounts a
         left join public.users u on u.id = a.user_id
         join pg_temp.temporary_nbu_rates tnr on a.currency = tnr.currency
group by u.id
order by u.id;

drop table if exists temp_credit_stat;
create temp table temp_credit_stat
(
    cnt_cred        integer,
    user_id         integer,
    user_name varchar(50),
    sum_uah_ba_cred integer
);

insert into temp_credit_stat
select count(c.id), u.id, u.name, sum((c.amount * tnr.rate) / 100.0)
from credits c
         left join public.users u on u.id = c.user_id
         join pg_temp.temporary_nbu_rates tnr on c.currency = tnr.currency
group by u.id
order by u.id;

select u.id as user_id,
       u.name as user_name,
       tas.cnt_acc as cnt_acc,
       tcs.cnt_cred as cnt_cred,
       tas.sum_uah_ba_acc,
       tcs.sum_uah_ba_cred,
       tas.sum_uah_ba_acc + tcs.sum_uah_ba_cred as diff
from users u
left join temp_account_stat tas on tas.user_id = u.id
left join temp_credit_stat tcs on tcs.user_id = u.id
order by u.id;

-- ------------------------------------------------------------------------------------------------
-- #16. HARD (BONUS-LEVEL)
-- Based on task #15, do the same, but for non-overdue accounts and credits.
-- Calculate "diff" and identify customers whose total amount on accounts does not exceed
-- (i.e. is less than) the total Big Amount of their credits.
-- Result: "user_id", "name", "cnt_acc", "sum_uah_ba_acc", "cnt_cred", "sum_uah_ba_cred", "diff"

-- TODO: Write your solution here