--7. TRIGGERS

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