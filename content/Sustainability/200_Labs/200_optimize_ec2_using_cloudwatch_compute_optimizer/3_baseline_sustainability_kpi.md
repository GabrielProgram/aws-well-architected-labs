---
title: "Baseline Sustainability KPI"
date: 2020-11-18T09:16:09-04:00
chapter: false
weight: 4
pre: "<b>3. </b>"
---

## Overview

Let’s baseline the metrics which we can use to measure sustainability improvement once workload optimization is completed. In this case, we will create proxy metrics to monitor a total number of vCPU of Amazon EC2 Instance, business metrics for outcome that is number of API calls served (business outcome) and also sustainability key performance indicator (KPI) which is resources provisioned per unit of work.

You will learn more about the following [design principles](https://docs.aws.amazon.com/wellarchitected/latest/sustainability-pillar/design-principles-for-sustainability-in-the-cloud.html) in AWS Well-Architected Sustainability Pillar:
* Understand your impact
* Establish sustainability goals

### 3.1. Understand what you have provisioned in AWS (Proxy metrics)
The resources provisioned to support your workload include compute, storage, and network resources. Evaluate the resources provisioned using your proxy metrics to see how those resources are consumed.

1. Expand **Metrics** and click **All metrics**. In Custom namespaces, there will be a new namespace named **Sustainability**. Click Sustainability.
![Section3 custom_namespace](/Sustainability/200_optimize_ec2_using_cloudwatch_compute_optimizer/Images/section3/custom_namespace.png)

2. Tick a box to see if you see total number of vCPU of Amazon EC2 Instance you just deployed. It will be **4** as expected. This will be used for proxy metrics that best reflect the type of improvement you are evaluating and the resources targeted by improvement.
![Section3 totalvcpu](/Sustainability/200_optimize_ec2_using_cloudwatch_compute_optimizer/Images/section3/totalvcpu.png)

### 3.2. Create Business Metrics
Your business metrics should reflect the value provided by your workload, for example, the number of simultaneous active users, API calls served, or the number of transactions completed. 

1. Click **Log groups** and click **httpd_access_log** that records all inbound requests handled by HTTP endpoints. 
![Section3 httpd_access_log](/Sustainability/200_optimize_ec2_using_cloudwatch_compute_optimizer/Images/section3/httpd_access_log.png)

2. Click **Metric filters** tab. 
![Section3 metric_filter](/Sustainability/200_optimize_ec2_using_cloudwatch_compute_optimizer/Images/section3/metric_filter.png)

3. You are going to define business metrics to quantify the achievement of business outcome. Click **Create metric filter** to monitor a specific pattern in access log. 
![Section3 create_metric_filter](/Sustainability/200_optimize_ec2_using_cloudwatch_compute_optimizer/Images/section3/create_metric_filter.png)

4. Define pattern to monitor the number of requests of **load.php** page that is a critical for your business. Specify **"GET /load.php"** as filter pattern to match it in access log.
    ```
    "GET /load.php"
    ```
    Select log as **your_EC2_instance_id/var/log/httpd/access_log** to test and click **Test pattern** button. You should be able to see 3 http requests per minute.

![Section3 define_pattern](/Sustainability/200_optimize_ec2_using_cloudwatch_compute_optimizer/Images/section3/define_pattern.png)


Scroll down to the bottom to click **Next**.

![Section3 next](/Sustainability/200_optimize_ec2_using_cloudwatch_compute_optimizer/Images/section3/next.png)

5. Provide Metric details.

    1. Create a filter name as **load.php**. 
    ```
    load.php
    ```
    2. **Click radio slider** as you will select the existing metric namespace.  
    3. Use **Sustainability** as Metric namespace.
    4. Specify **BusinessMetrics** as metric name.
    ```
    BusinessMetrics
    ```
    5. set Metric value to **1** and click **Next**.

![Section3 mectic_details](/Sustainability/200_optimize_ec2_using_cloudwatch_compute_optimizer/Images/section3/mectic_details.png)

6. Review all values and click **Create metric filter**.
![Section3 review](/Sustainability/200_optimize_ec2_using_cloudwatch_compute_optimizer/Images/section3/review.png)

7. Click **BusinessMetrics** to see the metrics you just created. 
![Section3 business_metrics](/Sustainability/200_optimize_ec2_using_cloudwatch_compute_optimizer/Images/section3/business_metrics.png)

8. Click **Sustainability > Metrics with no dimensions**.
![Section3 sustainability_meteics](/Sustainability/200_optimize_ec2_using_cloudwatch_compute_optimizer/Images/section3/sustainability_meteics.png)

9. Tick a box to see the number of units of "GET /load.php" is being monitored. 
![Section3 check_metrics](/Sustainability/200_optimize_ec2_using_cloudwatch_compute_optimizer/Images/section3/check_metrics.png)


### 3.3. Create Sustainability Key Performance Indicator Baseline

Let's evaluate specific improvement and our KPI is vCPU minutes per transaction and remember our improvement goal is to Maximize utilization of provisioned resources.

1. Click **Dashboards** 
![Section3 kpi_dashboard](/Sustainability/200_optimize_ec2_using_cloudwatch_compute_optimizer/Images/section3/kpi_dashboard.png)

2. Click **Create dashboard**. 
![Section3 create_kpi_dashboard](/Sustainability/200_optimize_ec2_using_cloudwatch_compute_optimizer/Images/section3/create_kpi_dashboard.png)

3. For Dashboard name, use **SustainabilityApp-KPI** and click **Create dashboard**.
![Section3 create_kpi_dashboard2](/Sustainability/200_optimize_ec2_using_cloudwatch_compute_optimizer/Images/section3/create_kpi_dashboard2.png)

4. Select **Line**.
![Section3 select_line](/Sustainability/200_optimize_ec2_using_cloudwatch_compute_optimizer/Images/section3/select_line.png)

5. Select **Metrics**.
![Section3 select_metrics](/Sustainability/200_optimize_ec2_using_cloudwatch_compute_optimizer/Images/section3/select_metrics.png)

6. Select **Sustainability**.
![Section3 mectics_name](/Sustainability/200_optimize_ec2_using_cloudwatch_compute_optimizer/Images/section3/mectics_name.png)

7. Select **Instance**.
![Section3 instance](/Sustainability/200_optimize_ec2_using_cloudwatch_compute_optimizer/Images/section3/instance.png)

8. Tick a box to select EC2 Instance ID in which SustainabilityApp is running and click **Sustainatility** to go back. 
![Section3 instance_id](/Sustainability/200_optimize_ec2_using_cloudwatch_compute_optimizer/Images/section3/instance_id.png)

9. Click **Metrics with no dimensions**. 
![Section3 metrics_no_dimensions](/Sustainability/200_optimize_ec2_using_cloudwatch_compute_optimizer/Images/section3/metrics_no_dimensions.png)

10. Tick a box to select **BusinessMetrics** at step 3.2 and select **Graphed metrics** tab.
![Section3 graphed_metrics](/Sustainability/200_optimize_ec2_using_cloudwatch_compute_optimizer/Images/section3/graphed_metrics.png)

11. Let's change **Statistic** and **Period**. 
![Section3 statistic_period](/Sustainability/200_optimize_ec2_using_cloudwatch_compute_optimizer/Images/section3/statistic_period.png)

    We are going to use [CloudWatch metrics with metric math function](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/using-metric-math.html).
    1. For total number of vCPU, change statistic from Average to **Maximum**. 
    2. Let's set period to **1 minute**. 
    3. For Business Metrics, change statistic from Average to **Sum**.
    4. Let's set period to **1 minute**.
    5. Click **Add math**.
    6. Select **Start with empty expression**.

12. Using the following formula, divide the provisioned resources by the business outcomes achieved to determine the provisioned resources per unit of work. 
**Formula:**
![Section3 formula](/Sustainability/200_optimize_ec2_using_cloudwatch_compute_optimizer/Images/section3/formula.png)
![Section3 kpi](/Sustainability/200_optimize_ec2_using_cloudwatch_compute_optimizer/Images/section3/kpi.png)
    
    Divide total number of vCPU by the number of requests per a minute to achieve business outcome. 
    Update math expression as follows and click **Apply**.
    ```
    m1/m2
    ```
13. Click **Expression** and use **Resources provisioned per unit of work**. Click **Apply** and **Create widget**.
![Section3 expression](/Sustainability/200_optimize_ec2_using_cloudwatch_compute_optimizer/Images/section3/expression.png)

    1. Click **Expression**.
    2. Provide **Resources provisioned per unit of work** as Label.
    3. Click **Apply**.
    4. Click **Create widget**.

14. Click **Save** button to continuously monitor KPI after reducing idle resources and maximizing utilization in next step. We will use Resources provisioned per unit of work as sustainability KPI.

    With, that below are baseline metrics and KPI:

        * Proxy Metric - Total number of vCPUs = 4
        * Business Metric - Total number of APIs = 3
        * KPI - Per request vCPU = 4 / 3 requests = 1.333
    
    Sustainability KPI Baseline value appears to be **1.33333**
![Section3 kpi_baseline](/Sustainability/200_optimize_ec2_using_cloudwatch_compute_optimizer/Images/section3/kpi_baseline.png)
    

{{< prev_next_button link_prev_url="../2_configure_env" link_next_url="../4_reducing_idle_resources_and_maximizing_utilization" />}}
