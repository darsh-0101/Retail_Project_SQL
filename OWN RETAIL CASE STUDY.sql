

--Data Preparation and Understanding
/*Total no of rows in each table*/

SELECT COUNT(*) AS CUST FROM Customer 
SELECT COUNT(*)  AS PROD FROM prod_cat_info
SELECT COUNT(*) AS TRANS FROM Transactions ;

/*tot no of trans tht returned*/
SELECT COUNT(DISTINCT([transaction_id])) AS retn FROM Transactions
WHERE Qty> 0;

/*date convertion*/
SELECT TOP 5 tran_date from Transactions
select CONVERT(date,tran_date,105) as trans_date from Transactions;

/*time range of transaction*/
SELECT DATEDIFF(YEAR,MIN(CONVERT(date,tran_date,105)),MAX(CONVERT(date,tran_date,105))) AS DIFF_YEAR,
DATEDIFF(MONTH,MIN(CONVERT(date,tran_date,105)),MAX(CONVERT(date,tran_date,105))) AS DIFF_MONTH,
DATEDIFF(DAY,MIN(CONVERT(date,tran_date,105)),MAX(CONVERT(date,tran_date,105))) AS DIFF_DAY
FROM Transactions;

/*PROD_CAT WHERE SUB_CAT "DIY" BELONG*/

SELECT [prod_cat] FROM prod_cat_info
WHERE [prod_subcat] = 'DIY'

--DATA ANALYSIS
/*CHANNEL FREQUENTLY USED FOR TRANSACTIONS*/

SELECT TOP 1 [Store_type],COUNT([Store_type])  AS cnt FROM Transactions
GROUP BY [Store_type]
ORDER BY cnt DESC ;

/*COUNT OF MALE AND FEMALE CUST*/

SELECT  Gender FROM Customer

SELECT Gender,COUNT(*) FROM Customer
WHERE Gender IS NOT NULL
GROUP BY Gender;

/*CITY HAS MAX CUST AND ITS COUNT*/
SELECT TOP 1 city_code,COUNT([customer_Id]) AS CNT FROM Customer
GROUP BY city_code
ORDER BY CNT DESC;

/*HOW MANY SUB CAT THERE IN BOOK CATG*/
SELECT  COUNT([prod_subcat]) AS CNT FROM prod_cat_info
WHERE [prod_cat]= 'Books';

/*MAX QTY OF PRODUCT EVER ORDERED*/
SELECT [prod_cat_code], MAX([Qty]) AS MAX_PROD FROM Transactions
GROUP BY [prod_cat_code];

/*NET TOT REVENUE BY CATG 'Books' AND 'ELECTRONICS'*/

SELECT SUM(CAST([total_amt] AS FLOAT)) AS revenue FROM Transactions As t2
JOIN prod_cat_info AS t1  ON t1.prod_cat_code=t2.[prod_cat_code] and t1.[prod_sub_cat_code]=t2.[prod_subcat_code]
WHERE t1.[prod_cat] in ('Books','Electronics');

/*cust have more than 10 transactions excluding return(qty>0)*/

SELECT cust_id FROM Transactions
WHERE  [Qty] > 0
GROUP BY cust_id
HAVING COUNT(DISTINCT([transaction_id])) > 10


/*COMBINED REVENUE EARNED FROM 'Electronics','Clothing' IN Flagship store*/
SELECT SUM([total_amt]) FROM Transactions AS T1
join prod_cat_info AS T2 ON T1.prod_cat_code=T2.prod_cat_code AND T1.prod_subcat_code=T2.[prod_sub_cat_code]
where prod_cat in ('Electronics') or prod_cat in ('Clothing')
and Store_type = 'Flagship stores'


SELECT [prod_subcat],SUM(CAST([total_amt] AS FLOAT)) AS REVENUE FROM Transactions AS T1
join prod_cat_info AS T2 ON T1.prod_cat_code=T2.prod_cat_code AND T1.prod_subcat_code=T2.[prod_sub_cat_code]
JOIN Customer AS T3 ON T1.[cust_id]=T3.[customer_Id]
WHERE [Gender] = 'M' AND [prod_cat] = 'Electronics'
GROUP BY [prod_subcat];

