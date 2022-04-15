--10. CONSTRAINT

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