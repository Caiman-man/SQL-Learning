--1. SELECT

--1. показать все книги, опубликованные в штате UT авторами на контракте
select distinct title
from titles, titleauthor, authors
where titles.title_id = titleauthor.title_id 
		and titleauthor.au_id = authors.au_id
			and authors.state = 'UT' and authors.contract = 1

--2. показать все книги дешевле $10 
select * from titles
where price < 10

--3. показать количество книг, опубликованных летом 
select * from titles
where month(pubdate) >= 06 and month(pubdate) <= 08

--4. показать всех издателей из города 'Paris' 
select * from publishers 
where city = 'Paris'

--5. показать, сколько прошло дней между датами публикации самой дорогой и самой дешЄвой книги
--5.1 трудно читаемый вариант
select datediff (day, (select pubdate from titles 
						where price = (select min(price) from titles) 
							and pubdate != (select pubdate from titles 
								where price = (select max(price) from titles))),
									(select pubdate from titles 
										where price = (select max(price) from titles)))

--5.2 вариант с переменными
declare @date1 date
set @date1 = (select pubdate from titles where price = (select min(price) from titles) and pubdate != 
			 (select pubdate from titles where price = (select max(price) from titles)))
declare @date2 date
set @date2 = (select pubdate from titles where price = (select max(price) from titles))
select datediff (day, @date1, @date2)