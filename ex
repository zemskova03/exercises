пару задач с сайта sql-ex, которые ,как мне кажется, являются интересными
51.Найдите названия кораблей, имеющих наибольшее число орудий среди всех имеющихся кораблей такого же водоизмещения (учесть корабли из таблицы Outcomes).

Select country, cast(avg((power(bore,3)/2)) as numeric(6,2))  from
(select country, classes.class, bore, name from classes left join ships on classes.class=ships.class
union all
select distinct country, class, bore, ship from classes t1 left join outcomes t2 on t1.class=t2.ship
where ship=class and ship not in (select name from ships) ) a
where name is not null 
group by country


32.Одной из характеристик корабля является половина куба калибра его главных орудий (mw).
С точностью до 2 десятичных знаков определите среднее значение mw для кораблей каждой страны, у которой есть корабли в базе данных.

WITH a AS 
(SELECT C.country, C.class, S.name, POWER(C.bore, 3)/2 as b  FROM Classes AS C 
	 INNER JOIN Ships AS S ON C.class=S.class
	 UNION 
SELECT C.country, C.class, O.ship, POWER(C.bore, 3)/2 as b FROM Classes AS C 
	  INNER JOIN Outcomes AS O ON C.class=O.ship)
SELECT country, CAST(AVG(b) AS numeric(10,2))
FROM a
GROUP BY country;


66.Для всех дней в интервале с 01/04/2003 по 07/04/2003 определить число рейсов из Rostov с пассажирами на борту.
Вывод: дата, количество рейсов.
SELECT date, max(C) 
FROM
(SELECT date,COUNT(*) AS C FROM Trip,
(SELECT trip_no,date 
FROM Pass_in_trip 
WHERE date BETWEEN '2003-04-01' AND '2003-04-07' 
GROUP BY trip_no, date) AS t1
WHERE Trip.trip_no=t1.trip_no AND town_from='Rostov'
GROUP BY date
UNION ALL
SELECT '2003-04-01',0
UNION ALL
SELECT '2003-04-02',0
UNION ALL
SELECT '2003-04-03',0
UNION ALL
SELECT '2003-04-04',0
UNION ALL
SELECT '2003-04-05',0
UNION ALL
SELECT '2003-04-06',0
UNION ALL
SELECT '2003-04-07',0) AS t2
GROUP BY date;


1.(рейт)Дима и Миша пользуются продуктами от одного и того же производителя.
Тип Таниного принтера не такой, как у Вити, но признак "цветной или нет" - совпадает.
Размер экрана Диминого ноутбука на 3 дюйма больше Олиного.
Мишин ПК в 4 раза дороже Таниного принтера.
Номера моделей Витиного принтера и Олиного ноутбука отличаются только третьим символом.
У Костиного ПК скорость процессора, как у Мишиного ПК; объем жесткого диска, как у Диминого ноутбука; объем памяти, как у Олиного ноутбука, а цена - как у Витиного принтера.
Вывести все возможные номера моделей Костиного ПК.
select distinct k.model
from 
(select prod.maker, l.hd, l.screen
      from product prod
          join laptop l on l.model = prod.model) d,
          
(select prod.maker, pc.speed, pc.price
      from product prod
          join pc on pc.model = prod.model) m,
          
(select color, type, price
      from printer) t,
      
(select model, color, type, price
      from printer) v,
      
(select model, ram, screen
      from laptop) o,
      
(select model, speed, ram, hd, price
      from pc) k
      
where d.maker = m.maker
    and t.type <> v.type and t.color = v.color
    and d.screen = o.screen + 3
    and m.price = 4 * t.price
    and stuff(v.model, 3, 1, '') = stuff(o.model, 3, 1, '')
    and k.speed = m.speed and k.hd = d.hd and k.ram = o.ram and k.price = v.price



 4. Посчитать сумму цифр в номере каждой модели из таблицы Product
Вывод: номер модели, сумма цифр
Для этой задачи запрещено использовать: CTE
select model,
       (len(replace(model, '1', '**')) - len(model)) * 1
       + (len(replace(model, '2', '**')) - len(model)) * 2
       + (len(replace(model, '3', '**')) - len(model)) * 3
       + (len(replace(model, '4', '**')) - len(model)) * 4
       + (len(replace(model, '5', '**')) - len(model)) * 5
       + (len(replace(model, '6', '**')) - len(model)) * 6
       + (len(replace(model, '7', '**')) - len(model)) * 7
       + (len(replace(model, '8', '**')) - len(model)) * 8
       + (len(replace(model, '9', '**')) - len(model)) * 9
from product


35.В таблице Product найти модели, которые состоят только из цифр или только из латинских букв (A-Z, без учета регистра).
Вывод: номер модели, тип модели.

SELECT model, type FROM Product
WHERE model not like '%[^0-9]%' OR upper(model) not  like '%[^A-Z]%'

30.В предположении, что приход и расход денег на каждом пункте приема фиксируется произвольное число раз (первичным ключом в таблицах является столбец code), требуется получить таблицу, в которой каждому пункту за каждую дату выполнения операций будет соответствовать одна строка.
Вывод: point, date, суммарный расход пункта за день (out), суммарный приход пункта за день (inc). Отсутствующие значения считать неопределенными (NULL).

SELECT COALESCE(I.point, O.point) as point,COALESCE(I.date, O.date) as date
,out,inc FROM (select point,date,sum(inc) as inc from income 
group by point,date)  AS I
FULL JOIN (select point,date,sum(out) as out from outcome
group by point,date)  AS O ON I.point=O.point
AND I.date=O.date

39.Найдите корабли, `сохранившиеся для будущих сражений`; т.е. выведенные из строя в одной битве (damaged), они участвовали в другой, произошедшей позже.

select distinct ship from outcomes out
inner join Battles b1 on b1.name=battle
where result='damaged' and 
exists (select ship from outcomes
inner join Battles b2 on b2.name=battle
where b1.date<b2.date and ship=out.ship )
