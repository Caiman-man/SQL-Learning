--8. TRIGGERS-2

--1. Триггер разрешает добавл¤ть только те книги, у которых цена положительная
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

--2. Триггер разрешает добавлять только те книги, у которых цена выше средней
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

--3. Триггер запрещает удалять издателей, если у них есть книги
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

--4. Триггер запрещает изменять книги в жанре 'Business'
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

--5. Триггер запрещает делать книги дешевле!
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