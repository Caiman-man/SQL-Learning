--2. SELECT

--1. ѕоказать все книги, опубликованные в штате UT авторами на контракте
select distinct title
from titles, titleauthor, authors
where titles.title_id = titleauthor.title_id 
		and titleauthor.au_id = authors.au_id
			and authors.state = 'UT' and authors.contract = 1

--2. ѕоказать все книги дешевле $10 
select * from titles
where price < 10

--3. ѕоказать количество книг, опубликованных летом 
select * from titles
where month(pubdate) >= 06 and month(pubdate) <= 08

--4. ѕоказать всех издателей из города 'Paris' 
select * from publishers 
where city = 'Paris'

--5. ѕоказать, сколько прошло дней между датами публикации самой дорогой и самой дешЄвой книги
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

-------------------------------------------------------------------------------
--3. UNION

--1. Показать книги, в названии которых есть цифры, отсортировать по цене
select title, price 
from titles
where title like '[0123456789]%'
order by price

--2. Показать все книги, которые опубликованы в жанрах 'Business' и 'Psychology'
select title, type 
from titles
where type = 'business' or type = 'psychology'

--3. Увеличить дату публикации книг в жанре 'Business' на 2 месяца (dateadd)
update titles
set pubdate = dateadd(month, 2, pubdate)
where type = 'business'

--4. Увеличить цену книг в жанре 'Business' на 5%
update titles
set price = price * 1.05
where type = 'business'

--5. Показать авторов с именами начинающимися и заканчивающимися на согласные буквы из CA
select au_fname, au_lname, state 
from authors
where au_fname like '[^aeoyiu]%[^aeoyiu]' and state = 'CA'

-------------------------------------------------------------------------------
--4. MULTY TABLES SELECT

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

-------------------------------------------------------------------------------
--5. JOIN and SUBQUERY

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

-------------------------------------------------------------------------------
--6. PROCEDURE

--1 ’ранима¤ процедура удал¤ет автора и его книги
--не работает как и 5й запрос
create procedure delete_author (@auid varchar(11))
as
	begin
	declare @titleid varchar(6)
	select @titleid = title_id from titles where title_id in 
					  (select title_id from titleauthor where au_id in
					  (select au_id from authors where au_id = @auid))
	delete from titles where title_id = @titleid
	delete from titleauthor where au_id = @auid
	delete from authors where au_id = @auid
end

exec delete_author '213-46-8915'

drop proc delete_author

--2 ’ранима¤ процедура увеличивает цену всех книг указанного диапазона цен на $2
create procedure increase_price(@price1 money, @price2 money)
as
begin
	update titles
	set price += 2
	where price > @price1 and price < @price2
end

exec increase_price 1, 100

--3 ’ранима¤ процедура добавл¤ет книгу указанному автору
--  не получилось передать в процедуру 'pub_id' и дату, но книги добавл¤ютс¤
create procedure add_book(@auid varchar(11), @titleid varchar(6), @title varchar(80),
						  @type char(12), @price money, @advance money, 
						  @royalty int, @ytdsales int, @notes varchar(200))
as
begin
	insert into titles
	(title_id, title, type, price, advance, royalty, ytd_sales, notes)
	values
	(@titleid, @title, @type, @price, @advance, @royalty, @ytdsales, @notes)

	insert into titleauthor (au_id, title_id)
	values (@auid, @titleid)
end

exec add_book '172-32-1176', 'AA7776', 'Alchemist', 'adventure', 77.77, 7700.00, 88, 101, 'just notes'

drop proc add_book

--4 ’ранима¤ процедура возвращает количество книг и среднюю цену книг авторов из указанного штата
create procedure count_and_average(@state char(2))
as
begin
	declare @count int
	select @count = count(title) from titles where title_id in 
					(select title_id from titleauthor where au_id in
					(select au_id from authors where state = @state))

	declare @average money
	select @average = avg(price) from titles where title_id in 
				      (select title_id from titleauthor where au_id in
					  (select au_id from authors where state = @state))
	print @count
	print @average
