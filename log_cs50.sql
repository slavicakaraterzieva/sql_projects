-- Keep a log of any SQL queries you execute as you solve the mystery.
-- opening the database
--sources: https://www.sqlitetutorial.net/

sqlite3 fiftyville.db
--looking into the tables

.tables
--looking at schemas

.schema crime_scene_reports
--looking into reports

SELECT description FROM crime_scene_reports WHERE day = 28 AND  month = 7 AND year = 2021;
--time line 10:15 - 16:36, looking into the interview reports of the same date and the bakery reports

--looking into iterviews
.schema interviews

SELECT name, transcript FROM interviews WHERE day = 28 AND month = 7 AND year = 2021;
--Ruth, Eugene and Raymond were intreviewed, things to check:
--security footage from the backery parking lot
--ATM on Leggett street for money withdrawing
--phone call less than a minute
--flights out of the airport for the next day and purchased tickets

--but before all this, let's see the people involved
SELECT * FROM people;
--so some people don't have phones or passports or cars. Katherine doesn't have anything.
--next to look bakery security logs

.schema bakery_security_logs
SELECT bakery_security_logs.activity, bakery_security_logs.license_plate, people.name FROM bakery_security_logs
JOIN people ON bakery_security_logs.license_plate = people.license_plate
WHERE day = 28 AND month = 7 AND year = 2021 AND hour = 10 AND minute >= 15 AND minute <= 25;
--nine cars exited in the timeframe
/*
 exit      5P2BI95        Vanessa
 exit      94KL13X        Bruce
 exit      6P58WS2        Barry
 exit      4328GD8        Luca
 exit      G412CB7        Sofia
 exit      L93JTIZ        Iman
 exit      322W7JE        Diana
 exit      0NTHK55        Kelsey
*/

--checking ATM
SELECT atm_transactions.transaction_type, atm_transactions.account_number, atm_transactions.amount, people.name
FROM atm_transactions JOIN bank_accounts ON atm_transactions.account_number = bank_accounts.account_number
JOIN people ON bank_accounts.person_id = people.id
WHERE day = 28 AND month = 7 AND year = 2021 AND atm_location = "Leggett Street";
--eight people withdrawed money.
/*
 withdraw          49610011        50      Bruce
 deposit           86363979        10      Kaelyn
 withdraw          26013199        35      Diana
 withdraw          16153065        80      Brooke
 withdraw          28296815        20      Kenny
 withdraw          25506511        20      Iman
 withdraw          28500762        48      Luca
 withdraw          76054385        60      Taylor
 withdraw          81061156        30      Benista
*/

--checking phone calls
SELECT phone_calls.caller, people.name FROM phone_calls
JOIN people ON phone_calls.caller = people.phone_number
WHERE day = 28 AND month = 7 AND year = 2021 AND duration < 60;
--nine people talked in that time frame
/*
name of callers
 (130) 555-0289    Sofia
 (499) 555-9472    Kelsey
 (367) 555-5533    Bruce
 (499) 555-9472    Kelsey
 (286) 555-6063    Taylor
 (770) 555-1861    Diana
 (031) 555-6622    Carina
 (826) 555-1652    Kenny
 (338) 555-6650    Benista
*/
SELECT phone_calls.receiver, people.name FROM phone_calls
JOIN people ON phone_calls.receiver = people.phone_number
WHERE day = 28 AND month = 7 AND year = 2021 AND duration < 60;
/*
name of receivers
(996) 555-8899  Jack
(892) 555-8872  Larry
(375) 555-8161  Robin
(717) 555-1342  Melissa
(676) 555-6554  James
(725) 555-3243  Philip
(910) 555-3251  Jacqueline
(066) 555-9701  Doris
(704) 555-2131  Anna
*/
--still not sure who is talking to whom from the queries. I remember creating temporary tables in MySQL, I wonder if I have the same option in sqlite3.
--it turns out that I can create temprary database with temporary table for this, I will use it because it will be deleted after the use, since I will use it only once.

--sources: https://database.guide/create-temporary-table-sqlite/
CREATE TEMP TABLE extended AS SELECT * FROM phone_calls;

ALTER TABLE TEMP.extended ADD COLUMN receiver_name TEXT;
ALTER TABLE TEMP.extended ADD COLUMN caller_name TEXT;

UPDATE temp.extended
SET receiver_name = people.name FROM people
JOIN phone_calls ON people.phone_number = phone_calls.receiver
WHERE temp.extended.receiver = phone_calls.receiver;

UPDATE temp.extended
SET caller_name = people.name FROM people
JOIN phone_calls ON people.phone_number = phone_calls.caller
WHERE temp.extended.caller = phone_calls.caller;

