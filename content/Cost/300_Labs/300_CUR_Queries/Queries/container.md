---
title: "Container"
date: 2021-01-22T14:56:09-04:00
chapter: false
weight: 5.0
pre: "<b> </b>"
---

These are queries for AWS Services under the [Container product family](https://aws.amazon.com/containers).  

{{% notice tip %}}
Use the clipboard in the top right of the text boxes below to copy all of the text to be pasted.
{{% /notice %}}

{{% notice info %}}
You may need to change variables used as placeholders in your query. **${table_Name}** is a common variable which needs to be replaced. **Example: cur_db.cur_table**
{{% /notice %}}

### Table of Contents

{{< expand "Amazon Elastic Container Services" >}}

{{% markdown_wrapper %}}

#### Query Description
This query will output the daily cost and usage per resource, by operation and service, for Elastic Consainer Services, ECS and EKS, both unblended and amortized costs are shown.  To provide you with a complete picture of the data, to match totals in cost explorer, if you are using Savings Plans you will likely see results with *blank* resource IDs, these represent the Savings Plans Negation values for compute cost already covered by Savings Plans.

#### Pricing
Please refer to the [Amazon ECS pricing page](https://aws.amazon.com/ecs/pricing/) and the [Amazon EKS pricing page](https://aws.amazon.com/eks/pricing/).

#### Sample Output
*Sample output includes a subset of query columns*
![Images/ecs_eks.png](/Cost/300_CUR_Queries/Images/Container/ecs_eks.png)

#### Download SQL File
[Link to Code](/Cost/300_CUR_Queries/Code/Container/ecs_eks.sql)

#### Copy Query
    SELECT
      bill_payer_account_id,
      line_item_usage_account_id,
      SPLIT_PART(line_item_resource_id,':',6) as split_line_item_resource_id,
      DATE_FORMAT((line_item_usage_start_date),'%Y-%m-%d') AS day_line_item_usage_start_date,
      line_item_operation,
      line_item_product_code,
      SUM(CAST(line_item_usage_amount AS double)) AS sum_line_item_usage_amount,
      SUM(line_item_unblended_cost) "sum_line_item_unblended_cost"
    , sum(CASE
        WHEN ("line_item_line_item_type" = 'SavingsPlanCoveredUsage') THEN "savings_plan_savings_plan_effective_cost"
        WHEN ("line_item_line_item_type" = 'SavingsPlanRecurringFee') THEN ("savings_plan_total_commitment_to_date" - "savings_plan_used_commitment")
        WHEN ("line_item_line_item_type" = 'SavingsPlanNegation') THEN 0
        WHEN ("line_item_line_item_type" = 'SavingsPlanUpfrontFee') THEN 0
        WHEN ("line_item_line_item_type" = 'DiscountedUsage') THEN "reservation_effective_cost"
          ELSE "line_item_unblended_cost" END) "amortized_cost"
    FROM
      ${table_name}
    WHERE
      year = '2020' AND (month BETWEEN '7' AND '9' OR month BETWEEN '07' AND '09')
      and line_item_product_code in ('AmazonECS','AmazonEKS')
      AND line_item_line_item_type NOT IN ('Tax','Credit','Refund','EdpDiscount')
    GROUP BY
      bill_payer_account_id,
      line_item_usage_account_id,
      3,
      4,
      line_item_operation,
      line_item_product_code
    ORDER BY
      day_line_item_usage_start_date,
      sum_line_item_unblended_cost,
      sum_line_item_usage_amount,
      line_item_operation;

{{% /markdown_wrapper %}}

{{% email_button category_text="Container" service_text="Amazon ECS" query_text="Amazon ECS/EKS Query" button_text="Help & Feedback" %}}

{{< /expand >}}

{{< expand "Amazon ECS - Daily Usage Hours and Cost by Usage Type and Purchase Option" >}}

{{% markdown_wrapper %}}

#### Query Description
This query will output the daily ECS cost and usage per resource, by usage type and purchase option, both unblended and amortized costs are shown.  To provide you with a complete picture of the data, to match totals in cost explorer, if you are using Savings Plans you will likely see results with *blank* resource IDs, these represent the Savings Plans Negation values for compute cost already covered by Savings Plans.

#### Pricing
Please refer to the [Amazon ECS pricing page](https://aws.amazon.com/ecs/pricing/).

#### Sample Output
*Sample output includes a subset of query columns*
![Images/ecs_hours_day.png](/Cost/300_CUR_Queries/Images/Container/ecs_hours_day.png)

#### Download SQL File
[Link to Code](/Cost/300_CUR_Queries/Code/Container/ecs_hours_day.sql)

#### Copy Query
    SELECT
      bill_payer_account_id,
      line_item_usage_account_id,
      DATE_FORMAT((line_item_usage_start_date),'%Y-%m-%d') AS day_line_item_usage_start_date,
      SPLIT_PART(SPLIT_PART(line_item_resource_id,':',6),'/',2) AS split_line_item_resource_id,
      CASE
        WHEN line_item_usage_type LIKE '%%Fargate-GB%%' THEN 'GB per hour'
        WHEN line_item_usage_type LIKE '%%Fargate-vCPU%%' THEN 'vCPU per hour'
      END AS case_line_item_usage_type,
      CASE line_item_line_item_type
        WHEN 'SavingsPlanCoveredUsage' THEN
          CASE savings_plan_offering_type
            WHEN 'ComputeSavingsPlans' THEN 'Compute Savings Plans'
            ELSE savings_plan_offering_type
          END
        WHEN 'SavingsPlanNegation' THEN
          CASE savings_plan_offering_type
            WHEN 'ComputeSavingsPlans' THEN 'Compute Savings Plans'
            ELSE savings_plan_offering_type
          END
        ELSE
          CASE pricing_term
            WHEN 'OnDemand' THEN 'OnDemand'
            WHEN '' THEN 'Spot Instance'
            ELSE pricing_term
          END
      END AS case_pricing_term,
      SUM(CAST(line_item_usage_amount AS double)) AS sum_line_item_usage_amount,
      SUM(CASE pricing_term
        WHEN 'OnDemand' THEN line_item_unblended_cost
        WHEN '' THEN line_item_unblended_cost
        END) AS sum_line_item_unblended_cost,
      SUM(CASE
        WHEN ("line_item_line_item_type" = 'SavingsPlanCoveredUsage') THEN "savings_plan_savings_plan_effective_cost"
        WHEN ("line_item_line_item_type" = 'SavingsPlanRecurringFee') THEN ("savings_plan_total_commitment_to_date" - "savings_plan_used_commitment")
        WHEN ("line_item_line_item_type" = 'SavingsPlanNegation') THEN 0
        WHEN ("line_item_line_item_type" = 'SavingsPlanUpfrontFee') THEN 0
        WHEN ("line_item_line_item_type" = 'DiscountedUsage') THEN "reservation_effective_cost"
          ELSE "line_item_unblended_cost" END) "amortized_cost"
      FROM
        ${table_name}
      WHERE
        year = '2020' AND (month BETWEEN '7' AND '9' OR month BETWEEN '07' AND '09')
        AND line_item_product_code in ('AmazonECS')
        AND line_item_operation != 'ECSTask-EC2'
        AND product_product_family != 'Data Transfer'
        AND line_item_line_item_type NOT IN ('Tax','Credit','Refund','EdpDiscount')
      GROUP BY
        bill_payer_account_id,
        line_item_usage_account_id,
        3,
        4,
        5,
        6
      ORDER BY
        day_line_item_usage_start_date ASC,
        case_pricing_term,
        sum_line_item_usage_amount DESC;

{{% /markdown_wrapper %}}

{{% email_button category_text="Container" service_text="Amazon ECS" query_text="Amazon ECS Daily Usage Hours and Cost by Usage Type and Purchase Option" button_text="Help & Feedback" %}}

{{< /expand >}}

{{% notice note %}}
CUR queries are provided as is. We recommend validating your data by comparing it against your monthly bill and Cost Explorer prior to making any financial decisions. If you wish to provide feedback on these queries, there is an error, or you want to make a suggestion, please email: curquery@amazon.com
{{% /notice %}}






