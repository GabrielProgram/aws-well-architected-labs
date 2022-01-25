---
title: "Add your own assumptions (using the Amazon Athena console)"
date: 2020-11-18T09:16:09-04:00
chapter: false
weight: 6
pre: "<b>2 </b>"
---

# Introduction

By now you have queried AWS Cost & Usage reports with Amazon Athena. You drew proxy metrics for sustainability from AWS usage data.
Calculating key performance indicators (KPIs), you might want to extend the queries with further assumptions/ data to reinforce sustainable best practices.

Some examples for further assumptions:

* preference of one EC2 instance family over another (e.g. [AWS Graviton](https://aws.amazon.com/ec2/graviton/) based instances)
* AWS Region preference by user location or the published carbon intensity of electricity grids
* preference of EC2 Spot instances to increase the overall utilization of the cloud's resources while decreasing cost

In this lab you will learn to make that data available to your queries as a simple view in Amazon Athena.

# Lab 2

1. Go the the [Amazon Athena console](https://console.aws.amazon.com/athena/home?#query) in the region where you deployed earlier the AWS Serverless Application Repository application in [lab 1.4]({{< ref "content/Sustainability/300_Labs/300_cur_reports_as_efficiency_reports/1-4_queries_from_sar.md" >}}).
2. Choose the Database `aws_usage_queries_database`, which you have deployed in [lab 1.4]({{< ref "content/Sustainability/300_Labs/300_cur_reports_as_efficiency_reports/1-4_queries_from_sar.md" >}}).
3. Execute the following query to get a list of regions which you use for Amazon EC2 instances. It will return a list of regions, like `us-east-1`, `ap-southeast-2`, and `eu-west-1`.
```sql
SELECT DISTINCT(region) FROM monthly_vcpu_hours_by_account
```
4. Let's create a table with weights to prefer regions where [AWS purchases and retires environmental attributes](https://sustainability.aboutamazon.com/environment/the-cloud?energyType=true), like Renewable Energy Credits and Guarantees of Origin, to cover the non-renewable energy used in these regions. Execute the following query:
```sql
SELECT 'eu-west-1' region, 1 points
UNION SELECT 'eu-central-1' region, 1 points
UNION SELECT 'ca-central-1' region, 1 points
UNION SELECT 'us-gov-west-1' region, 1 points
UNION SELECT 'us-west-2' region, 1 points
UNION SELECT 'ap-southeast-2' region, 2 points
UNION SELECT 'us-east-1' region, 2 points
[add further regions returned in your previous query with 2 points here]
```
5. To create a view from the select statement choose **Create** and then choose **Create view from query**.
6. Enter `region_points` as **Name**.
7. Choose **Create**.

Now you can do the same with the instance families to prefer the Graviton2 processor, the ARM-based AWS-designed chip. This is currently the most power efficient processor AWS offers to customers as Graviton 2 processors provide better performance per watt than any other EC2 processor.

1. Execute the following query to get a list of regions which you use for Amazon EC2 instances:
```sql
SELECT DISTINCT(instance_family) FROM monthly_vcpu_hours_by_account
```
2. Execute the following query to create a view list of instance families with their weights, like t2 (Intel), m5a (AMD), t4g (Graviton2), etc.
```sql
CREATE OR REPLACE VIEW instance_family_points AS
SELECT 't2' instance_family, 2 points
UNION SELECT 'c5' instance_family, 2 points
UNION SELECT 'm4' instance_family, 2 points
UNION SELECT 'm5' instance_family, 2 points
UNION SELECT 't3' instance_family, 2 points
UNION SELECT 'm5a' instance_family, 2 points
UNION SELECT 't4g' instance_family, 1 points
```
3. Now you can use points to weight the instance vCPU hours table. Execute the following query:
```sql
SELECT instance_family,
         region,
         account_id,
         purchase_option,
         SUM(vcpu_hours) vcpu_hours,
         year,
         month,
         SUM(f.points * r.points * vcpu_hours) points
FROM monthly_vcpu_hours_by_account
JOIN region_points r
USING (region)
JOIN instance_family_points f
USING (instance_family)
GROUP BY instance_family, region, account_id, purchase_option, year, month
ORDER BY 8 DESC
```

Congratulations! You have put additional assumptions into views to extend the usage data by weights. You can now continue with Lab 3 to see how you could add the additional views and tables in an Infrastructure as Code (IaC) approach.

{{< prev_next_button link_prev_url="../1-4_queries_from_sar" link_next_url="../3_add_assumptions_iac" />}}
