-- modified: 2021-04-25

SELECT -- automation_select_stmt
  bill_payer_account_id,
  line_item_usage_account_id,
  DATE_FORMAT((line_item_usage_start_date),'%Y-%m-%d') AS day_line_item_usage_start_date, -- automation_timerange_dateformat
  SPLIT_PART(SPLIT_PART(line_item_resource_id,':',6),'/',2) AS split_line_item_resource_id,
  CASE
    WHEN line_item_usage_type LIKE '%Fargate-GB%' THEN 'GB per hour'
    WHEN line_item_usage_type LIKE '%Fargate-vCPU%' THEN 'vCPU per hour'
  END AS case_line_item_usage_type,
  CASE line_item_line_item_type
    WHEN 'SavingsPlanCoveredUsage' THEN savings_plan_offering_type
    WHEN 'SavingsPlanNegation' THEN savings_plan_offering_type
    ELSE 
      CASE pricing_term
        WHEN 'OnDemand' THEN 'OnDemand'
        WHEN '' THEN 'Spot Instance'
        ELSE pricing_term
      END
  END AS case_purchase_option,
  SUM(CAST(line_item_usage_amount AS DOUBLE)) AS sum_line_item_usage_amount,
  SUM(CASE pricing_term
    WHEN 'OnDemand' THEN line_item_unblended_cost
    WHEN '' THEN line_item_unblended_cost
    END) AS sum_line_item_unblended_cost,
  SUM(CASE
    WHEN line_item_line_item_type = 'SavingsPlanCoveredUsage' THEN savings_plan_savings_plan_effective_cost
    WHEN line_item_line_item_type = 'SavingsPlanRecurringFee' THEN savings_plan_total_commitment_to_date - savings_plan_used_commitment
    WHEN line_item_line_item_type = 'SavingsPlanNegation' THEN 0
    WHEN line_item_line_item_type = 'SavingsPlanUpfrontFee' THEN 0
    WHEN line_item_line_item_type = 'DiscountedUsage' THEN reservation_effective_cost
    ELSE line_item_unblended_cost 
  END) AS sum_amortized_cost
FROM -- automation_from_stmt
  ${table_name} -- automation_tablename
WHERE -- automation_where_stmt
  ${date_filter} -- automation_timerange_year_month
  AND line_item_product_code IN ('AmazonECS')
  AND line_item_operation != 'ECSTask-EC2'
  AND product_product_family != 'Data Transfer'
  AND line_item_line_item_type  IN ('DiscountedUsage', 'Usage', 'SavingsPlanCoveredUsage')
GROUP BY -- automation_groupby_stmt
  bill_payer_account_id,
  line_item_usage_account_id,
  DATE_FORMAT((line_item_usage_start_date),'%Y-%m-%d'),
  SPLIT_PART(SPLIT_PART(line_item_resource_id,':',6),'/',2),
  5, --refers to case_line_item_usage_type
  6 -- refers to case_purchase_option
ORDER BY -- automation_order_stmt
  day_line_item_usage_start_date ASC,
  case_purchase_option,
  sum_line_item_usage_amount DESC
;

