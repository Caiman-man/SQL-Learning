--6. FUNCTIONS and VIEWS

--1. Хранимая функция возвращает название самой дешёвой книги
create function min_price_title()
returns table
as
	return select title from titles where price = (select min(price) from titles)

select * from min_price_title()

drop function min_price_title

--2. Хранимая процедура меняет местами цены самой дорогой и самой дешёвой книги
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

--3. Хранимая функция возвращает список всех штатов, где живут авторы, не написавшие ни одной книги
create function states()
returns table
as
	return select distinct state
			from authors left join titleauthor 
			on authors.au_id = titleauthor.au_id
			where titleauthor.title_id is null 

select * from states()

drop function states

--4. Хранимая функция возвращает самую дорогую и самую дешёвую книгу в заданном жанре
--результат удалось возвратить только в одном столбце
create function min_max_titles(@type varchar(20))
returns table
as

	return select title, price, type from titles where price = (select min(price) from titles where type = @type) and type = @type
	union
	select title, price, type from titles where price = (select max(price) from titles where type = @type) and type = @type

select * from min_max_titles('business')

drop function min_max_titles