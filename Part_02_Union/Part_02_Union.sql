--2. UNION

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