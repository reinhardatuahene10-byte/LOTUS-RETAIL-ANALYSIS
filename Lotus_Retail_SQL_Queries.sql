#LOTUS RETAIL ANALYSIS

##SQL ANALYSIS

--Tool: Google BigQuery

================================================================================
-- VAL-001: Identify orders with revenue reconciliation differences
================================================================================
WITH Totals AS (
SELECT
      F.Order_id,
      SUM(D.line_total_revenue) AS Total_line,
      F.total_revenue
FROM
     `reinhardproject.LOTUS_RETAIL.Facts_Orders_Table` AS F    
INNER JOIN  
     `reinhardproject.LOTUS_RETAIL.Order_Details_Clean` AS D   
ON 
     F.Order_id = D.order_id 
GROUP BY
     F.order_id,
     F.total_revenue
)
     SELECT
           *
     FROM
          Totals
     WHERE
          total_revenue - Total_line <> 0 




================================================================================
-- CATEGORY PERFORMANCE
================================================================================
WITH Category_Total AS (
SELECT
      O.order_id,
      P.Category,
      SUM(O.line_total_cost) AS Total_Cost,
      SUM(O.line_total_revenue) AS Total_Revenue
FROM
      `reinhardproject.LOTUS_RETAIL.Order_Details_Clean` AS O
INNER JOIN 
       `reinhardproject.LOTUS_RETAIL.Products_Table` AS P  
ON
      O.product_id = P.product_id  
GROUP BY
      O.order_id,
      P.Category
),
Completed_Orders AS (
      SELECT
            C.Order_id,
            C.Category,
            C.Total_Cost,
            C.Total_Revenue
      FROM
            Category_Total AS C    
      INNER JOIN  
            `reinhardproject.LOTUS_RETAIL.Facts_Orders_Table`  AS F      
      ON
            C.Order_id = F.order_id
      WHERE
            F.order_status = 'Completed'
),
Rejected_returns AS (
       SELECT
             C.Order_id,
             C.Category,
             C.Total_Cost,
             C.Total_Revenue
       FROM
             Category_Total AS C 
       INNER JOIN
             `reinhardproject.LOTUS_RETAIL.Returns_Table` AS R 
       ON
            C.Order_id = R.Order_id
       WHERE
            R.return_status = 'Rejected'
),
Final_Revenue AS (
        SELECT
             Order_id,
             Category,
             Total_Cost,
             Total_Revenue 
        FROM
              Completed_Orders

        UNION ALL

        SELECT
              Order_Id,
              Category,
              Total_Cost,
              Total_Revenue   
        FROM
              Rejected_Returns
)
         SELECT
               Category,
               SUM(Total_Revenue) AS Revenue_Total,
               COUNT(DISTINCT Order_id) AS Total_Orders,
               SUM(Total_Revenue - Total_Cost) AS Gross_Profit,
               ROUND(SUM(Total_revenue) / COUNT(DISTINCT Order_id), 2) AS AOV,
               ROUND((SUM(Total_Revenue - Total_Cost) / SUM(Total_Revenue)) * 100, 2) AS Profit_Margin
         FROM
               Final_Revenue
        GROUP BY
               Category



=============================================================================================
-- DRILL DOWN TO CONFIRM IF DISCOUNTS HAS IMPACTS IN CATEGORY PERFORMANCE
=============================================================================================
WITH Category_Discount AS (
SELECT
      O.order_id,
      P.product_id,
      P.Category,
      O.discount_pct
FROM
       `reinhardproject.LOTUS_RETAIL.Order_Details_Clean` AS O    
INNER JOIN 
       `reinhardproject.LOTUS_RETAIL.Products_Table` AS P      
ON 
       O.Product_id = P.product_id  
),
Completed_Discount AS (
      SELECT
            C.order_id,
            C.product_id,
            C.Category,
            C.discount_pct
      FROM
            Category_Discount AS C 
      INNER JOIN 
             `reinhardproject.LOTUS_RETAIL.Facts_Orders_Table`  AS F      
      ON  
           C.Order_id = F.order_id 
      WHERE
           F.order_status = 'Completed'
),
Rejected_Discount AS (
       SELECT
              C.Order_id,
              C.Product_id,
              C.Category,
              C.discount_pct
       FROM
              Category_Discount AS C    
       INNER JOIN   
              `reinhardproject.LOTUS_RETAIL.Returns_Table` AS R     
       ON
             C.Order_id = R.order_id  
       WHERE
             R.return_status = 'Rejected'
),
  Final_Analysis AS (
        SELECT
             *
        FROM
              Completed_Discount

        UNION ALL 

        SELECT
              *
        FROM
              Rejected_Discount
  )
        SELECT
                Category,
                ROUND(AVG(discount_pct), 2) AS Avg_Discount
         FROM
                Final_Analysis
        GROUP BY
                Category