end

exec count_and_average 'UT'

drop proc count_and_average

--5 хранима¤ процедура удал¤ет книги заданного жанра и возвращает количество удалЄнных книг
--не работает, не удал¤ет книги, видимо из-за св¤зи между titles и titleauthor
create procedure delete_book(@type char(12))
as
begin
	declare @count int
	select @count = count(*) from titles where type = @type

	declare @titleid varchar(6)
	select @titleid = title_id from titles where title_id in 
					   (select title_id from titleauthor where titles.type = @type)
	delete from titles where type = @type
	delete from titleauthor where title_id = @titleid

	print @count
end

exec delete_book 'adventure'

drop proc delete_book

-------------------------------------------------------------------------------
--7. FUNCTIONS and VIEWS

--1. Представление показывает авторов, которые написали больше всех книг
--не получилось сделать нужный запрос
--но получилось найти авторов, которые написали более одной книги
create view show_authors
as
	select titleauthor.au_id, count(titleauthor.title_id) as amount, au_fname, au_lname
	from authors, titleauthor
	where authors.au_id = titleauthor.au_id
	group by titleauthor.au_id, au_fname, au_lname
	having count(titleauthor.title_id) > 1

select * from show_authors

drop view show_authors

--2. Хранимая функция возвращает название самой дешёвой книги
create function min_price_title()
returns table
as
	return select title from titles where price = (select min(price) from titles)

select * from min_price_title()

drop function min_price_title

--3. Хранимая процедура меняет местами цены самой дорогой и самой дешёвой книги
create procedure swap
as
begin
	declare @max_price money
	select @max_price = max(price) from titles

	declare @min_price money
	select @min_price = min(price) from titles

	declare @min_id varchar(6)
	select @min_id = title_id from titles where price = (select min(price) from titles)

	declare @max_id varchar(6)
	select @max_id = title_id from titles where price = (select max(price) from titles)

	update titles 
	set price = @max_price where title_id = @min_id
	update titles 
	set price = @min_price where title_id = @max_id
end

exec swap

drop proc swap

--4. Хранимая функция возвращает список всех штатов, где живут авторы, не написавшие ни одной книги
create function states()
returns table
as
	return select distinct state
			from authors left join titleauthor 
			on authors.au_id = titleauthor.au_id
			where titleauthor.title_id is null 

select * from states()

drop function states

--5. Хранимая функция возвращает самую дорогую и самую дешёвую книгу в заданном жанре
--результат удалось возвратить только в одной колонке
create function min_max_titles(@type varchar(20))
returns table
as

	return select title, price, type from titles where price = (select min(price) from titles where type = @type) and type = @type
	union
	select title, price, type from titles where price = (select max(price) from titles where type = @type) and type = @type

select * from min_max_titles('business')

drop function min_max_titles

-------------------------------------------------------------------------------
--8. TRIGGERS

--1. Показать для каждого автора:
--- имя, фамилия автора
--- количество издательств, которые его публикуют
--- название издательства, которое публикует его самую дорогую книгу
select * from
(select au_id, au_fname, au_lname,
(select count(pub_id) from titles where title_id in
(select title_id from titleauthor where au_id = a.au_id)) as [pubs_number],
(select top 1 pub_name from publishers where pub_id in 
(select pub_id from titles where price = (select max(price) from titles where title_id in
(select title_id from titleauthor where au_id = a.au_id)))) as [pubs_name]
from authors A) A2
where [pubs_name] is not null

--2. Показать самую раннюю опубликованную книги в своих издательствах
select * from titles A
where pubdate = (select min(pubdate) from titles
where pub_id = (select pub_id from publishers where pub_id = A.pub_id))

--3. Триггер не позволяет добавлять авторов, в именах которых нет гласных букв
create trigger insert_ban
on authors 
for insert	
as
begin
	declare @n int
	select @n = count(*) from inserted
	where au_fname like '%[aeoyiu]%'
	if @n = 0
		begin
			raiserror('Inserting is not possible!', 0, 1)
			rollback tran
		end
	else
		print('Insert is successfull!') 
