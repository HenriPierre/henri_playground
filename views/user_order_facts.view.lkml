view: user_order_facts {
  derived_table: {
    sql: SELECT
        users."ID"  AS "users.id",
        users."FIRST_NAME"  AS "users.first_name",
        users."LAST_NAME"  AS "users.last_name",
        COUNT(DISTINCT (order_items."ORDER_ID")) AS lifetime_orders,
        COALESCE(SUM(CAST((order_items."SALE_PRICE") AS DOUBLE PRECISION)), 0) AS sum_of_sale_price,
        TO_CHAR(TO_DATE(min((TO_CHAR(TO_DATE(CONVERT_TIMEZONE('UTC', 'America/Los_Angeles', CAST(order_items."CREATED_AT"  AS TIMESTAMP_NTZ))), 'YYYY-MM-DD'))) ), 'YYYY-MM-DD') AS "order_items.first_order",
        TO_CHAR(TO_DATE(max((TO_CHAR(TO_DATE(CONVERT_TIMEZONE('UTC', 'America/Los_Angeles', CAST(order_items."CREATED_AT"  AS TIMESTAMP_NTZ))), 'YYYY-MM-DD'))) ), 'YYYY-MM-DD') AS "order_items.last_order"
      FROM "PUBLIC"."ORDER_ITEMS"
           AS order_items
      LEFT JOIN "PUBLIC"."USERS"
           AS users ON (order_items."USER_ID") = (users."ID")

      GROUP BY 1,2,3
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: users_id {
    type: number
    sql: ${TABLE}."users.id" ;;
  }

  dimension: users_first_name {
    type: string
    sql: ${TABLE}."users.first_name" ;;
  }

  dimension: users_last_name {
    type: string
    sql: ${TABLE}."users.last_name" ;;
  }

  dimension: lifetime_orders {
    type: number
    sql: ${TABLE}."LIFETIME_ORDERS" ;;
  }

  dimension: sum_of_sale_price {
    type: number
    sql: ${TABLE}."SUM_OF_SALE_PRICE" ;;
  }

  dimension: order_items_first_order {
    type: date
    sql: ${TABLE}."order_items.first_order" ;;
  }

  dimension: order_items_last_order {
    type: date
    sql: ${TABLE}."order_items.last_order" ;;
  }









  dimension: lifetime_orders_tiered {
    type: tier
    sql: ${lifetime_orders} ;;
    tiers: [1,2,3,6,10]
    style: integer
  }

  dimension:  lifetime_orders_tiered_with_units{
    type: string
    sql: CASE
          WHEN ${lifetime_orders}=1 THEN '1 Order'
          WHEN ${lifetime_orders}=2 THEN '2 Orders'
          WHEN ${lifetime_orders}<6 THEN '3-5 Orders'
          WHEN ${lifetime_orders}<10 THEN '6-9 Orders'
          ELSE '10+ Orders'
          END;;

  }



  dimension: Customer_Lifetime_Revenue_tiered {
    type: tier
    sql: ${sum_of_sale_price} ;;
    tiers: [0,5,20,50,100,500,1000]
    style: integer
  }


  dimension:  Customer_Lifetime_Revenue_tiered_with_units{
    type: string
    sql: CASE
          WHEN ${sum_of_sale_price}<5 THEN '$0.00 - $4.99'
          WHEN ${sum_of_sale_price}<50 THEN '$20.00 - $49.99'
          WHEN ${sum_of_sale_price}<100 THEN '$50.00 - $99.99'
          WHEN ${sum_of_sale_price}<500 THEN '$100.00 - $499.99'
          WHEN ${sum_of_sale_price}<1000 THEN '$500.00 - $999.99'
          ELSE '+$1000.00'
          END;;

    }



  measure: Total_Lifetime_Orders {
    type: sum
    sql: ${lifetime_orders} ;;
  }

  measure: Average_lifetime_Orders {
    type: average
    sql: ${lifetime_orders} ;;
  }

  measure: Total_Lifetime_Revenue {
    type: sum
    sql: ${sum_of_sale_price} ;;
  }

  measure: Average_Lifetime_Revenue {
    type: average
    sql: ${sum_of_sale_price} ;;
  }

  dimension: days_between_first_last_order {
    type: number
    sql: DATEDIFF( day, ${order_items_first_order}, ${order_items_last_order}) ;;
  }

  dimension: days_since_last_order{
    type: number
    sql: DATEDIFF(day, ${order_items_last_order},GETDATE()) ;;
  }
  dimension: full_name {
    type: string
    sql: CONCAT(${users_first_name}, ' ', ${users_last_name}) ;;
  }

  set: detail {
    fields: [
      users_id,
      users_first_name,
      users_last_name,
      lifetime_orders,
      sum_of_sale_price,
      order_items_first_order,
      order_items_last_order
    ]
  }
}
