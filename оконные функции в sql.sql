/*Оконные функции в SQL */

/*1. Напишите запрос с временной таблицей и перепишите его с табличной переменной. Сравните планы. 
В качестве запроса с временной таблицей и табличной переменной можно взять свой запрос или следующий запрос:
Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года (в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки)
Выведите id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом
Пример 
Дата продажи Нарастающий итог по месяцу
2015-01-29 4801725.31
2015-01-30 4801725.31
2015-01-31 4801725.31
2015-02-01 9626342.98
2015-02-02 9626342.98
2015-02-03 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/

drop table if exists #SumAscItog
; with cte as (select distinct	si.InvoiceId, 
								si.InvoiceDate, 
								si.CustomerID, 
								sc.CustomerName, 
			  (select sum(ct.TransactionAmount)
			   from Sales.Invoices i
									join Sales.CustomerTransactions ct on i.InvoiceID =	ct.InvoiceID
			   where month(i.InvoiceDate) = month(si.InvoiceDate) and day(i.InvoiceDate) = day(si.InvoiceDate) and InvoiceDate >= '2015.01.01'
			   group by month(i.InvoiceDate), day(i.InvoiceDate)) as SumAscItog
from Sales.Invoices AS si
						join Sales.Customers sc on si.CustomerID = sc.CustomerID
where si.InvoiceDate >= '2015-01-01')

select * into #SumAscItog from cte
select * from #SumAscItog order by InvoiceID;


--Запрос с табличной переменной

declare @SumAscItog table
(
	InvoiceID int not null,
	InvoiceDate date not null,
	CustomerID int not null,
	CustomerName nvarchar(100) not null,
	SumAscItog float not null
)
; with cte as(
				select distinct	si.InvoiceId, 
								si.InvoiceDate, 
								si.CustomerID, 
								sc.CustomerName, 
				(select sum(ct.TransactionAmount)
					from Sales.Invoices i
						join Sales.CustomerTransactions ct on i.InvoiceID =	ct.InvoiceID
							where month(i.InvoiceDate) = month(si.InvoiceDate) and day(i.InvoiceDate) = day(si.InvoiceDate) and InvoiceDate >= '2015.01.01'
								group by month(i.InvoiceDate), day(i.InvoiceDate)) as SumAscItog
from Sales.Invoices AS si
	join Sales.Customers sc on si.CustomerID = sc.CustomerID
		where si.InvoiceDate >= '2015-01-01')

insert into @SumAscItog select * from cte
select * from @SumAscItog order by InvoiceID;


/*
2. Если вы брали предложенный выше запрос, то сделайте расчет суммы нарастающим итогом с помощью оконной функции.
Сравните 2 варианта запроса - через windows function и без них. Написать какой быстрее выполняется, сравнить по set statistics time on;
*/

--Запрос с оконной функцией

select distinct si.InvoiceId, 
				si.InvoiceDate, 
				si.CustomerID, 
				sc.CustomerName, 
				(sum(ct.TransactionAmount) over (order by Month(InvoiceDate))) as SumAscItog
from Sales.Invoices as si
						join Sales.Customers sc on si.CustomerID = sc.CustomerID
						join Sales.CustomerTransactions ct on si.InvoiceID = ct.InvoiceID
where si.InvoiceDate >= '2015-01-01'
order by si.InvoiceId, si.InvoiceDate;

--Запрос с подзапросом

select distinct	si.InvoiceId, 
				si.InvoiceDate, 
				si.CustomerID, 
				sc.CustomerName, 
				(select sum(ct.TransactionAmount)
				 from Sales.Invoices i
									join Sales.CustomerTransactions ct on i.InvoiceID =	ct.InvoiceID
				where month(i.InvoiceDate) = month(si.InvoiceDate) and day(i.InvoiceDate) = day(si.InvoiceDate) and InvoiceDate >= '2015.01.01'
				group by month(i.InvoiceDate), day(i.InvoiceDate)) as SumAscItog
from Sales.Invoices AS si
						join Sales.Customers sc on si.CustomerID = sc.CustomerID
where si.InvoiceDate >= '2015-01-01'


/*
3. Вывести список 2х самых популярных продуктов (по кол-ву проданных) в каждом месяце за 2016й год (по 2 самых популярных продукта в каждом месяце)
*/
select * 
from  (select	si.StockItemID, 
				si.StockItemName, 
				il.Quantity,				
				month (i.InvoiceDate) as monthh, 
				year (i.InvoiceDate) as yeaar,
				ROW_NUMBER() Over (Partition by month(i.InvoiceDate) Order by il.Quantity Desc) as RowNumber
	   from Sales.Invoices i
							join Sales.InvoiceLines il on il.InvoiceID = i.InvoiceID
							join Warehouse.StockItems si on si.StockItemID = il.StockItemID
	   where  year(i.InvoiceDate) = '2016' ) as tbl
where  RowNumber <= 2

/*
4. Функции одним запросом
Посчитайте по таблице товаров, в вывод также должен попасть ид товара, название, брэнд и цена
пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново +
посчитайте общее количество товаров и выведете полем в этом же запросе +
посчитайте общее количество товаров в зависимости от первой буквы названия товара +
отобразите следующий id товара исходя из того, что порядок отображения товаров по имени ?
предыдущий ид товара с тем же порядком отображения (по имени)
названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items" +
сформируйте 30 групп товаров по полю вес товара на 1 шт +
Для этой задачи НЕ нужно писать аналог без аналитических функций
*/



select ws.StockItemID, ws.StockItemName, ws.Brand, ws.UnitPrice, 
	   row_number() OVER (partition by left(StockItemName,1) order by ws.StockItemName  DESC) as 'Numbering'
	   ,count(QuantityPerOuter) over(   ) as'Count_all'
	   ,count(QuantityPerOuter) over(partition by left(StockItemName,1)   ) as'Count_QuantityPerOuter' 
	   ,lead(StockItemID) over (order by  StockItemID  ) as 'Next product id'
	   ,lag(StockItemName,2, 'No items') over(order by  StockItemName )  as 'Product names 2 lines ago'
	   ,ntile(30)  OVER (ORDER BY TypicalWeightPerUnit) AS 'GroupNumber'
from Warehouse.StockItems as ws

/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал
В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки
*/
select *
from (
		select o.SalespersonPersonID,
			   p.FullName,
			   o.CustomerID, 
			   c.CustomerName,
			   o.OrderDate, 
			   ol.Quantity * ol.UnitPrice as Total,
			   ROW_NUMBER() over(partition by o.SalespersonPersonID order by o.OrderDate desc) as LastSalCust
		from Sales.Orders o
							join Sales.OrderLines ol on o.OrderID = ol.OrderID
							join Application.People p on o.SalespersonPersonID = p.PersonID
							join Sales.Customers c on o.CustomerID = c.CustomerID) as tabl
where LastSalCust = 1;


/*
6. Выберите по каждому клиенту 2 самых дорогих товара, которые он покупал
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки customer
*/
select *
from (select  i.CustomerID, 
			  sc.CustomerName, 
			  si.StockItemID,
			  si.UnitPrice,
			  i.InvoiceDate,  
			  row_number() over (partition by i.CustomerID order by si.UnitPrice desc) as CustTrans
	  from Sales.InvoiceLines il
								join Warehouse.StockItems si on il.StockItemID = si.StockItemID 
								join Sales.Invoices i on il.InvoiceID = i.InvoiceID
								join Sales.Customers sc on i.CustomerID = sc.CustomerID) as tabl
	  where CustTrans <= 2

