--11. AdditionalTasks

--1. Триггер при попытке добавить самую дешёвую книгу увеличивает её цену на 10%
create trigger add_min_price_title
on titles after insert
as
begin
	if (select min(price) from titles) = (select min(price) from inserted)
	begin
		update titles
		set price = price * 1.1
		where price = (select min(price) from inserted)
	end
end

drop trigger add_min_price_title

--2. Хранимая функция возвращает таблицу с самыми дорогими книгами в своих жанрах
create function max_price_title()
returns table
as
return 
	select * from titles A
	where price = (select max(price) from titles
	where type = (select distinct type from titles where type = A.type))

select * from max_price_title()

drop function max_price_title

--3. Представление (view) показывает даты самой ранней и самой поздней книг
create view show_date_titles
as
	select title, pubdate
	from titles
	where pubdate = (select max(pubdate) from titles) or 
		  pubdate = (select min(pubdate) from titles)

select * from show_date_titles

drop view show_date_titles

--4. Триггер (instead of) при удалении автора запрещает его удалять, если у него есть 2 книги
create function count_title (@au_id varchar(11))
returns int
as
begin
	declare @count int
	select @count = count(*) from titleauthor where au_id = @au_id
	return @count
end

create trigger delete_author
on authors instead of delete
as
begin
	declare @au_id varchar(11), @n int

	select @au_id = deleted.au_id
	from deleted

	select @n = count(*) from deleted
	where dbo.count_title(@au_id) >= 2
	if @n > 0
		begin
			raiserror('Deleting is not possible!', 0, 1)
			rollback tran
		end
	else
		print('Delete is successfull!') 
end

drop trigger delete_author

--5. представление (view) показывает магазины, которые продают книги с самой низкой ценой
alter view ShowStores
as
select stor_id, stor_name, stor_address from stores where stor_id in
(select stor_id from sales where title_id in
(select title_id from titles where price = (select min(price) from titles)))

select * from ShowStores

--6. хранимая функция принимает жанр книг и возвращает количество дней, которое прошло между публикациями самой
--ранней и самой поздней книг в указанном жанре
create function DaysCount(@type varchar(20))
returns int
as
begin
	declare @date1 date
	select @date1 = min(pubdate) from titles where type = @type 

	declare @date2 date
	select @date2 = max(pubdate) from titles where type = @type 

	declare @cnt int
	set @cnt = datediff (day, @date1, @date2)
	return @cnt
end

select dbo.DaysCount('business')

--7. хранимая функция принимает жанр книг и возвращает авторов, которые написали самые дешёвые и самые дорогие книги в указанном жанре
alter function ShowAuthorsByType(@type varchar(20))
returns @T table(au_id varchar(11), au_fname varchar(20), au_lname varchar(40))
as
begin

	declare @min money
	select @min = price from titles where price = (select min(price) from titles where type = @type) and type = @type

	declare @max money
	select @max = price from titles where price = (select max(price) from titles where type = @type) and type = @type
	
	insert into @T
	select au_id, au_fname, au_lname from authors
	where au_id in
	(select au_id from titleauthor where title_id in
	(select title_id from titles where price = @min or price = @max))
	return
end

select * from ShowAuthorsByType('psychology')

--8. хранимая процедура принимает цену книг и повышает цену всех книг, которые дешевле указанной цены на$2. 
--   После этого процедура возвращает количество книг, цена которых была увеличена, и их среднюю цену
alter procedure IncreasePrice(@price money, @cnt int out, @avg money out)
as
begin
	
	select @cnt = count(*) from titles where price < @price
	select @avg = avg(price) from titles where price < @price

	update titles
	set price += 2
	where price < @price

	print @cnt
	print @avg
end

declare @count int
declare @average3 money
exec IncreasePrice 15, @cnt out, @avg out
select @count, @average3

--9. курсор показывает имена, фамилии и штат всех авторов,
--проживающих в штате 'CA', которые написали только одну книгу
DECLARE @au_fname varchar(20), @au_lname varchar(40), @state char(2)

DECLARE AuthorsCursor CURSOR dynamic FOR 
select au_fname, au_lname, state 
from authors 
where state = 'CA'
and au_id in
(select authors.au_id
from authors inner join titleauthor
on authors.au_id = titleauthor.au_id
group by authors.au_id
having count(*) = 1)

OPEN AuthorsCursor

FETCH first FROM AuthorsCursor 
INTO @au_fname, @au_lname, @state

WHILE @@FETCH_STATUS = 0
BEGIN

	select @au_fname, @au_lname, @state

	FETCH NEXT FROM AuthorsCursor
	INTO @au_fname, @au_lname, @state

END

CLOSE AuthorsCursor

DEALLOCATE AuthorsCursor

--10. Instead of триггер при добавлении книги увеличивает её цену на $5, если её цена ниже, чем средняя цена уже существующих книг
alter trigger AddBookTrigger
on titles instead of insert
as
begin
    if((select price from inserted) < (select avg(price) from titles))
    begin
        insert into titles 
        (title_id, title, type, price, pub_id, advance, royalty, ytd_sales, notes, pubdate)
        select 
        title_id, title, type, price + 5, pub_id, advance, royalty, ytd_sales, notes, pubdate 
        from inserted
    end
end

insert into titles (title_id, title, type, price)
values ('AA7778', 'Alchemist', 'adventure', 4)

select * from titles
order by price

--11. для каждой книги в одном запросе показать: 
--	- название, 
--	- жанр,
--	- цену,
--	- количество авторов, которые её написали,
--	- количество магазинов, продающих эту книгу
select distinct title, type, price,
(select count(au_id) from titleauthor where title_id in
(select title_id from titles where title_id = TS.title_id)) as [au_count],
(select count(stor_id) from stores where stor_id in
(select stor_id from sales where title_id in
(select title_id from titles where title_id = TS.title_id))) as [store_count]
from titles TS

/*Пример:
title										type			price	au_count	store_count
The Busy Executive's Database Guide			business    	23.99		2			2
Cooking with Computers						business    	15.95		2			1
Sushi, Anyone?								trad_cook   	18.99		3			1*/
	

/*12. в одном запросе показать:
	- название самой дорогой книги и её цену,
	- название самой дешёвой книги и её цену, для каждого жанра*/
select distinct type as [type],
(select top 1 title from titles where price = (select max(price) from titles where type = TS.type)) as [title1],
(select max(price) from titles where type = TS.type) as [max_price],
(select top 1 title from titles where price = (select min(price) from titles where type = TS.type)) as [title2],
(select min(price) from titles where type = TS.type) as [min_price]
from titles TS

/*Пример:
type			title1									max_price	title2							min_price
business    	The Busy Executive's Database Guide		23.99		You Can Combat Computer Stress!	7.689
mod_cook    	The Busy Executive's Database Guide		23.99		You Can Combat Computer Stress!	7.689
UNDECIDED   	The Psychology of Computer Cooking		9.00		The Psychology of Computer		9.00*/


