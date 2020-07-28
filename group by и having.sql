/*Группировки и агрегатные функции */
/*1. Посчитать среднюю цену товара, общую сумму продажи по месяцам

Вывести:
* Год продажи 
* Месяц продажи
* Средняя цена за месяц по всем товарам
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.*/
select DATEPART(YYYY,i.InvoiceDate) as 'год',
	   DATEPART(MM,i.InvoiceDate) as 'месяц',
	   AVG(s.UnitPrice) AS 'средняя',
	   SUM(il.UnitPrice* il.Quantity) AS 'сумма за период'
from Sales.Invoices i
		inner join sales.InvoiceLines il
		on il.InvoiceId=i.InvoiceId
		inner join Warehouse.StockItems s
		on s.StockItemID=il.StockItemID
group by DATEPART(YYYY,i.InvoiceDate), DATEPART(MM,i.InvoiceDate)
order by DATEPART(YYYY,i.InvoiceDate), DATEPART(MM,i.InvoiceDate)




/*2. Отобразить все месяцы, где общая сумма продаж превысила 10 000 

Вывести:
* Год продажи 
* Месяц продажи
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.*/
select DATEPART(YYYY,i.InvoiceDate) as 'год',
	   DATEPART(MM,i.InvoiceDate) as 'месяц',
		SUM(il.UnitPrice) AS 'общая сумма продаж'
from Sales.Invoices i
inner join sales.InvoiceLines il
		on il.InvoiceId=i.InvoiceId
group by DATEPART(YYYY,i.InvoiceDate), DATEPART(MM,i.InvoiceDate)
having SUM(il.UnitPrice)>10000
order by DATEPART(YYYY,i.InvoiceDate), DATEPART(MM,i.InvoiceDate)



/*3. Вывести сумму продаж, дату первой продажи и количество проданного по месяцам, по товарам, продажи которых менее 50 ед в месяц. 
Группировка должна быть по году, месяцу, товару.

Вывести:
* Год продажи 
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи 
* Количество проданного 
Продажи смотреть в таблице Sales.Invoices и связанных таблицах.*/

select DATEPART(YYYY,i.InvoiceDate) as 'год',
	   DATEPART(MM,i.InvoiceDate) as 'месяц',
	   s.StockItemName,
	   SUM(il.UnitPrice) AS 'сумма продаж',
	  (select top 1 InvoiceDate  from Sales.Invoices ) as 'kio',
	   COUNT(il.Quantity) as 'количество проданного',
	   min (i.InvoiceDate)
from Sales.Invoices i
		inner join sales.InvoiceLines il
		on il.InvoiceId=i.InvoiceId
		inner join Warehouse.StockItems s
		on s.StockItemID=il.StockItemID
group by DATEPART(YYYY,i.InvoiceDate), DATEPART(MM,i.InvoiceDate),s.StockItemName
having COUNT(il.Quantity) <50
order by DATEPART(YYYY,i.InvoiceDate), DATEPART(MM,i.InvoiceDate),s.StockItemName



/*4. Написать рекурсивный CTE sql запрос и заполнить им временную таблицу и табличную переменную
Дано :
CREATE TABLE dbo.MyEmployees 
( 
EmployeeID smallint NOT NULL, 
FirstName nvarchar(30) NOT NULL, 
LastName nvarchar(40) NOT NULL, 
Title nvarchar(50) NOT NULL, 
DeptID smallint NOT NULL, 
ManagerID int NULL, 
CONSTRAINT PK_EmployeeID PRIMARY KEY CLUSTERED (EmployeeID ASC) 
); 

INSERT INTO dbo.MyEmployees VALUES 
(1, N'Ken', N'Sánchez', N'Chief Executive Officer',16,NULL) 
,(273, N'Brian', N'Welcker', N'Vice President of Sales',3,1) 
,(274, N'Stephen', N'Jiang', N'North American Sales Manager',3,273) 
,(275, N'Michael', N'Blythe', N'Sales Representative',3,274) 
,(276, N'Linda', N'Mitchell', N'Sales Representative',3,274) 
,(285, N'Syed', N'Abbas', N'Pacific Sales Manager',3,273) 
,(286, N'Lynn', N'Tsoflias', N'Sales Representative',3,285) 
,(16, N'David',N'Bradley', N'Marketing Manager', 4, 273) 
,(23, N'Mary', N'Gibson', N'Marketing Specialist', 4, 16); 

Результат вывода рекурсивного CTE:
EmployeeID Name Title EmployeeLevel
1 Ken Sánchez Chief Executive Officer 1
273 | Brian Welcker Vice President of Sales 2
16 | | David Bradley Marketing Manager 3
23 | | | Mary Gibson Marketing Specialist 4
274 | | Stephen Jiang North American Sales Manager 3
276 | | | Linda Mitchell Sales Representative 4
275 | | | Michael Blythe Sales Representative 4
285 | | Syed Abbas Pacific Sales Manager 3
286 | | | Lynn Tsoflias Sales Representative 4
*/

    WITH TestCTE(EmployeeID, FirstName,LastName, Title, ManagerID,DeptID, EmployeeLevel)
   AS
   (    
        
        SELECT EmployeeID,FirstName,LastName, Title, ManagerID,DeptID, 1 AS EmployeeLevel 
        FROM dbo.MyEmployees  
		WHERE ManagerID IS NULL 
        UNION ALL
       
        SELECT t1.EmployeeID,t1.FirstName, t1.LastName, t1.Title, t1.ManagerID,t1.DeptID, t2.EmployeeLevel + 1 
        FROM dbo.MyEmployees  t1 
        JOIN TestCTE t2 ON t1.ManagerID=t2.EmployeeID 
	   ) 
   SELECT EmployeeID,case   
									when EmployeeLevel=1 then  ''
									when EmployeeLevel=2 then  '|'
									when EmployeeLevel=3 then  '||'
									when EmployeeLevel=4 then  '|||'
								end
   ,FirstName+''+LastName as Name, Title,EmployeeLevel  INTO #MyEmployees
   FROM TestCTE   
   ORDER BY 5


    select * from #MyEmployees


/*Опционально:
Написать запросы 1-3 так, чтобы если в каком-то месяце не было продаж, то этот месяц также отображался бы в результатах, но там были нули.*/