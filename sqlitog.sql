Какие самолеты имеют более 50 посадочных мест?
Jaká letadla mají více než 50 sedadel?


select aircraft_code
from(
select *,
row_number()over(partition by aircraft_code order by seat_no)
from seats) ss
where row_number>50
group by 1


В каких аэропортах есть рейсы, в рамках которых можно добраться бизнес - классом дешевле, чем эконом - классом?
V kterých letištích jsou lety, které umožňují cestování v business třídě levněji než v ekonomické třídě?
 
Таких аэропортов и рейсов нет
Neexistují žádná letiště ani lety, které by splňovaly tato kritéria.


with cte1 as
(select flight_id,fare_conditions,amount
from ticket_flights
where fare_conditions ilike '%Business%'),
cte2 as
(select *
from ticket_flights
where fare_conditions ilike '%Economy%')
select x.flight_id,departure_airport
from cte1 x
join cte2 y on x.flight_id=y.flight_id
join flights fl on x.flight_id=fl.flight_id
where x.amount<y.amount
group by x.flight_id,departure_airport


Есть ли самолеты, не имеющие бизнес - класса?
 Existují letadla, která nemají business třídu?


select aircraft_code as "Самолет", array_agg
from (select aircraft_code , array_agg(fare_conditions)
from seats
group by 1) ac
where 'Business' !=all(array_agg)
group by 1,2



Найдите количество занятых мест для каждого рейса,
процентное отношение количества занятых мест к общему количеству мест в самолете,
добавьте накопительный итог вывезенных пассажиров по каждому аэропорту на каждый день.

Prosím, zjistěte počet obsazených sedadel na každém letu, procentuální podíl obsazených
sedadel vůči celkovému počtu sedadel ve letadle, a také kumulativní počet přepravených 
pasažérů pro každé letiště každý den. 


select bp.flight_id, count(seat_no) as "Кол-во занятых мест","Общее кол-во мест",
(count(seat_no)*100/"Общее кол-во мест") as "%", ss.actual_departure, ss.departure_airport,
sum(count(seat_no))over(order by departure_airport, actual_departure::date) as "Вывезенные пассажиры"
from 
 (select count(seat_no) as "Общее кол-во мест",flight_id,actual_departure::date,fl.departure_airport
from seats s
join flights fl on s.aircraft_code=fl.aircraft_code
group by 2,3) ss
join boarding_passes bp on ss.flight_id=bp.flight_id
group by 1,3,5,6

Найдите процентное соотношение перелетов по маршрутам от общего количества перелетов.
Выведите в результат названия аэропортов и процентное отношение.

 Zjistěte také procentuální rozložení letů podle tras vzhledem k celkovému počtu letů. 
 Výsledkem bude výpis názvů letišť a procentuálního podílu.

select arrival_airport, departure_airport,a.airport_name,a2.airport_name,
count(f.flight_id) as "Кол-во перелетов", round(count(f.flight_id)*100/sum(count(f.flight_id))over(),3) as "% от всех перелетов"
from flights f
join airports a on a.airport_code = f.departure_airport
join airports a2 on a2.airport_code = f.arrival_airport 
group by 1,2,3,4

Выведите количество пассажиров по каждому коду сотового оператора, если учесть, что код оператора - это три символа после +7
Vypište počet pasažérů pro každý kód mobilního operátora s přihlédnutím k tomu, že kód operátora je tři znaky za +7.

select count(passenger_id) as "количество пассажиров",(substring(contact_data->>'phone' from 3 for 3)) as " код оператора"
from tickets
group by 2

Между какими городами не существует перелетов?
Mezi kterými městy neexistují lety?


select a.city as "Город 1",a2.city as "Город 2"
from airports a,airports a2
where a.city  > a2.city 
group by 1,2
except
select a.city as "Город 1",a1.city as "Город 2"
from flights f
join airports a on f.departure_airport=a.airport_code
join airports a1 on f.arrival_airport=a1.airport_code
group by 1,2


Классифицируйте финансовые обороты (сумма стоимости билетов) по маршрутам:
До 50 млн - low
От 50 млн включительно до 150 млн - middle
От 150 млн включительно - high
Выведите в результат количество маршрутов в каждом классе.

Klasifikujte finanční obraty (celkovou cenu letenek) podle tras:
Do 50 milionů - low
Od 50 milionů včetně do 150 milionů - middle
Od 150 milionů včetně - high
Vypište výsledky s počtem tras v každé kategorii.


select l."Классификация", f.arrival_airport,f.departure_airport, count(*)
from (select f.flight_id,sum(amount) as "сумма стоимости билетов",
 case
	when sum(amount) < 50000000 then 'low'
	when sum(amount) >= 50000000 and sum(amount) >= 150000000  then 'middle'
	else 'high'
end "Классификация"
from flights f
left join ticket_flights tf on f.flight_id=tf.flight_id 
group by 1) l
right join flights f on l.flight_id=f.flight_id
group by 1,2,3



Выведите пары городов между которыми расстояние более 5000 км
Vypište páry měst, mezi kterými je vzdálenost větší než 5000 km.


with cte1 as (
select rad.city1 as city1,rad.city2 as city2,
(6371*(acos(
sin(aradianalat)*sin((bradianalat))
+ 
cos(aradianalat)*cos(bradianalat)*cos(aradianalong - bradianalong)
))) as L
from (
select radians(a.longitude) as aradianalong,radians(a.latitude) as aradianalat,
radians(b.longitude) as bradianalong,radians(b.latitude) as bradianalat,a.city as city1,b.city as city2
from airports a, airports b
where  a.city>b.city) rad)
select x.city1,x.city2,x.l
from airports a 
join cte1 x on a.city = x.city1
where l>5000