--10
select TOP 5 [prod_subcat], (sum(total_amt)/(Select sum(total_amt) from Transactions))*100  As SALES_percentage
from Transactions AS t
join [dbo].[prod_cat_info]  AS p on t.prod_cat_code = p.prod_cat_code and prod_subcat_code= prod_sub_cat_code
where Qty>0
GROUP BY [prod_subcat]
order by SALES_percentage desc;


SELECT Qty FROM Transactions WHERE Qty>0
 select  top 5 prod_subcat, (sum(total_amt)/(Select sum(total_amt) from Transactions))*100 as SalesPercentage,(COUNT(case when qty<0 then qty else null end)/sum(qty))*100 as PercetageOfReturn
from Transactions t
inner join prod_cat_info pci on t.prod_cat_code = pci.prod_cat_code and prod_subcat_code= prod_sub_cat_code
group by prod_subcat
order by sum(total_amt) desc;
select (sum(total_amt)/(Select sum(total_amt) from Transactions))*100 from Transactions

--11)
/*min,2,3,4,........,70,..,97,98,99,max*/
/*max to 70 is -30 and from starts from -30 to max*/          
--frist identify the last 30 days and from there filter till specific conditions

SELECT cust_id, sum([total_amt]) as total_revenue,DATEDIFF(YEAR,[DOB],GETDATE())  as age
FROM  Transactions
join Customer AS C ON cust_id=customer_Id
WHERE  DATEDIFF(YEAR,[DOB],GETDATE()) BETWEEN 25 AND 35 and CONVERT(date, [tran_date],103) between DATEADD(day,-30,(select MAX(CONVERT(date, [tran_date],103)) from Transactions)) 
and (select MAX(CONVERT(date, [tran_date],103)) from Transactions)
group by cust_id ,DATEDIFF(YEAR,[DOB],GETDATE())


--12)
--max the return max the total value 'return is inversely proportional to total amt
--accending used bcoz its negative values
select TOP 5 prod_cat , SUM([total_amt]) as total_amt,sum(Qty) as max_returns from Transactions t inner join prod_cat_info pci on t.prod_cat_code = pci.prod_cat_code
and t.prod_subcat_code = pci.prod_sub_cat_code 
where Qty < 0 and convert (date, tran_date,103) between dateadd(month,-3,(select max(convert(date,tran_date,103)) from Transactions))
and (select max (convert(date,tran_date,103)) from Transactions)
group by prod_cat
order by max_returns;
 --12)
 --using having function
select TOP 5 prod_cat,sum(max_returns) as max_return from(
 select prod_cat ,sum(Qty) as max_returns,convert (date, tran_date,103) as date  from Transactions t inner join prod_cat_info pci on t.prod_cat_code = pci.prod_cat_code
and t.prod_subcat_code = pci.prod_sub_cat_code 
where Qty < 0
group by prod_cat,convert (date, tran_date,103)
having  convert (date, tran_date,103) > dateadd(month,-3,(select max(convert(date,tran_date,103)) from Transactions))
 )as t
group by prod_cat
order by max_return;



--13)which store type sells max products by value of sales amount and qty sold


select top 1(store_type),sum(total_amt) as sales, sum(Qty) as qtantity from Transactions 
where  Qty >0 
group by Store_type
order by  sales desc,qtantity desc
 --13)

select Store_type,sum(total_amt) [TotalSales], sum(Qty) [TotalQuantity] from Transactions
 group by Store_type
 having sum(total_amt) >=All  (select sum(total_amt) from Transactions group by Store_type) and 
 sum(qty) >=all (select sum(qty) from Transactions group by Store_type)

--14)
 select [prod_cat],AVG([total_amt]) AVE_REVENUE from Transactions T
 join [dbo].[prod_cat_info] P on T.[prod_cat_code]=P.[prod_cat_code]
 WHERE Qty>0
 GROUP BY[prod_cat]
 HAVING AVG([total_amt]) > ALL (SELECT AVG([total_amt]) from Transactions T WHERE Qty>0)
 ORDER BY AVE_REVENUE DESC;

 --15)

select   prod_subcat, AVG([total_amt]) as avg_amt ,SUM(total_amt), (select top 5 [prod_cat]  from prod_cat_info 
                               where Qty>0
                                     group by [prod_cat]
									  order by SUM(Qty)desc)as sum_amt from Transactions T
 join prod_cat_info P on T.[prod_cat_code]=P.[prod_cat_code] and [prod_sub_cat_code] = [prod_subcat_code]
  where Qty>0
  group by prod_subcat;

  