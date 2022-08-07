-- modified: 2021-04-25
-- query_id: cloudwatch-spend
-- query_description: This query will provide monthly unblended and usage information per linked account for AWS CloudWatch.
-- query_columns: bill_payer_account_id,line_item_operation,line_item_unblended_cost,line_item_usage_account_id,line_item_usage_amount,line_item_usage_start_date,line_item_usage_type
-- query_link: /cost/300_labs/300_cur_queries/queries/management__governance/

SELECT -- automation_select_stmt
  bill_payer_account_id,
  line_item_usage_account_id,
  DATE_FORMAT(line_item_usage_start_date,'%Y-%m') month_line_item_usage_start_date, -- automation_timerange_dateformat
  CASE
    WHEN line_item_usage_type LIKE '%%Requests%%' THEN 'Requests'
    WHEN line_item_usage_type LIKE '%%DataProcessing-Bytes%%' THEN 'DataProcessing'
    WHEN line_item_usage_type LIKE '%%TimedStorage-ByteHrs%%' THEN 'Storage'
    WHEN line_item_usage_type LIKE '%%DataScanned-Bytes%%' THEN 'DataScanned'
    WHEN line_item_usage_type LIKE '%%AlarmMonitorUsage%%' THEN 'AlarmMonitors'
    WHEN line_item_usage_type LIKE '%%DashboardsUsageHour%%' THEN 'Dashboards'
    WHEN line_item_usage_type LIKE '%%MetricMonitorUsage%%' THEN 'MetricMonitor'
    WHEN line_item_usage_type LIKE '%%VendedLog-Bytes%%' THEN 'VendedLogs'
    WHEN line_item_usage_type LIKE '%%GMD-Metrics%%' THEN 'GetMetricData'
  ELSE 'Others'
  END AS line_item_usage_type,
  -- if uncommenting, also uncomment one other occurrence of line_item_resource_id in GROUP BY
  -- SPLIT_PART(line_item_resource_id,':',7) as ResourceID, 
  line_item_operation,
  SUM(CAST(line_item_usage_amount AS DOUBLE)) AS sum_line_item_usage_amount,
  SUM(CAST(line_item_unblended_cost AS DECIMAL(16,8))) AS sum_line_item_unblended_cost 
FROM -- automation_from_stmt
  ${table_name} -- automation_tablename
WHERE -- automation_where_stmt
  ${date_filter} -- automation_timerange_year_month
  AND product_product_name = 'AmazonCloudWatch'
  AND line_item_line_item_type  IN ('DiscountedUsage', 'Usage', 'SavingsPlanCoveredUsage')
GROUP BY -- automation_groupby_stmt
  bill_payer_account_id, 
  line_item_usage_account_id,
  DATE_FORMAT(line_item_usage_start_date,'%Y-%m'), -- automation_timerange_dateformat
  line_item_usage_type,
  -- line_item_resource_id,
  line_item_operation
ORDER BY -- automation_order_stmt
sum_line_item_unblended_cost desc
;
