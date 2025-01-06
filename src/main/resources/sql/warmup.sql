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
       sum((a.amount * r.rate) / 100.0) as uah_eq_acc
from users as t1
         join public.accounts a on t1.id = a.user_id
         join nbu_rates r on a.currency = r.ccy
    and r.ccy_date = '2024-12-05'
group by t1.id
order by t1.id;

--hard
drop table if exists temporary_nbu_rates;
create temp table temporary_nbu_rates
(
    currency text primary key,
    rate     NUMERIC(6, 2)
);

insert into temporary_nbu_rates
select r.ccy, r.rate
from nbu_rates r
where r.ccy_date = '2024-12-05';

select t1.id,
       sum((a.amount * tnr.rate) / 100.0) as uah_eq_acc
from users as t1
         join public.accounts a on t1.id = a.user_id
         join pg_temp.temporary_nbu_rates tnr on a.currency = tnr.currency
group by t1.id
order by t1.id;
-- ------------------------------------------------------------------------------------------------
-- #2a. EASY-MEDIUM-HARD (depends on the solution path you choose)
-- Get total Big Amount UAH equivalent for CREDITS of users and count of CREDITS by user.
-- Result: "user_id", "cnt_cred", "uah_eq_cred"

-- Note: Use CURRENT_DATE for getting current date in Postgres DB.
--easy
select t1.id                            as user_id,
       count(c.id)                      as cnt_cred,
       sum((c.amount * r.rate) / 100.0) as ah_eq_cred
from users as t1
         join public.credits c on t1.id = c.user_id
         join nbu_rates r on c.currency = r.ccy
    and r.ccy_date = '2024-12-05'
group by t1.id
order by t1.id;

--hard
drop table if exists temporary_nbu_rates;
create temp table temporary_nbu_rates
(
    currency text primary key,
    rate     NUMERIC(6, 2)
);

insert into temporary_nbu_rates
select r.ccy, r.rate
from nbu_rates r
where r.ccy_date = '2024-12-05';

select t1.id                              as user_id,
       count(c.id)                        as cnt_cred,
       sum((c.amount * tnr.rate) / 100.0) as ah_eq_cred
from users as t1
         join public.credits c on t1.id = c.user_id
         join pg_temp.temporary_nbu_rates tnr on c.currency = tnr.currency
group by t1.id
order by t1.id;


--hard
drop table if exists temporary_current_rate;
create temp table temporary_current_rate(
    ccy  CHAR(3) PRIMARY KEY NOT NULL,
    current_rate NUMERIC(6, 2)
);

insert into temporary_current_rate
select nbu_rates.ccy, nbu_rates.rate
from nbu_rates
where ccy_date = '2024-12-05';

select t1.id,
       sum((a.amount * r.current_rate) / 100.0) as uah_eq_acc
from users t1
         join public.accounts a on t1.id = a.user_id
         join temporary_current_rate r on a.currency = r.ccy
group by t1.id
order by t1.id;
-- ------------------------------------------------------------------------------------------------
-- #4. EASY.
-- Get all the users which have more than one of accounts.
-- Result: User ID and count of his accounts ("count_acc"), sorted by "count_acc" DESCending and User ID ASCending.
select a.user_id,
       count(a.id) as count_acc
from accounts a
group by a.user_id
having count(a.id) > 1
order by count_acc desc, a.user_id;

-- ------------------------------------------------------------------------------------------------
-- #5. EASY.
-- Select all UNIQUE users who have accounts other than UAH.
-- Result: user_id
select distinct a.user_id
from accounts a
where a.currency != 'UAH';

-- ------------------------------------------------------------------------------------------------
-- #6. MEDIUM.
-- Select users by name (as "user_name"), account (as "acc_id")
-- and maximum Big Amount of money in the account (as "UAH_sum") (only UAH-accounts).
-- Sort by amount in descending order. Bring out the top-3 in the rating.
-- Result: "user_name", "acc_id", "UAH_sum"
select t1.name          as user_name,
       a.id             as acc_id,
       a.amount / 100.0 as UAH_sum
from users as t1
         join public.accounts a on t1.id = a.user_id
    and a.currency = 'UAH'
order by UAH_sum desc
limit 3;

-- ------------------------------------------------------------------------------------------------
-- #7. MEDIUM.
-- How did the rate change compared to the previous day (except UAH rate)?
-- Result: currency, "curr_date", "curr_rate", "prev_date", "prev_rate", "diff"
drop table if exists temporary_date_tb;
create temp table temporary_date_tb
(
    ccy  char(3),
    rate numeric(6, 2)
);

insert into temporary_date_tb
select r.ccy, r.rate
from nbu_rates r
where r.ccy_date = ('2024-12-05'::date - 1);

select r.ccy                         as currency,
       r.ccy_date                    as curr_date,
       r.rate                        as curr_rate,
       r.ccy_date - interval '1 day' as prev_date,
       tdt.rate                      as prev_rate,
       abs(tdt.rate - r.rate)        as diff
from nbu_rates r
         join pg_temp.temporary_date_tb tdt on r.ccy = tdt.ccy
where r.ccy_date = '2024-12-05'
  and r.ccy != 'UAH';

-- ------------------------------------------------------------------------------------------------
-- #8. MEDIUM.
-- Get count accounts and credits for ALL users sorted by user ID.
-- Result: "user_id", "cnt_acc", "cnt_cred"

-- Note: Not at all the users have accounts and/or credits, in this case output NULL as "uah_eq"
select t1.id       as user_id,
       count(a.id) as cnt_acc,
       count(c.id) as cnt_cred
from users as t1
         left join public.accounts a on t1.id = a.user_id
         left join public.credits c on t1.id = c.user_id
group by t1.id
order by t1.id;


-- ------------------------------------------------------------------------------------------------
-- #9. MEDIUM.
-- Select all users who do not have any accounts.
-- Result: "user_id", "acc_id"
-- Note: In this case account ID must be NULL.
select t1.id as user_id,
       a.id  as account_id
from users t1
         left join public.accounts a on t1.id = a.user_id
where a.user_id is null;


-- ------------------------------------------------------------------------------------------------
-- #10. EASY (BONUS-LEVEL)
-- Calculate the count of students and their average age.
-- Result: "cnt", "avg_age"
-- ------------------------------------------------------------------------------------------------
SELECT count(s.id) as cnt,
       avg(s.age)  as avg_age
FROM students s;

create table products
(
    id         bigserial primary key,
    name       text not null,
    price      decimal(8, 2),
    created_at timestamp default now()
);

insert into products(name, price)
values ('banana', 14),
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
         (select name,
                 count(*) over (partition by name) as name_count
          from products)

select distinct name
from name_counts
where name_count > 1;


