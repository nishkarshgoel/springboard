/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 2 of the case study, which means that there'll be less guidance for you about how to setup
your local SQLite connection in PART 2 of the case study. This will make the case study more challenging for you: 
you might need to do some digging, aand revise the Working with Relational Databases in Python chapter in the previous resource.

Otherwise, the questions in the case study are exactly the same as with Tier 1. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

SELECT name
FROM `Facilities`
WHERE membercost > 0;


/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT( 1 )
FROM `Facilities`
WHERE membercost = 0;


/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance
FROM Facilities
where membercost > 0
and membercost < (20*monthlymaintenance)/100


/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT * 
FROM Facilities 
where facid in (1,5)


/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT name, 
case
	when monthlymaintenance > 100 then 'expensive'
	else 'cheap'
END as 'monthly maintenance'
FROM Facilities


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

Select firstname, surname
from Members
where joindate = (Select max(joindate) from Members)


/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

Select distinct f.name as court, (Select concat(m.firstname, ' ', m.surname) from Members m where m.memid = b.memid) as member
from Bookings b
Left join Facilities f
using (facid)
where f.name like 'Tennis Court%'


/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

Select f.name facility, concat(m.firstname, ' ', m.surname) member, 
Case
	when m.memid=0 then f.guestcost * b.slots
	else f.membercost * b.slots
end as cost 
from Bookings b, 
Members m, 
Facilities f
where b.facid = f.facid
and b.memid = m.memid
and b.starttime like '2012-09-14%'
and (Case
	when m.memid=0 then f.guestcost * b.slots
	else f.membercost * b.slots
end) > 30
order by cost desc


/* Q9: This time, produce the same result as in Q8, but using a subquery. */

Select f.name facility, concat(m.firstname, ' ', m.surname) member, 
Case
	when m.memid=0 then f.guestcost * b.slots
	else f.membercost * b.slots
end as cost 
from (Select memid, facid, slots from Bookings where starttime like '2012-09-14%') b, 
Members m, 
Facilities f
where b.facid = f.facid
and b.memid = m.memid
and (Case
	when m.memid=0 then f.guestcost * b.slots
	else f.membercost * b.slots
end) > 30
order by cost desc



/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

Select a.name facility, sum(a.cost) revenue
from (Select f.name, 
Case
	when b.memid = 0 then f.guestcost * b.slots
	else f.membercost * b.slots
End as cost
from Bookings b, Facilities f
where b.facid = f.facid) a
group by a.name
having sum(a.cost) < 1000
order by revenue


/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

Select m.firstname||' '||m.surname member, (Select m1.firstname||' '||m1.surname from Members m1 where m1.memid = m.recommendedby) recommendedby 
from Members m 
order by m.surname, m.firstname;


/* Q12: Find the facilities with their usage by member, but not guests */

Select m.firstname||' '||m.surname member, count(1) facilities_used from Bookings b, Members m where b.memid = m.memid and b.memid != 0 group by m.firstname||' '||m.surname


/* Q13: Find the facilities usage by month, but not guests */

Select strftime('%m', date(starttime)) month, count(1) facilities_used from Bookings where memid != 0 group by month

