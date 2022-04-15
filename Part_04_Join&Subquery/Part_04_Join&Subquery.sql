--4. JOIN and SUBQUERY

-- 1. ПОКАЗАТЬ ВСЕХ АВТОРОВ, КОТОРЫЕ НЕ ПИШУТ КНИГ В ЖАНРЕ 'BUSINESS' (JOIN)
-- 1.1 join
select distinct au_fname, au_lname, type
from authors inner join titleauthor inner join titles
on titleauthor.title_id = titles.title_id
on authors.au_id = titleauthor.au_id
where titles.type != 'business'
order by type

-- 1.2 join + except
select au_fname, au_lname, type
from authors inner join titleauthor inner join titles
on titleauthor.title_id = titles.title_id
on authors.au_id = titleauthor.au_id
except
select au_fname, au_lname, type
from authors inner join titleauthor inner join titles
on titleauthor.title_id = titles.title_id
on authors.au_id = titleauthor.au_id
where titles.type = 'business'
order by type

-- 1.3 многотабличный + except
select au_lname, au_fname, type
from titles, titleauthor, authors
where titles.title_id = titleauthor.title_id 
		and titleauthor.au_id = authors.au_id
except
select distinct au_lname, au_fname, type
from titles, titleauthor, authors
where titles.title_id = titleauthor.title_id 
		and titleauthor.au_id = authors.au_id
			and titles.type = 'business'
order by type

-- 1.4 подзапрос + except
select au_lname, au_fname from authors
except
select au_lname, au_fname from authors where au_id in
(select au_id from titleauthor where title_id in
(select title_id from titles where type = 'business'))


-- 2. ПОКАЗАТЬ МАГАЗИНЫ, КОТОРЫЕ ПРОДАЮТ КНИГИ С ЦЕНОЙ НИЖЕ СТРЕДНЕЙ (ПОДЗАПРОС И JOIN)
-- 2.1 многотабличный
select distinct stor_name
from stores, sales, titles
where stores.stor_id = sales.stor_id
and sales.title_id = titles.title_id
and titles.price <= (select avg(price) from titles)

-- 2.2 join
select distinct stor_name
from stores inner join sales 
on stores.stor_id = sales.stor_id
inner join titles
on sales.title_id = titles.title_id
and titles.price <= (select avg(price) from titles)

-- 2.3 подзапрос
select stor_name from stores where stor_id in
(select stor_id from sales where title_id in
(select title_id from titles where price <= (select avg(price) from titles)))


-- 3. ПОКАЗАТЬ МАГАЗИНЫ, КОТОРЫЕ ПРОДАЮТ КНИГИ АВТОРОВ ИЗ 'UT' (ПОДЗАПРОС И JOIN)
-- 3.1 join
select distinct stor_name
from stores inner join sales 
on stores.stor_id = sales.stor_id
inner join titleauthor
on sales.title_id = titleauthor.title_id
inner join authors
on titleauthor.au_id = authors.au_id
and authors.state = 'UT'

-- 3.2 подзапрос
select stor_name from stores where stor_id in
(select stor_id from sales where title_id in
(select title_id from titleauthor where au_id in
(select au_id from authors where state = 'UT')))


-- 4. ПОКАЗАТЬ СКОЛЬКО АВТОРОВ НАПИСАЛИ КНИГИ, ИЗДАННЫЕ ЛЕТОМ (ПОДЗАПРОС И JOIN)
-- 4.1 join
select count(distinct authors.au_id)
from authors inner join titleauthor
on authors.au_id = titleauthor.au_id
inner join titles
on titleauthor.title_id = titles.title_id
where month(pubdate) between 6 and 8

-- 4.2 подзапрос
select count(*) from authors where au_id in
(select au_id from titleauthor where title_id in
(select title_id from titles where month(pubdate) between 6 and 8))


-- 5. ПОКАЗАТЬ ГОД ИЗДАНИЯ САМОЙ ДОРОГОЙ КНИГИ В ЖАНРЕ 'BUSINESS' (ПОДЗАПРОС)
select distinct year(pubdate) from titles where pubdate in
(select pubdate from titles where price = (select max(price) from titles where type = 'business'))