end

drop trigger insert_ban

--insert into authors(au_id, au_lname, au_fname, phone, address, city, state, zip, contract)
--values
--('111-11-1111', 'Marilyn', 'Mnsn', '333 333-3333','1st street', 'Los Angeles', 'CA', 12345, 1)

--4. Триггер не позволяет удалять автора, если у него есть книги
create trigger delete_ban
on authors 
for delete
as
begin
	declare @au_id varchar(11), @n int

	select @au_id = deleted.au_id
	from deleted

	select @n = count(*) from deleted
	where @au_id in (select titleauthor.au_id from authors left join titleauthor 
					 on titleauthor.au_id = authors.au_id 
					 where titleauthor.title_id is not null)
	if @n > 0
		begin
			raiserror('Deleting is not possible!', 0, 1)
			rollback tran
		end
	else
		print('Delete is successfull!') 
end

drop trigger delete_ban
--delete from authors where au_id = '998-72-3567'

--5. Триггер при удалении автора удаляет и все его книги
create trigger delete_titles
on authors
after delete
as
begin
	delete from titles where title_id in 
	(select title_id from titleauthor where au_id = (select au_id from deleted))
end

drop trigger delete_titles
--delete from authors where au_id = '111-11-1111'

-------------------------------------------------------------------------------
--9. TRIGGERS-2

--1. “риггер разрешает добавл¤ть только те книги, у которых цена положительна¤
create trigger add_trigger1
on titles instead of insert
as
begin
	print 'Instead of INSERT1'
	insert into titles 
	select * from inserted
	where price > 0
end

insert into titles (title_id, title, type, price)
values ('AA7778', 'Alchemist', 'adventure', -10)

drop trigger add_trigger1

--2. “риггер разрешает добавл¤ть только те книги, у которых цена выше средней
create trigger add_trigger2
on titles instead of insert
as
begin
	print 'Instead of INSERT2'
	insert into titles 
	select * from inserted
	where price > (select avg(price) from titles)
end

insert into titles (title_id, title, type, price)
values ('AA7778', 'Alchemist', 'adventure', 100)

drop trigger add_trigger2

--3. “риггер запрещает удал¤ть издателей, если у них есть книги
create trigger delete_trigger
on publishers instead of delete
as
begin
	print 'Instead of DELETE'
	select * from deleted
	delete from publishers where pub_id in
	(select publishers.pub_id
	from titles full outer join publishers
	on titles.pub_id = publishers.pub_id
	where title is null)
end

delete from publishers where pub_id = '9901'
delete from publishers where pub_id = '0877'

drop trigger delete_trigger

--4. “риггер запрещает измен¤ть книги в жанре 'Business'
create trigger update_trigger1
on titles instead of update
as
begin
	print 'Instead of UPDATE1'
	select * from inserted
	select * from deleted

	update titles 
	set title = inserted.title
	from titles, inserted
	where titles.title_id = inserted.title_id
	and inserted.type != 'business'
end

update titles set title = 'Alchemist' where title_id = 'BU2075'
update titles set title = 'Alchemist' where title_id = 'PS2091'

drop trigger update_trigger1

--5. “риггер запрещает делать книги дешевле!
create trigger update_trigger2
on titles instead of update
as
begin
	print 'Instead of UPDATE2'
	select * from inserted
	select * from deleted

	update titles 
	set price = inserted.price
	from titles, inserted
	where titles.title_id = inserted.title_id
	and titles.price < inserted.price
end

update titles set price = 10 where title_id = 'BU1032'

drop trigger update_trigger2

-------------------------------------------------------------------------------
--10. CURSORS

--1.  урсор добавл¤ет к каждому названию книги год издани¤ в круглых скобках. пример: —казки (1998)
DECLARE @title varchar(80), @pubdate date

DECLARE cursor_1 CURSOR dynamic FOR 
SELECT title, pubdate FROM titles

OPEN cursor_1

FETCH first FROM cursor_1 
INTO @title, @pubdate

