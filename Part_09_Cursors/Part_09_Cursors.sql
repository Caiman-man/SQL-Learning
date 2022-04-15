--09. CURSORS

--1. Курсор добавляет к каждому названию книги год издания в круглых скобках. пример: сказки (1998)
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


--2. Курсор стирает после каждого названия книги год издания вместе со скобками
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


--3. Курсор вычисляет количество букв 'a' в именах авторов
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


--4. Курсор заменяет все буквы 'a' в названиях книг на '|'
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


--5. Курсор заменяет все буквы '|' в названиях книг на 'a'
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