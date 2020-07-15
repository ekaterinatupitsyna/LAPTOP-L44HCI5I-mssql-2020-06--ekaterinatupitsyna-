---------------------------------������ �1-----------------------------------------------------------------------------
/*��� ������, � �������� ������� ���� "urgent" ��� �������� ���������� � "Animal" �������: Warehouse.StockItems. */
select StockItemID,StockItemName 
from Warehouse.StockItems
where (StockItemName like '%urgent%') or (StockItemName like 'Animal%')


---------------------------------������ �2------------------------------------------------------------------------------
/*����������� (Suppliers), � ������� �� ���� ������� �� ������ ������ (PurchaseOrders).-----------------------------------
������� ����� JOIN, � ����������� ������� ������� �� �����.�������: Purchasing.Suppliers, Purchasing.PurchaseOrders.*/
select b.SupplierID , SupplierName
from Purchasing.Suppliers a 
left join Purchasing.PurchaseOrders b on a.SupplierID =b.SupplierID 
where b.SupplierID is  null

---------------------------------������ �3------------------------------------------------------------------------------
/*������ (Orders) � ����� ������ ����� 100$ ���� ����������� ������ ������ ����� 20 ���� 
� �������������� ����� ������������ ����� ������ (PickingCompletedWhen). 
�������:
* OrderID
* ���� ������ � ������� ��.��.����
* �������� ������, � ������� ���� �������
* ����� ��������, � �������� ��������� �������
* ����� ����, � ������� ��������� ���� ������� (������ ����� �� 4 ������) ???????
* ��� ��������� (Customer)
�������� ������� ����� ������� � ������������ ��������, ��������� ������ 1000 � ��������� ��������� 100 �������. 
���������� ������ ���� �� ������ ��������, ����� ����, ���� ������ (����� �� �����������). 
�������: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/
select a.OrderID, CONVERT(char(10), a.OrderDate, 104) as Date, 
datename(m,ExpectedDeliveryDate) as Month, DATEPART ( quarter , ExpectedDeliveryDate ) as Quarter,

  CASE
    WHEN MONTH (ExpectedDeliveryDate) < 5  THEN 1
	WHEN MONTH (ExpectedDeliveryDate)>10   THEN 3
	else  2
  END Thirdyear,
  c.CustomerName
from Sales.Orders a  join Sales.OrderLines b on a.OrderID=b.OrderID   join  Sales.Customers c on a.CustomerID=c.CustomerID 
where (b.UnitPrice>100) or (b.PickedQuantity>20)
order by Quarter , Date
  offset  1000 rows
  fetch next 100 rows only  

---------------------------------������ �4---------------------------------------------
/*������ ����������� (Purchasing.Suppliers), ������� ���� ��������� � ������ 2014 ���� 
� ��������� Air Freight ��� Refrigerated Air Freight (DeliveryMethodName).
�������:
* ������ �������� (DeliveryMethodName) +
* ���� ��������+
* ��� ����������+
* ��� ����������� ���� ������������ ����� (ContactPerson)+
�������: Purchasing.Suppliers, Purchasing.PurchaseOrders   ExpectedDeliveryDate, Application.DeliveryMethods, Application.People.*/

select DeliveryMethodName, ExpectedDeliveryDate, SupplierName, FullName
from Application.DeliveryMethods a 
inner join Purchasing.PurchaseOrders b on a.DeliveryMethodID=b.DeliveryMethodID                                 
inner join Purchasing.Suppliers c on c.SupplierID=b.SupplierID
inner join Application.People d ON b.ContactPersonID = d.PersonID
where 
(DeliveryMethodName='Air Freight' or DeliveryMethodName='Refrigerated Air Freight') 
and (b.ExpectedDeliveryDate between '2014-01-01' and '2014-01-31' )

-----------------------------------������ �5---------------------------------------------
/*������ ��������� ������ (�� ����)+� ������ ������� +� ������ ����������, ������� ������� ����� (SalespersonPerson). */
select top(10) OrderDate, CustomerName,p.FullName
from sales.Orders o join sales.Customers c on o.CustomerID=c.CustomerID
                    join Application.People p on o.ContactPersonID=p.PersonID
order by OrderDate desc


-----------------------------------������ �6-------------------------------------------------------------------------------------------------------------
/* ��� �� � ����� �������� � �� ���������� ��������, ������� �������� ����� Chocolate frogs 250g.
��� ������ �������� � Warehouse.StockItems.*/ 
select SO.CustomerID, CustomerName, AP.PhoneNumber, AP.FaxNumber, StockItemName
from Sales.Orders so
join Sales.Customers sc on so.CustomerID = sc.CustomerID
join Application.People AP on so.LastEditedBy = AP.PersonID
join (select ws.StockItemID, ws.StockItemName,SOL.OrderID, SOL.PickedQuantity, SOL.UnitPrice
      from Warehouse.StockItems ws
      join Sales.OrderLines SOL on SOL.StockItemID = ws.StockItemID) as StockItems
      on so.OrderID = StockItems.OrderID
      where StockItemName = 'Chocolate frogs 250g'

