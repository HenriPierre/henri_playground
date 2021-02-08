view: products {
  sql_table_name: "PUBLIC"."PRODUCTS"
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }

  dimension: brand {
    type: string
    sql: ${TABLE}."BRAND" ;;
    drill_fields: [name, category]

      link: {
        label: "Google"
        url: "http://www.google.com/search?q={{ value }}"
      }
      link: {
        label: "Facebook"
        url: "http://www.facebook.com/search?q={{ value }}"
      }
  }


  dimension: drilltodash_example_6 {

    label: "Category Linked to Dashboard"

    description: "When we drill into this field, we will be navigated to another dashboard and pull in filters from the original dashboard"

    type: string

    sql: ${TABLE}."BRAND" ;;

    link: {

      label: "Brand Comparisons"
      url: "/dashboards/26?Brand={{ value | url_encode }}"
      #url: "/dashboards/26?Category={{ value | url_encode }}&Brand={{ _filters['products.brand'] | url_encode }}"

    }

  }





  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }

  dimension: cost {
    type: number
    sql: ${TABLE}."COST" ;;
  }

  dimension: department {
    type: string
    sql: ${TABLE}."DEPARTMENT" ;;
  }

  dimension: distribution_center_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."DISTRIBUTION_CENTER_ID" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: retail_price {
    type: number
    sql: ${TABLE}."RETAIL_PRICE" ;;
    value_format_name: usd
  }

  dimension: sku {
    type: string
    sql: ${TABLE}."SKU" ;;
  }

  measure: count {
    type: count
    drill_fields: [id, name, distribution_centers.name, distribution_centers.id, inventory_items.count]
  }
}
