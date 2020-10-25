--Pivot и Cross Apply
/*
1. Требуется написать запрос, который в результате своего выполнения формирует таблицу следующего вида:
Название клиента Месяц Год Количество покупок 
Клиентов взять с ID 2-6, это все подразделение Tailspin Toys
имя клиента нужно поменять так чтобы осталось только уточнение
например исходное Tailspin Toys (Gasport, NY) - вы выводите в имени только Gasport,NY  
дата должна иметь формат dd.mm.yyyy например 25.12.2019
*/

select * from (
select sc.CustomerID CustomerID ,InvoiceID InvoiceID,SUBSTRING(sc.CustomerName, 16,LEN(sc.CustomerName)-16) name, format(InvoiceDate, 'dd-mm-yyy') date
from sales.Customers sc join Sales.Invoices si on sc.CustomerID=si.CustomerID
where sc.CustomerID  between 2 and 6
			  )as t
pivot(count(InvoiceID)
for  CustomerID in ([2], [3],[4],[5],[6])) 
as pvt

/*
2. Для всех клиентов с именем, в котором есть Tailspin Toys
вывести все адреса, которые есть в таблице, в одной колонке
*/

select * from (
				select   [CustomerName]
						,[DeliveryAddressLine1] 
						,[DeliveryAddressLine2] 
						,[PostalAddressLine1]	
						,[PostalAddressLine2]	
				from sales.Customers 
				where CustomerName like '%Tailspin Toys%'
			  ) as t
unpivot 
(
AddressLine  for typeAddress  in (DeliveryAddressLine1,DeliveryAddressLine2,PostalAddressLine1,PostalAddressLine2

) 
)as unpt



/*
3. В таблице стран есть поля с кодом страны цифровым и буквенным
сделайте выборку ИД страны, название, код - чтобы в поле был либо цифровой либо буквенный код
*/
select *
from 
		(select  [CountryID]
				,[IsoAlpha3Code]
				,[CountryName]
				,cast([IsoNumericCode] as nvarchar(3)) as [IsoNumericCode]
		 from Application.Countries
		
		) as t
unpivot 
(
code for type in ([IsoAlpha3Code],[IsoNumericCode] )

)as unpt
/*
4. Перепишите ДЗ из оконных функций через CROSS APPLY
Выберите по каждому клиенту 2 самых дорогих товара, которые он покупал
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки
*/

SELECT c.CustomerID,c.CustomerName, i.StockItemName, i.UnitPrice,i.InvoiceDate
FROM Sales.Customers c
CROSS APPLY (SELECT TOP 2 si.StockItemName,si.StockItemID,
       si.UnitPrice, i.InvoiceDate
       FROM Sales.Invoices i
       JOIN Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID
       JOIN Warehouse.StockItems si ON  il.StockItemID = si.StockItemID
       WHERE il.StockItemID = si.StockItemID and i.CustomerID = c.CustomerID
       ORDER BY si.UnitPrice desc) as i
ORDER BY CustomerID, i.InvoiceDate





		