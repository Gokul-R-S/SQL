/***
--> Digital Music Store - Data Analysis
Data Analysis project to help Chinook Digital Music Store to help how they can
optimize their business opportunities and to help answering business related questions.
***/

select * from Album; -- 347
select * from Artist; -- 275
select * from Customer; -- 59
select * from Employee; -- 8
select * from Genre; -- 25
select * from Invoice; -- 412
select * from InvoiceLine; -- 2240
select * from MediaType; -- 5
select * from Playlist; -- 18
select * from PlaylistTrack; -- 8715
select * from Track; -- 3503


1) Find the artist who has contributed with the maximum no of albums. Display the artist name and the no of albums.

with cte as 
(select artistid,name,count(*) no_of_albums,
rank() over(order by count(*) desc) rnk from artist join album using(artistid) group by 1,2)
select name artist,no_of_albums from cte where rnk = 1;

-- The artist with the highest number of album contributions is Iron Maiden, with 21 albums.


2) Display the name, email id, country of all listeners who love Jazz, Rock and Pop music.

select distinct firstname ||' ' || lastname cust_name,email,country 
from customer join invoice using (customerid)
join invoiceline using(invoiceid) join track using(trackid)
join genre using (genreid) where genre.name in ('Jazz','Rock','Pop')

-- There are 59 listeners who enjoy Jazz, Rock, and Pop music, and their details, including name, email, and country, have been retrieved.


3) Find the employee who has supported the most no of customers. Display the employee name and designation

with cte as
(select employeeid, concat(e.firstname,' ',e.lastname) employee_name, title, rank()over(order by count(*) desc) rnk,count(*) total
from customer c join employee e on c.supportrepid = e.employeeid
group by 1, 2, 3)
select employee_name, title, total from cte where rnk = 1

-- The employee who has supported the most customers is Jane Peacock, a Sales Support Agent, with 21 customers.


4) Which city generated the highest revenue?

with cte as
(select billingcity, sum(total) revenue, rank()over(order by sum(total) desc) rnk from invoice group by 1)
select billingcity,revenue from cte where rnk = 1

-- The city with the highest revenue and best customers is Prague, generating 90.24 in revenue.


5) The highest number of invoices belongs to which country?

select billingcountry country,total from 
	(select billingcountry,count(*) total,rank()over(order by count(*) desc) rnk from invoice group by billingcountry)
where rnk = 1

-- The USA has the highest number of invoices (91), making it the largest market and a key focus for marketing and sales efforts.


6) Name the best customer (customer who spent the most money).

select cust_name,revenue from 
		(select customerid,concat(firstname,' ',lastname) cust_name,sum(total) revenue,
		rank()over(order by sum(total) desc) rnk 
		from customer join invoice using(customerid) 
		group by 1,2)
where rnk = 1

-- The best customer is Helena Holý, who spent the most money, totaling 49.62 in revenue.

	
7) Suppose you want to host a rock concert in a city and want to know which location should host it.

select billingcity,count(*) no_of_consumers
from invoice join invoiceline using(invoiceid) 
join track using(trackid)
join genre using (genreid) where genre.name = 'Rock'
group by 1 order by 2 desc

-- The best location to host a rock concert is São Paulo, 
-- as it has the highest number of rock consumers (40), followed by Berlin (34) and Paris (30).

	
8) Identify all the albums who have less then 5 track under them.
   Display the album name, artist name and the no of tracks in the respective album.

select a.title as album_name, ar.name as artist_name, count(t.trackid) as no_of_tracks 
from track t join album a on t.albumid = a.albumid join artist ar on a.artistid = ar.artistid 
group by a.albumid, ar.artistid, a.title, ar.name 
having count(t.trackid) < 5 
order by no_of_tracks desc;

-- There are 95 albums that contain less than 5 tracks. This suggests that a significant number 
-- of albums in the database have only a few songs, possibly indicating singles, EPs, or short compilations.

	
9) Display the track, album, artist and the genre for all tracks which are not purchased.

select distinct t.name track ,a.title album, ar.name artist,g.name genre
from track t 
join album a using(albumid) 
join artist ar using (artistid)
join genre g using (genreid) 
where not exists (select 1 from invoiceline il where il.trackid = t.trackid)

-- 1518 tracks were never purchased, indicating low listener interest.


10) Find artist who have performed in multiple genres. Diplay the aritst name and the genre.

select distinct ar.name as artist_name, g.name as genre_name
from track t
join album a using(albumid)
join artist ar using(artistid)
join genre g using(genreid)
where exists (
    select 1
    from track
    join album a2 using(albumid)
	where a2.artistid = ar.artistid
    group by artistid
    having count(distinct genreid) > 1
)

-- The output shows 50 artists who have performed in multiple genres, indicating their versatility across different musical styles.


11) Which is the most popular and least popular genre?

with cte as 
	(select genre.name g_name,count(*) no_of_songs,rank()over(order by count(*) desc) rnk from 
	invoiceline join track using(trackid)
	join genre using(genreid) group by 1)
select g_name,no_of_songs, 'Most Popular' popular_flag from cte where rnk = 1
union all
select g_name,no_of_songs,'Least Popular' from cte where rnk = (select max(rnk) from cte)

-- The most popular genre is Rock with 835 occurrences, 
-- while the least popular genres are Rock And Roll and Science Fiction, each with only 6 occurrences.


12) What are the cities where customers purchased tracks priced above the average price?

select distinct billingcity as city
from invoiceline il
join invoice i using(invoiceid)
where il.unitprice > (select avg(unitprice) from invoiceline);

-- 27 cities bought above-average priced tracks.


13) Identify the 5 most popular artist for the most popular genre.
    Popularity is defined based on how many songs an artist has performed in for the particular genre.
    Display the artist name along with the no of songs.
	[To plan the concert, the team wants to identify the most popular genre among customers and determine 
	which artists have contributed the most songs in that genre.]

with popular_genre as (
    select g.name as genre_name,
           rank() over (order by count(*) desc) as rnk
    from track
    join genre g using(genreid)
    join invoiceline using(trackid)
    group by g.name
),
top_artists as (
    select ar.name as artist_name, count(*) as no_of_songs,
           rank() over (order by count(*) desc) as rnk
    from track
    join album using(albumid)
    join artist ar using(artistid)
    join genre g using(genreid)
    where g.name in (select genre_name from popular_genre where rnk = 1)
    group by ar.name
)
select artist_name, no_of_songs
from top_artists where rnk <= 5;

-- Rock is the most popular genre. The top 5 rock artists by song count are 
-- Led Zeppelin (114), U2 (112), Deep Purple (92), Iron Maiden (81), and Pearl Jam (54).


14) Find the artist who has contributed with the maximum no of songs/tracks. Display the artist name and the no of songs.

with cte as
		(select ar.name artist_name,count(trackid) no_of_songs,
		rank()over(order by count(trackid) desc) rnk
		from track 
		join album a using(albumid) 
		join artist ar using(artistid) 
		group by 1)
select artist_name,no_of_songs from cte where rnk = 1;

-- Iron Maiden has contributed the most songs, with a total of 213 tracks.











