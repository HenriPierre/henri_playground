view: order_items {
  sql_table_name: "PUBLIC"."ORDER_ITEMS"
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."CREATED_AT" ;;
  }

  dimension_group: delivered {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."DELIVERED_AT" ;;
  }

  dimension: inventory_item_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."INVENTORY_ITEM_ID" ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension_group: returned {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."RETURNED_AT" ;;
  }

  dimension: sale_price {
    type: number
    sql: ${TABLE}."SALE_PRICE" ;;
  }

  dimension_group: shipped {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."SHIPPED_AT" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  dimension: user_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."USER_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  ###################################### USE CASE ###############################################
measure: pct_total_revenue {
  type: percent_of_total
  sql: ${Total_revenue_for_completed_sales} ;;
  value_format_name: percent_2
}

  measure: Total_sale_price {
    type: sum
    sql: ${TABLE}."SALE_PRICE" ;;
    value_format_name:usd
  }


  measure: Average_sale_price {
    type: average
    sql: ${TABLE}."SALE_PRICE" ;;
    value_format_name:usd

  }

  measure: Cumulative_total_sales {
    type: running_total
    sql: ${TABLE}."SALE_PRICE" ;;
    value_format_name:usd
  }

  measure: Total_revenue_for_completed_sales {
    type: sum
    filters: [status: "-Cancelled, -Returned"]
    sql:${TABLE}."SALE_PRICE" ;;
    value_format_name:usd
  }

  measure: Total_Gross_Margin_Amount {
    type: number
    sql: ${order_items.Total_revenue_for_completed_sales}-${inventory_items.Total_cost} ;;
    drill_fields: [products.category, products.brand, Total_Gross_Margin_Amount]
    value_format_name:usd
  }

  #measure: Average_gross_margin{
  #  type: average
  #  sql: ${Total_Gross_Margin_Amount};;
  #  value_format_name:usd
  #}

  measure: Gross_margin_perct {
    type: number
    sql: ${Total_Gross_Margin_Amount}/${Total_revenue_for_completed_sales} ;;
    value_format_name: percent_2
  }

  measure: Nbr_item_returned {
    type: count_distinct
    filters: [status: "Returned"]
    sql: ${user_id} ;;
  }

  measure: item_return_rate {
    type: number
    sql: ${Nbr_item_returned}/${count} ;;
    value_format_name: percent_2
  }

  measure: nbr_cust_return {
    type: count_distinct
    filters: [status: "Returned"]
    sql:${user_id};;
  }

  measure: pct_user_with_return {
    type: number
    sql: ${nbr_cust_return}/${users.count} ;;
    value_format_name: percent_2
  }

  measure: average_spend_per_cust {
    type: number
    sql: ${Total_sale_price}/${users.count} ;;
    value_format_name:usd

  }

  measure: first_order{
    type: date
    sql: min(${created_date}) ;;
    convert_tz: no
  }

  measure: last_order {
    type: date
    sql: max(${created_date}) ;;
    convert_tz: no
  }

  measure: Days_Since_Latest_Order {
    type: number
    sql: now()-${last_order} ;;
  }

####################################################################################################

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      id,
      users.first_name,
      users.last_name,
      users.id,
      inventory_items.id,
      inventory_items.product_name
    ]
  }
}
