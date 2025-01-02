-- WARMUP
-- NOTE: Money.amount are specified in pennies.
--       Big Amount = Amount / 100.0
-- Time: 30 min.

-- ------------------------------------------------------------------------------------------------
-- #0. EASY.
-- Insert into table 'students' your name (or nick) and your age.
-- Name length must be 3 or more letters and Age > 15
insert into students (name, age)
values ('Yelyzaveta Lubenets', 0);

-- ------------------------------------------------------------------------------------------------
-- #1. EASY.
-- Calculate average age of users [double/numeric] (in any option)
-- Result: one field  -> "average_age"
select avg(age) as average_age
from users as t1;

-- ------------------------------------------------------------------------------------------------
-- #2. EASY-MEDIUM-HARD (depends on the solution path you choose)
-- Get total Big Amount UAH equivalent for ACCOUNTS of users.
-- Result: User ID and the total sum of Big Amount UAH equivalent sorted by user ID ("id", "uah_eq_acc").

-- Note: Use CURRENT_DATE for getting current date in Postgres DB.

-- easy
select t1.id,
       sum ((a.amount * r.rate) / 100.0) as uah_eq_acc
from users as t1
join public.accounts a on t1.id = a.user_id
join nbu_rates r on a.currency = r.ccy
and r.ccy_date = '2024-12-05'
group by t1.id
order by t1.id;

-- ------------------------------------------------------------------------------------------------
-- #2a. EASY-MEDIUM-HARD (depends on the solution path you choose)
-- Get total Big Amount UAH equivalent for CREDITS of users and count of CREDITS by user.
-- Result: "user_id", "cnt_cred", "uah_eq_cred"

-- Note: Use CURRENT_DATE for getting current date in Postgres DB.
SELECT *
-- TODO: Write your solution here
FROM users as t1;

-- ------------------------------------------------------------------------------------------------
-- #4. EASY.
-- Get all the users which have more than one of accounts.
-- Result: User ID and count of his accounts ("count_acc"), sorted by "count_acc" DESCending and User ID ASCending.
SELECT *
-- TODO: Write your solution here
FROM users as t1;

-- ------------------------------------------------------------------------------------------------
-- #5. EASY.
-- Select all UNIQUE users who have accounts other than UAH.
-- Result: user_id
SELECT *
-- TODO: Write your solution here
FROM users as t1;

-- ------------------------------------------------------------------------------------------------
-- #6. MEDIUM.
-- Select users by name (as "user_name"), account (as "acc_id")
-- and maximum Big Amount of money in the account (as "UAH_sum") (only UAH-accounts).
-- Sort by amount in descending order. Bring out the top-3 in the rating.
-- Result: "user_name", "acc_id", "UAH_sum"
SELECT *
-- TODO: Write your solution here
FROM users as t1;

-- ------------------------------------------------------------------------------------------------
-- #7. MEDIUM.
-- How did the rate change compared to the previous day (except UAH rate)?
-- Result: currency, "curr_date", "curr_rate", "prev_date", "prev_rate", "diff"
SELECT *
-- TODO: Write your solution here
FROM users as t1;

-- ------------------------------------------------------------------------------------------------
-- #8. MEDIUM.
-- Get count accounts and credits for ALL users sorted by user ID.
-- Result: "user_id", "cnt_acc", "cnt_cred"

-- Note: Not at all the users have accounts and/or credits, in this case output NULL as "uah_eq"
SELECT *
-- TODO: Write your solution here
FROM users as t1;

-- ------------------------------------------------------------------------------------------------
-- #9. MEDIUM.
-- Select all users who do not have any accounts.
-- Result: "user_id", "acc_id"
-- Note: In this case account ID must be NULL.
SELECT *
-- TODO: Write your solution here
FROM users as t1;

-- ------------------------------------------------------------------------------------------------
-- #10. EASY (BONUS-LEVEL)
-- Calculate the count of students and their average age.
-- Result: "cnt", "avg_age"
-- ------------------------------------------------------------------------------------------------
SELECT *
-- TODO: Write your solution here
FROM students;

create table products (
    id bigserial primary key,
    name text not null,
    price decimal (8,2),
    created_at timestamp default now()
);

insert into products(name, price)
values
    ('banana', 14),
    ('banana', 14),
    ('apple', 12),
    ('orange', 12),
    ('pineapple', 12);

-- find duplicate names

-- v1 ( group by + having )
select name
from products
group by name
having count(name) > 1;

-- v2 ( self join )
select p1.name
from products p1
join public.products p2 on p1.id = p2.id
group by p1.name
having count(p1.name) > 1;

-- v3 ( window function )
with name_counts as
    ( select name,
             count(*) over (partition by name) as name_count
      from products)

select distinct name
from name_counts
where name_count > 1;