WHILE @@FETCH_STATUS = 0
BEGIN
	UPDATE titles 
	SET title = @title + ' (' + CONVERT(VARCHAR(4), @pubdate, 102) + ')'
	WHERE CURRENT OF cursor_1

	FETCH NEXT FROM cursor_1
	INTO @title, @pubdate
END

CLOSE cursor_1

DEALLOCATE cursor_1


--2.  урсор стирает после каждого названи¤ книги год издани¤ вместе со скобками
DECLARE @title varchar(80)

DECLARE cursor_2 CURSOR dynamic FOR 
SELECT title FROM titles

OPEN cursor_2

FETCH first FROM cursor_2 
INTO @title

WHILE @@FETCH_STATUS = 0
BEGIN
	UPDATE titles 
	SET title = left(@title, len(@title)-7)
	WHERE CURRENT OF cursor_2

	FETCH NEXT FROM cursor_2
	INTO @title
END

CLOSE cursor_2

DEALLOCATE cursor_2


--3.  урсор вычисл¤ет количество букв 'a' в именах авторов
DECLARE @fname varchar(20), @cnt int = 0

DECLARE cursor_3 CURSOR dynamic FOR 
SELECT au_fname FROM authors

OPEN cursor_3

FETCH first FROM cursor_3 INTO @fname

WHILE @@FETCH_STATUS = 0
BEGIN
	declare @i int = 1, @l varchar(1)
	WHILE @i <= len(@fname)

	BEGIN
		set @l = substring(@fname, @i, 1)
		if @l = 'a'
			set @cnt = @cnt + 1
		set @i = @i + 1
	END

	FETCH NEXT FROM cursor_3
	INTO @fname
END

close cursor_3

deallocate cursor_3

select @cnt


--4.  урсор замен¤ет все буквы 'a' в названи¤х книг на '|'
DECLARE @title varchar(80)

DECLARE cursor_4 CURSOR dynamic FOR 
SELECT title FROM titles

OPEN cursor_4

FETCH first FROM cursor_4 
INTO @title

WHILE @@FETCH_STATUS = 0
BEGIN
	UPDATE titles 
	SET title = replace (@title, 'a', '|') 
	WHERE CURRENT OF cursor_4

	FETCH NEXT FROM cursor_4
	INTO @title
END

CLOSE cursor_4

DEALLOCATE cursor_4


--5.  урсор замен¤ет все буквы '|' в названи¤х книг на 'a'
DECLARE @title varchar(80)

DECLARE cursor_5 CURSOR dynamic FOR 
SELECT title FROM titles

OPEN cursor_5

FETCH first FROM cursor_5 
INTO @title

WHILE @@FETCH_STATUS = 0
BEGIN
	UPDATE titles 
	SET title = replace (@title, '|', 'a') 
	WHERE CURRENT OF cursor_5

	FETCH NEXT FROM cursor_5
	INTO @title
END

CLOSE cursor_5

DEALLOCATE cursor_5

-------------------------------------------------------------------------------
--11. CONSTRAINT

--1. Constraint запрещает добавлять книги без гласных в названии
alter table titles add constraint CK_titles check (title like '%[aeoyiu]%')

--2. Constraint запрещает добавлять авторов, у которых имена или фамилии начинаются не с заглавной буквы
alter table authors add constraint CK_authors check (au_fname like '[A-Z]%' and au_lname like '[A-Z]%')

--3. Constraint запрещает добавлять книги, для которых в указанном жанре уже есть 7 книг
alter procedure get_count_titles (@count_t int out)
as
begin
	set @count_t = (select top 1 count(*) [max_count] 
						from titles group by type 
							order by [max_count] desc)
end

declare @count int
exec get_count_titles @count out
select @count

alter table titles add constraint CK_titles_2 check (get_count_titles < 7)

--4. Constraint запрещает добавлять авторов, если уже есть автор с таким именем и фамилией и штатом
alter table authors add constraint CK_authors_2 unique (au_fname, au_lname, state)

-------------------------------------------------------------------------------
--12. 

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


