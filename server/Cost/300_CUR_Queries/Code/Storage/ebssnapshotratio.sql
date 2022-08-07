-- modified: 2021-04-25
-- query_id: ebssnapshotratio
-- query_description: This query provides monthly ratio of unblended cost and usage information between Amazon EBS Volume vs Amazon EBS Snapshots Usage per account and region. 
-- query_columns: bill_payer_account_id,line_item_unblended_cost,line_item_usage_account_id,line_item_usage_amount,line_item_usage_start_date,product_product_family,product_region
-- query_link: /cost/300_labs/300_cur_queries/queries/storage/

SELECT -- automation_select_stmt
  bill_payer_account_id ,
  line_item_usage_account_id,
  DATE_FORMAT(line_item_usage_start_date,'%Y-%m') AS month_line_item_usage_start_date, -- automation_timerange_dateformat
  CASE 
    WHEN product_product_family = 'Storage' THEN 'EBS Volume'
    WHEN product_product_family = 'Storage Snapshot' THEN 'EBS Snapshot'
  END AS usage_type_product_product_family,
  product_region,
  SUM(CAST(line_item_usage_amount AS DOUBLE)) AS sum_line_item_usage_amount,
  SUM(CAST(line_item_unblended_cost AS DECIMAL(16,8))) AS sum_line_item_unblended_cost
FROM -- automation_from_stmt
  ${table_name} -- automation_tablename
WHERE -- automation_where_stmt
  ${date_filter} -- automation_timerange_year_month
  AND product_product_name = 'Amazon Elastic Compute Cloud'
  AND (product_product_family = 'Storage Snapshot' OR product_product_family = 'Storage')
  AND line_item_line_item_type  IN ('DiscountedUsage', 'Usage', 'SavingsPlanCoveredUsage')
GROUP BY -- automation_groupby_stmt
  bill_payer_account_id,
  line_item_usage_account_id,
  DATE_FORMAT((line_item_usage_start_date),'%Y-%m'), -- automation_timerange_dateformat
  CASE 
   WHEN product_product_family = 'Storage' THEN 'EBS Volume'
   WHEN product_product_family = 'Storage Snapshot' THEN 'EBS Snapshot'
  END,
  product_region
ORDER BY -- automation_order_stmt
  month_line_item_usage_start_date ASC,
  sum_line_item_unblended_cost DESC, 
  sum_line_item_usage_amount DESC
;
