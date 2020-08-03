--Insert, Update, Merge

use WideWorldImporters
/* 1. Довставлять в базу 5 записей используя insert в таблицу Customers или Suppliers */
INSERT INTO Sales.Customers 
(CustomerID, CustomerName, BillToCustomerID, CustomerCategoryID, PrimaryContactPersonID, DeliveryMethodID, DeliveryCityID,
 PostalCityID, CreditLimit, AccountOpenedDate, StandardDiscountPercentage, IsStatementSent,IsOnCreditHold, PaymentDays, 
 PhoneNumber, FaxNumber, DeliveryRun, RunPosition, WebsiteURL, DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, 
 PostalAddressLine1, PostalAddressLine2, PostalPostalCode, LastEditedBy)
VALUES 
(NEXT VALUE FOR Sequences.CustomerID, 'Michael Jackson',NEXT VALUE FOR Sequences.CustomerID,6, 3256,3,3714,3714,4000,'2016-06-25',0,0,0,7,'(206) 555-0100','(206) 555-0101','','','http://www.microsoft.com/','Shop 30','278 Jackson Street','90298','PO Box 7789','Nadaville','90273',1),
(NEXT VALUE FOR Sequences.CustomerID, 'Sergei Mikhailov',NEXT VALUE FOR Sequences.CustomerID,6,3138,3,1827,1827,1928,'2016-10-11',0,0,0,7,'(203) 555-0100','(203) 555-0101','','','http://www.microsoft.com/','Shop 14','15  Bruno Street','90012','PO Box 751','Selmaville','90922',1),
(NEXT VALUE FOR Sequences.CustomerID, 'Victor Sokolov',NEXT VALUE FOR Sequences.CustomerID,5,3214,3,1982,1982,2913,'2016-08-11',0,0,0,7,'(207) 555-0100','(207) 555-0101','','','http://www.microsoft.com/','Suite 12','918 Manson Street','90008','PO Box 097','Anupamville','90027',1),
(NEXT VALUE FOR Sequences.CustomerID, 'Evgeny Soloviev',NEXT VALUE FOR Sequences.CustomerID,4,3168,3,2983,2983,1827,'2016-09-11',0,0,0,7,'(204) 555-0100','(204) 555-0101','','','http://www.microsoft.com/','Unit 10','829  Jordan Street','90309','PO Box 796','Baalaamjaliville','90056',1),
(NEXT VALUE FOR Sequences.CustomerID, 'Alexander Argor',NEXT VALUE FOR Sequences.CustomerID,5,3240,3,2117,2117,1990,'2016-07-11',0,0,0,7,'(211) 555-0100','(211) 555-0101','','','http://www.microsoft.com/','Shop 22','45  Yashin Street','90607','PO Box 78','Irmaville','90201',1)


/* 2. удалите 1 запись из Customers, которая была вами добавлена*/
delete from Sales.Customers where CustomerID=1067 
/* удален 'Alexander Argor' */

/* 3. изменить одну запись, из добавленных через UPDATE*/
update Sales.Customers set CustomerName='Victor Semyonov' where CustomerID=1063
/* изменен 'Michael Jackson' */

