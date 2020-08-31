/*������� ������� � SQL */

/*1. �������� ������ � ��������� �������� � ���������� ��� � ��������� ����������. �������� �����. 
� �������� ������� � ��������� �������� � ��������� ���������� ����� ����� ���� ������ ��� ��������� ������:
������� ������ ����� ������ ����������� ������ �� ������� � 2015 ���� (� ������ ������ ������ �� ����� ����������, ��������� ����� � ������� ������� �������)
�������� id �������, �������� �������, ���� �������, ����� �������, ����� ����������� ������
������ 
���� ������� ����������� ���� �� ������
2015-01-29 4801725.31
2015-01-30 4801725.31
2015-01-31 4801725.31
2015-02-01 9626342.98
2015-02-02 9626342.98
2015-02-03 9626342.98
������� ����� ����� �� ������� Invoices.
����������� ���� ������ ���� ��� ������� �������.
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


--������ � ��������� ����������

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
2. ���� �� ����� ������������ ���� ������, �� �������� ������ ����� ����������� ������ � ������� ������� �������.
�������� 2 �������� ������� - ����� windows function � ��� ���. �������� ����� ������� �����������, �������� �� set statistics time on;
*/

--������ � ������� ��������

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

--������ � �����������

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
3. ������� ������ 2� ����� ���������� ��������� (�� ���-�� ���������) � ������ ������ �� 2016� ��� (�� 2 ����� ���������� �������� � ������ ������)
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
4. ������� ����� ��������
���������� �� ������� �������, � ����� ����� ������ ������� �� ������, ��������, ����� � ����
������������ ������ �� �������� ������, ��� ����� ��� ��������� ����� �������� ��������� ���������� ������ +
���������� ����� ���������� ������� � �������� ����� � ���� �� ������� +
���������� ����� ���������� ������� � ����������� �� ������ ����� �������� ������ +
���������� ��������� id ������ ������ �� ����, ��� ������� ����������� ������� �� ����� ?
���������� �� ������ � ��� �� �������� ����������� (�� �����)
�������� ������ 2 ������ �����, � ������ ���� ���������� ������ ��� ����� ������� "No items" +
����������� 30 ����� ������� �� ���� ��� ������ �� 1 �� +
��� ���� ������ �� ����� ������ ������ ��� ������������� �������
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
5. �� ������� ���������� �������� ���������� �������, �������� ��������� ���-�� ������
� ����������� ������ ���� �� � ������� ����������, �� � �������� �������, ���� �������, ����� ������
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
6. �������� �� ������� ������� 2 ����� ������� ������, ������� �� �������
� ����������� ������ ���� �� ������, ��� ��������, �� ������, ����, ���� ������� customer
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

