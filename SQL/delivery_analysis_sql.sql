-- Q1
/* How is the overall delivery performance? */
select on_time_flag, delivery_delay_days, order_delivered_customer_date, order_estimated_delivery_date
from analysis_delivery

SELECT COUNT(*) AS total_orders,
		SUM(CASE WHEN on_time_flag = 1 THEN 1 ELSE 0 END) AS on_time_orders,
		SUM(CASE WHEN on_time_flag = 0 THEN 1 ELSE 0 END) AS late_orders,
		ROUND(AVG(delivery_delay_days),2) AS avg_delivery_delay,
		ROUND(AVG(processing_days), 2) AS avg_processing_days,
		ROUND(AVG(shipping_days), 2) AS avg_shipping_days,
		ROUND(
			  SUM(CASE WHEN on_time_flag = 1 THEN 1 ELSE 0 END)*100.0 / COUNT (*), 2
			  ) AS on_time_delivery_rate
FROM analysis_delivery;
		
/* The overall delivery process is efficient, with most orders arriving on time or earlier than expected. 
The high on-time delivery rate (93.42%) indicates stable operational performance across the fulfillment process. */

--Q2
/* How has delivery performance changed over time? */

SELECT YEAR(order_purchase_timestamp) AS purchase_year,
	   MONTH(order_purchase_timestamp) AS purchase_month,
	   COUNT(*) AS total_orders,
	   ROUND(AVG(delivery_delay_days), 2) AS avg_delivery_delay,
	   ROUND(
			SUM(CASE WHEN on_time_flag = 1 THEN 1 ELSE 0 END)*100.0 / COUNT(*),2) AS on_time_delivery_rate
FROM analysis_delivery
GROUP BY 
		YEAR(order_purchase_timestamp),
		MONTH(order_purchase_timestamp)
ORDER BY
		purchase_year,
		purchase_month;
/*Overall delivery performance remained consistently high throughout the period, with the on-time delivery rate exceeding 90% in most months.
Delivery performance temporarily declined between November 2017 and March 2018, reaching its lowest level in February 2018 (86.14%) before recovering in subsequent months.
Despite monthly fluctuations, average delivery delay remained negative across all months, indicating that most orders were delivered earlier than the estimated delivery date. */

-- Q3
/* Which sellers contribute most to delivery delays? */
SELECT seller_id,
	   seller_state,
	   COUNT(*) AS total_orders,
	   SUM(CASE WHEN on_time_flag = 0 THEN 1 ELSE 0 END) AS late_orders,
	   ROUND(AVG(CASE WHEN on_time_flag = 0 THEN delivery_delay_days END), 2
			 ) AS avg_late_days,
	   ROUND(
			SUM(CASE WHEN on_time_flag = 0 THEN 1 ELSE 0 END)*100.0 / COUNT(*),2) AS late_delivery_rate
FROM analysis_delivery
GROUP BY
		seller_id,
		seller_state
HAVING
		COUNT(*) >= 50
ORDER BY 
		late_delivery_rate DESC,
		late_orders DESC,
		avg_late_days DESC;

--Q4
/* Which product categories experience the worst delivery performance? */
SELECT product_category_name,
	   product_category_name_english,
	   COUNT(*) AS total_orders,
	   ROUND(
			AVG(CASE WHEN on_time_flag = 0 THEN delivery_delay_days END), 2
			) AS avg_late_days,
	   SUM(CASE WHEN on_time_flag = 0 THEN 1 ELSE 0 END) AS late_orders,
	   ROUND(
			SUM(CASE WHEN on_time_flag = 0 THEN 1 ELSE 0 END)*100.0 / COUNT(*),2) AS late_delivery_rate
FROM analysis_delivery
GROUP BY 
		product_category_name,
		product_category_name_english
HAVING 
		COUNT(*) >= 100
ORDER BY
		late_delivery_rate DESC,
		late_orders DESC,
		avg_late_days DESC;

--Q5
/* How are delivery delays associated with customer satisfaction? */
SELECT CASE WHEN on_time_flag = 1 THEN 'ON_TIME' ELSE 'LATE' END AS delivery_status,
		COUNT(*) AS total_orders,
		SUM(CASE WHEN review_score = -1 THEN 1 ELSE 0 END) AS no_review,
		ROUND(
			  SUM(CASE WHEN review_score = -1 THEN 1 ELSE 0 END)*100.0 / COUNT(*), 2
			  ) AS no_review_rate,
		ROUND(
			   AVG(CASE WHEN review_score <> -1 THEN review_score END),2
			  ) AS avg_revie_score
FROM analysis_delivery
GROUP BY on_time_flag
/* Delivery performance has a strong association with customer satisfaction. 
Customers whose orders are delivered late tend to give substantially lower ratings and are less likely to leave a review, 
indicating that improving on-time delivery could enhance both customer experience and review outcomes.*/

--Q6
/* Which operational factors are most associated with delivery delays? */
SELECT
    CASE WHEN on_time_flag = 1 THEN 'ON_TIME' ELSE 'LATE' END AS delivery_status,
    COUNT(*) AS total_orders,

    ROUND(AVG(processing_days), 2) AS avg_processing_days,
    ROUND(AVG(shipping_days), 2) AS avg_shipping_days,
    ROUND(AVG(freight_value), 2) AS avg_freight_value,
    ROUND(AVG(price), 2) AS avg_price,
    ROUND(AVG(basket_size), 2) AS avg_basket_size
FROM analysis_delivery
GROUP BY
    on_time_flag;

--Q7
/* Which states experience the highest delivery delay rates? */ 
SELECT
    customer_state,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN on_time_flag = 0 THEN 1 ELSE 0 END) AS late_orders,
    ROUND(
          SUM(CASE WHEN on_time_flag = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
		 ) AS late_delivery_rate,
    ROUND(
          AVG(CASE WHEN on_time_flag = 0 THEN delivery_delay_days END), 2
         ) AS avg_late_days
FROM analysis_delivery
GROUP BY
    customer_state
HAVING
    COUNT(*) >= 100
ORDER BY
    late_delivery_rate DESC,
    late_orders DESC,
    avg_late_days DESC;