/* 4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть*/
merge Sales.Customers AS target
using (select CustomerID, CustomerName, BillToCustomerID, cc.CustomerCategoryID, PrimaryContactPersonID, dm.DeliveryMethodID, DeliveryCityID, PostalCityID, CreditLimit, AccountOpenedDate, StandardDiscountPercentage, IsStatementSent,IsOnCreditHold, PaymentDays, p.PhoneNumber, p.FaxNumber, DeliveryRun, RunPosition, WebsiteURL, DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, PostalAddressLine1, PostalAddressLine2, PostalPostalCode, p.LastEditedBy
    from Sales.Customers c
    JOIN Application.People p ON c.AlternateContactPersonID = p.PersonID and c.PrimaryContactPersonID = p.PersonID
    JOIN Sales.BuyingGroups b ON c.BuyingGroupID = b.BuyingGroupID
    JOIN Sales.CustomerCategories cc ON c.CustomerCategoryID = cc.CustomerCategoryID
    JOIN Application.Cities ac ON c.DeliveryCityID = ac.CityID and c.PostalCityID = ac.CityID
    JOIN Application.DeliveryMethods dm ON c.DeliveryMethodID = dm.DeliveryMethodID)
    as source(CustomerID, CustomerName, BillToCustomerID, CustomerCategoryID, PrimaryContactPersonID, DeliveryMethodID, DeliveryCityID, PostalCityID, CreditLimit, AccountOpenedDate, StandardDiscountPercentage, IsStatementSent,IsOnCreditHold, PaymentDays, PhoneNumber, FaxNumber, DeliveryRun, RunPosition, WebsiteURL, DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, PostalAddressLine1, PostalAddressLine2, PostalPostalCode, LastEditedBy)
    on (target.CustomerID = source.CustomerID)
    when MATCHED
      then update set CustomerID = source.CustomerID,
        CustomerName = source.CustomerName,
        BillToCustomerID = source.BillToCustomerID,
        CustomerCategoryID = source.CustomerCategoryID,
        PrimaryContactPersonID = source.PrimaryContactPersonID,
        DeliveryMethodID = source.DeliveryMethodID,
        DeliveryCityID = source.DeliveryCityID,
        PostalCityID = source.PostalCityID,
        CreditLimit = source.CreditLimit,
        AccountOpenedDate = source.AccountOpenedDate,
        StandardDiscountPercentage = source.StandardDiscountPercentage,
        IsStatementSent = source.IsStatementSent,
        IsOnCreditHold = source.IsOnCreditHold,
        PaymentDays = source.PaymentDays,
        PhoneNumber = source.PhoneNumber,
        FaxNumber = source.FaxNumber,
        DeliveryRun = source.DeliveryRun,
        RunPosition = source.RunPosition,
        WebsiteURL = source.WebsiteURL,
        DeliveryAddressLine1 = source.DeliveryAddressLine1,
        DeliveryAddressLine2 = source.DeliveryAddressLine2,
        DeliveryPostalCode = source.DeliveryPostalCode,
        PostalAddressLine1 = source.PostalAddressLine1,
        PostalAddressLine2 = source.PostalAddressLine2,
        PostalPostalCode = source.PostalPostalCode,
        LastEditedBy = source.LastEditedBy
    when NOT MATCHED
      then insert(CustomerID, CustomerName, BillToCustomerID, CustomerCategoryID, PrimaryContactPersonID, DeliveryMethodID, DeliveryCityID, PostalCityID, CreditLimit, AccountOpenedDate, StandardDiscountPercentage, IsStatementSent,IsOnCreditHold, PaymentDays, PhoneNumber, FaxNumber, DeliveryRun, RunPosition, WebsiteURL, DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, PostalAddressLine1, PostalAddressLine2, PostalPostalCode, LastEditedBy)
      values (source.CustomerID, source.CustomerName, source.BillToCustomerID, source.CustomerCategoryID, source.PrimaryContactPersonID, source.DeliveryMethodID, source.DeliveryCityID, source.PostalCityID, source.CreditLimit, source.AccountOpenedDate, source.StandardDiscountPercentage, source.IsStatementSent,source.IsOnCreditHold, source.PaymentDays, source.PhoneNumber, source.FaxNumber, source.DeliveryRun, source.RunPosition, source.WebsiteURL, source.DeliveryAddressLine1, source.DeliveryAddressLine2, source.DeliveryPostalCode, source.PostalAddressLine1, source.PostalAddressLine2, source.PostalPostalCode, source.LastEditedBy)
    output deleted.*,$action,inserted.*;
/* 5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk inser */
use WideWorldImporters



----

EXEC sp_configure 'show advanced options', 1;  
GO  
-- To update the currently configured value for advanced options.  
RECONFIGURE;  
GO  
-- To enable the feature.  
EXEC sp_configure 'xp_cmdshell', 1;  
GO  
-- To update the currently configured value for this feature.  
RECONFIGURE;  
GO  
----
SELECT @@SERVERNAME
----
exec master..xp_cmdshell 'bcp "[WideWorldImporters].Sales.InvoiceLines" out  "D:\1\InvoiceLines15.txt" -T -w -t";" -S LAPTOP-L44HCI5I\SQL20171'

-----
------

drop table if exists [Sales].[InvoiceLines_BulkDemo]

CREATE TABLE [Sales].[InvoiceLines_BulkDemo](
  [InvoiceLineID] [int] NOT NULL,
  [InvoiceID] [int] NOT NULL,
  [StockItemID] [int] NOT NULL,
  [Description] [nvarchar](100) NOT NULL,
  [PackageTypeID] [int] NOT NULL,
  [Quantity] [int] NOT NULL,
  [UnitPrice] [decimal](18, 2) NULL,
  [TaxRate] [decimal](18, 3) NOT NULL,
  [TaxAmount] [decimal](18, 2) NOT NULL,
  [LineProfit] [decimal](18, 2) NOT NULL,
  [ExtendedPrice] [decimal](18, 2) NOT NULL,
  [LastEditedBy] [int] NOT NULL,
  [LastEditedWhen] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_Sales_InvoiceLines_BulkDemo] PRIMARY KEY CLUSTERED 
(
  [InvoiceLineID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [USERDATA]
) ON [USERDATA]
----

  BULK INSERT [WideWorldImporters].[Sales].[InvoiceLines_BulkDemo]
           FROM "D:\1\InvoiceLines15.txt"
           WITH 
           (
            BATCHSIZE = 1000, 
            DATAFILETYPE = 'widechar',
            FIELDTERMINATOR = ';',
            ROWTERMINATOR ='\n',
            KEEPNULLS,
            TABLOCK        
            );




select Count(*) from [Sales].[InvoiceLines_BulkDemo];


