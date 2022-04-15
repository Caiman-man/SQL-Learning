--3. MULTY TABLES SELECT

--1. показать все книги, дешевле $15, написанные авторами из 'CA'
select distinct title, price, state
from titles, titleauthor, authors
where titles.title_id = titleauthor.title_id 
		and titleauthor.au_id = authors.au_id
			and authors.state = 'CA' and titles.price < 15

--2. показать авторов, не написавших ни одной книги
-- в таблице authors - есть все авторы
-- а в таблице titleauthor - только те авторы, которые писали книги
select authors.au_id, au_lname, au_fname
from authors
except
select authors.au_id, au_lname, au_fname
from authors, titleauthor
where titleauthor.au_id = authors.au_id
--или же просто:
select * from authors
where contract = 0

--3. показать магазины, не продавшие ни одной книги
--результат ничего не дал, так как все магазины имели продажи книг
select stor_name
from stores
except
select stor_name
from stores, sales
where stores.stor_id = sales.stor_id

--4. показать жанры, в которых работают авторы из штата 'UT'
select distinct type, state
from titles, titleauthor, authors
where titles.title_id = titleauthor.title_id 
		and titleauthor.au_id = authors.au_id
			and authors.state = 'UT'

--5. показать самую дорогую книгу в жанре 'Business' 
select title, type, price
from titles
where price = (select max(price) from titles where type = 'business')