=======================================================================================
-- QUARTERLY TRENDS
=======================================================================================
WITH Completed_Orders AS (
SELECT
     EXTRACT(YEAR FROM Order_date) AS Year,
     EXTRACT(QUARTER FROM Order_Date) AS Quarter,
     COUNT(DISTINCT Order_id) AS Total_Orders,
     SUM(Total_Cost) AS Cost_price,
     SUM(Total_Revenue) AS Revenue
FROM
     `reinhardproject.LOTUS_RETAIL.Facts_Orders_Table` 
WHERE
     order_status = 'Completed'
GROUP BY
     EXTRACT(YEAR FROM Order_date),
     EXTRACT(QUARTER FROM Order_Date)
),
Rejected_Returns AS (
     SELECT
           EXTRACT(YEAR FROM F.Order_date) AS Year,
           EXTRACT(QUARTER FROM F.order_Date) AS Quarter,
           COUNT(DISTINCT R.Order_id) AS Total_Orders,
           SUM(F.Total_Cost) AS Cost_price,
           SUM(F.Total_Revenue) AS Revenue
     FROM
          `reinhardproject.LOTUS_RETAIL.Facts_Orders_Table` AS F       
     INNER JOIN 
           `reinhardproject.LOTUS_RETAIL.Returns_Table` AS R    
     ON
           F.order_id = R.order_id
     WHERE
           R.return_status = 'Rejected'
     AND   F.order_status = 'Returned'
     GROUP BY
           EXTRACT(YEAR FROM F.Order_date),
           EXTRACT(QUARTER FROM F.order_Date)
),
Combined_Analysis AS (
      SELECT
          *
      FROM 
            Completed_Orders

     UNION ALL 
      
      SELECT
            *
      FROM
             Rejected_Returns
),
Final_Analysis AS (
      SELECT
             Year,
             Quarter,
             SUM(Total_orders) AS Orders,
             SUM(Cost_price) AS Total_Cost_Price,
             SUM(Revenue) AS Total_Revenue,
             ROUND(SUM(Revenue) / SUM(Total_orders), 2) AS AOV,
             SUM(Revenue) - SUM(Cost_price) AS Gross_Profit,
             ROUND(((SUM(Revenue) - SUM(Cost_price)) / SUM(Revenue)) * 100, 2) AS Profit_Margin
      FROM
             Combined_Analysis
      GROUP BY
             Year,
             Quarter
),
YOY_Performance AS (
       SELECT
             Year,
             Quarter,
             Total_Revenue,
             Orders,
             AOV,
             Gross_Profit,
             Profit_Margin,
             LAG(Total_Revenue) OVER (PARTITION BY QUARTER ORDER BY Year) AS Previous_Revenue,
             Total_Revenue - LAG(Total_Revenue) OVER (PARTITION BY QUARTER ORDER BY Year) AS Revenue_Change,
             ROUND(((Total_Revenue - LAG(Total_Revenue) OVER (PARTITION BY QUARTER ORDER BY Year)) / LAG(Total_Revenue) OVER (PARTITION BY QUARTER ORDER BY Year))
             * 100, 2) AS Percentage_Change
       FROM
             Final_Analysis
)
        SELECT
             Year,
             Quarter,
             Orders,
             Total_Revenue,
             AOV,
             Gross_Profit,
             Profit_Margin,
             Revenue_Change,
             Percentage_Change,
             ROW_NUMBER() OVER (PARTITION BY Year ORDER BY Total_Revenue DESC) AS Quarter_Ranking
        FROM
             YOY_Performance


====================================================================================
-- RETURN STATUS IMPACT
====================================================================================
WITH Return_Counts AS (
SELECT
      R.Return_Status,
      COUNT(DISTINCT R.Order_id) AS Total_Orders,
      SUM(F.Total_Cost) AS Cost_price,
      SUM(R.Return_Amount) AS Total_Returns,
      SUM(F.Total_Revenue) - SUM(F.Total_Cost) AS Potential_Gross_Profit
FROM
      `reinhardproject.LOTUS_RETAIL.Returns_Table` AS R 
INNER JOIN  
       `reinhardproject.LOTUS_RETAIL.Facts_Orders_Table` AS F
ON 
       R.Order_id = F.Order_id
GROUP BY 
      Return_Status
)
      SELECT
            Return_Status,
            Total_Orders,
            Total_Returns,
            ROUND(Total_Orders / (
                    SELECT
                          COUNT(DISTINCT Order_id)
                    FROM
                         `reinhardproject.LOTUS_RETAIL.Returns_Table` 
            ) * 100, 2) AS Percentage_of_Returns,
            Potential_Gross_Profit
      FROM
            Return_Counts