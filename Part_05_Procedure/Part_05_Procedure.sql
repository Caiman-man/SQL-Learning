--5. PROCEDURE

--1 Хранимая процедура удаляет автора и его книги
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

--2 Хранимая процедура увеличивает цену всех книг указанного диапазона цен на $2
create procedure increase_price(@price1 money, @price2 money)
as
begin
	update titles
	set price += 2
	where price > @price1 and price < @price2
end

exec increase_price 1, 100

--3 Хранимая процедура добавляет книгу указанному автору
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

--4 Хранимая процедура возвращает количество книг и среднюю цену книг авторов из указанного штата
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

--5 хранимая процедура удаляет книги заданного жанра и возвращает количество удалЄнных книг
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