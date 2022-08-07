-- modified: 2021-04-25
-- query_id: sqs
-- query_description: This query will provide the top 20 daily unblended costs as well as usage information for a specified linked account for Amazon SQS. The output will include detailed information about the resource id (queue), usage type, and API operation. The cost will be summed and in descending order. This is helpful for tracking down spikes in cost for SQS usage. Cost Explorer will provide you all of this information except the resource ID. This allows your investigation to be targeted to a time range, linked account, API operation, and resource that is generating the usage.
-- query_columns: line_item_operation,line_item_resource_id,line_item_unblended_cost,line_item_usage_account_id,line_item_usage_amount,line_item_usage_start_date,line_item_usage_type
-- query_link: /cost/300_labs/300_cur_queries/queries/application_integration/

SELECT -- automation_select_stmt
  line_item_usage_account_id,
  DATE_FORMAT((line_item_usage_start_date),'%Y-%m-%d') AS day_line_item_usage_start_date, -- automation_timerange_dateformat
  line_item_usage_type,
  line_item_operation,
  line_item_resource_id,
  SUM(CAST(line_item_usage_amount AS DOUBLE)) AS sum_line_item_usage_amount,
  SUM(CAST(line_item_unblended_cost AS DECIMAL(16,8))) AS sum_line_item_unblended_cost
FROM -- automation_from_stmt
  ${table_Name} -- automation_tablename
WHERE -- automation_where_stmt
  ${date_filter} -- automation_timerange_year_month
  AND line_item_product_code = 'AWSQueueService'
  AND line_item_line_item_type  IN ('DiscountedUsage', 'Usage', 'SavingsPlanCoveredUsage')
GROUP BY -- automation_groupby_stmt
  line_item_usage_account_id,
  DATE_FORMAT((line_item_usage_start_date),'%Y-%m-%d'),
  line_item_usage_type,
  line_item_operation,
  line_item_resource_id
ORDER BY -- automation_order_stmt
  sum_line_item_unblended_cost DESC
LIMIT 20; -- automation_limit_stmt