SELECT caller, caller_name, receiver, receiver_name FROM temp.extended
WHERE day = 28 AND month = 7 AND year = 2021 AND duration < 60;
/*
 (499) 555-9472  Kelsey    (892) 555-8872  Larry
 (367) 555-5533  Bruce     (375) 555-8161  Robin
 (499) 555-9472  Kelsey    (717) 555-1342  Melissa
 (286) 555-6063  Taylor    (676) 555-6554  James
 (770) 555-1861  Diana     (725) 555-3243  Philip
 (031) 555-6622  Carina    (910) 555-3251  Jacqueline
 (826) 555-1652  Kenny     (066) 555-9701  Doris
 (338) 555-6650  Benista   (704) 555-2131  Anna
*/

--checking transport
SELECT people.name, people.passport_number, people.license_plate, flights.hour, flights.minute FROM people
JOIN passengers ON people.passport_number = passengers.passport_number
JOIN flights ON passengers.flight_id = flights.id
WHERE year = 2021 AND month = 7 AND day = 29 ORDER by hour ASC LIMIT 10;
/*

 name   passport_number  license_plate  hour  minute

 Doris   7214083635       M51FA04        8     20
 Sofia   1695452385       G412CB7        8     20
 Bruce   5773159633       94KL13X        8     20
 Edward  1540955065       130LD9Z        8     20
 Kelsey  8294398571       0NTHK55        8     20
 Taylor  1988161715       1106N58        8     20
 Kenny   9878712108       30G67EN        8     20
 Luca    8496433585       4328GD8        8     20
 Daniel  7597790505       FLFN3W0        9     30
 Carol   6128131458       81MNC9R        9     30
*/

--checking where did this people went
SELECT passengers.flight_id AS id, people.name, people.passport_number, flights.hour, flights.minute, airports.full_name AS destination, airports.city FROM people
JOIN passengers ON people.passport_number = passengers.passport_number
JOIN flights ON passengers.flight_id = flights.id
JOIN airports ON airports.id = destination_airport_id
WHERE year = 2021 AND month = 7 AND day = 29 ORDER by hour ASC LIMIT 10;
/*
id name   passport_number   hour  minute       destination                   city

36 Doris   7214083635       8     20      LaGuardia Airport             New York City
36 Sofia   1695452385       8     20      LaGuardia Airport             New York City
36 Bruce   5773159633       8     20      LaGuardia Airport             New York City
36 Edward  1540955065       8     20      LaGuardia Airport             New York City
36 Kelsey  8294398571       8     20      LaGuardia Airport             New York City
36 Taylor  1988161715       8     20      LaGuardia Airport             New York City
36 Kenny   9878712108       8     20      LaGuardia Airport             New York City
36 Luca    8496433585       8     20      LaGuardia Airport             New York City
43 Daniel  7597790505       9     30      O'Hare International Airport  Chicago
43 Carol   6128131458       9     30      O'Hare International Airport  Chicago
*/

--comparing logs with flights
SELECT passengers.flight_id, bakery_security_logs.license_plate, people.name FROM bakery_security_logs
JOIN people ON bakery_security_logs.license_plate = people.license_plate
JOIN passengers ON people.passport_number = passengers.passport_number
WHERE day = 28 AND month = 7 AND year = 2021 AND hour = 10 AND minute >= 15 AND minute <= 25 AND flight_id = 36;
/* narowing to 5 people
flight_id  license_plate   name

 36         94KL13X        Bruce
 36         4328GD8        Luca x
 36         G412CB7        Sofia
 36         0NTHK55        Kelsey
*/
--comparing phone calls with flights
SELECT DISTINCT passengers.flight_id AS id, phone_calls.caller, people.name FROM phone_calls
JOIN people ON phone_calls.caller = people.phone_number
JOIN passengers ON people.passport_number = passengers.passport_number
WHERE day = 28 AND month = 7 AND year = 2021 AND duration < 60 AND flight_id = 36;
/*
5 people
 id       caller      name

 36   (130) 555-0289  Sofia
 36   (499) 555-9472  Kelsey
 36   (367) 555-5533  Bruce
 36   (286) 555-6063  Taylor x
 36   (826) 555-1652  Kenny x
*/

--comparing atm with flights
SELECT DISTINCT passengers.flight_id AS id, atm_transactions.transaction_type, atm_transactions.account_number, atm_transactions.amount, people.name
FROM atm_transactions JOIN bank_accounts ON atm_transactions.account_number = bank_accounts.account_number
JOIN people ON bank_accounts.person_id = people.id
JOIN passengers ON people.passport_number = passengers.passport_number
WHERE day = 28 AND month = 7 AND year = 2021 AND atm_location = "Leggett Street" AND flight_id = 36;
/*
down to Bruce, busted!
id  transaction_type  account_number  amount   name

 36  withdraw          49610011        50      Bruce
 36  withdraw          76054385        60      Taylor x
 36  withdraw          28296815        20      Kenny x
 36  withdraw          28500762        48      Luca x
*/
