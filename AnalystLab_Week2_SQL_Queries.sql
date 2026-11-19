/*
AnalystLab Africa - Week 2
Track 1: Data Analytics
Project: E-commerce Business Performance and Customer Behaviour Analysis
Database: Maven_Fuzzy_Factory.db
SQL dialect: SQLite (DB Browser for SQLite)

Run each query separately in DB Browser for SQLite.
Save this file in: AnalystLab_Week2_Project/03_SQL_Queries/

Note:
- The imported orders table is named orders_mav (not orders).
- The supplied product data contains product_id, created_at and product_name only.
  No product category/type field was supplied.
- Some CSV imports appear to have included a header row as a data row.
  Queries below exclude known header-text rows where relevant.
*/


/* QUESTION 1
   What is the total number of unique orders?
*/
SELECT
    COUNT(DISTINCT order_id) AS total_unique_orders
FROM orders_mav;


/* QUESTION 2
   What is the total revenue generated?
   Use the order-level price_usd field to avoid double-counting order items.
*/
SELECT
    ROUND(SUM(price_usd), 2) AS total_revenue
FROM orders_mav;


/* QUESTION 3
   Which five products generate the highest revenue?
   Only products matching the supplied products table are included.
*/
SELECT
    oi.product_id,
    p.product_name,
    ROUND(SUM(oi.price_usd), 2) AS total_revenue
FROM order_items AS oi
INNER JOIN products AS p
    ON oi.product_id = p.product_id
GROUP BY
    oi.product_id,
    p.product_name
ORDER BY total_revenue DESC
LIMIT 5;


/* QUESTION 4
   Which product categories or product types perform best, where available?

   The supplied products table contains product_id, created_at and product_name.
   It does not contain a category or product_type column, so category/type
   performance cannot be analysed from the provided data.
*/
PRAGMA table_info(products);


/* QUESTION 5
   Which marketing sources generate the most website sessions?
   The WHERE condition excludes an accidentally imported header row, if present.
   NULL is retained as a group because it represents sessions with no source recorded.
*/
SELECT
    utm_source,
    COUNT(DISTINCT website_session_id) AS total_sessions
FROM website_sessions
WHERE utm_source IS NULL
   OR utm_source <> 'utm_source'
GROUP BY utm_source
ORDER BY total_sessions DESC;


/* QUESTION 6
   Which device type generates the most website traffic?
*/
SELECT
    device_type,
    COUNT(DISTINCT website_session_id) AS total_sessions
FROM website_sessions
WHERE device_type <> 'device_type'
GROUP BY device_type
ORDER BY total_sessions DESC;


/* QUESTION 7
   What is the website session-to-order conversion rate?
*/
SELECT
    COUNT(DISTINCT ws.website_session_id) AS total_sessions,
    COUNT(DISTINCT o.website_session_id) AS sessions_with_orders,
    ROUND(
        COUNT(DISTINCT o.website_session_id) * 100.0
        / COUNT(DISTINCT ws.website_session_id),
        2
    ) AS conversion_rate_percentage
FROM website_sessions AS ws
LEFT JOIN orders_mav AS o
    ON ws.website_session_id = o.website_session_id;


/* QUESTION 8
   What is the total number and value of refunds?
*/
SELECT
    COUNT(DISTINCT order_item_refund_id) AS total_refunds,
    ROUND(SUM(refund_amount_usd), 2) AS total_refund_value
FROM order_item_refunds;


/* QUESTION 9
   Which months recorded the highest and lowest revenue?

   The created_at values are stored as text in M/D/YYYY H:MM format.
   This query extracts month and year from that format and excludes the
   imported header row because it does not match the date pattern.
*/
SELECT
    CAST(
        substr(created_at, 1, instr(created_at, '/') - 1)
        AS INTEGER
    ) AS month_number,
    CAST(
        substr(
            created_at,
            instr(created_at, '/') + 1
            + instr(
                substr(created_at, instr(created_at, '/') + 1),
                '/'
            )
        , 4) AS INTEGER
    ) AS year_number,
    ROUND(SUM(price_usd), 2) AS monthly_revenue
FROM orders_mav
WHERE created_at GLOB '[0-9]*/[0-9]*/[0-9][0-9][0-9][0-9]*'
GROUP BY
    year_number,
    month_number
ORDER BY
    year_number,
    month_number;


/* QUESTION 10
   What is the average order value (AOV)?
*/
SELECT
    ROUND(
        SUM(price_usd) / COUNT(DISTINCT order_id),
        2
    ) AS average_order_value
FROM orders_mav;


/*
Recorded analysis results from the completed queries:

1. Total unique orders: 32,314
2. Total revenue: USD 1,938,509.75
3. Top product: The Original Mr. Fuzzy
   Other valid products returned:
   - The Forever Love Bear
   - The Birthday Sugar Panda
   - The Hudson River Mini bear
   The products table contains four products; the fifth row in the initial
   top-five output was blank with zero revenue and is not a valid product.
4. Product categories/types: not available in the supplied products table.
5. Marketing sessions:
   - gsearch: 316,035
   - source not recorded (NULL): 83,328
   - bsearch: 62,823
   - socialbook: 10,685
   A header-text row was also present in the original query output.
6. Device sessions:
   - desktop: 327,027
   - mobile: 145,844
7. Total sessions: 472,872
   Sessions with orders: 32,314
   Conversion rate: 6.83%
8. Total refunds: 1,732
   Refund value: USD 85,338.69
9. Highest revenue month: December 2014 (USD 144,823.02)
   Lowest revenue month: March 2012 (USD 2,999.40)
   An invalid header-text row with zero revenue was excluded.
10. Average order value: USD 59.99

These recorded results are the outputs reported during the analysis.
If the database is changed or queries are rerun after cleaning, update this
summary to match the latest results.
