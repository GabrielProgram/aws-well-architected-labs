---
title: "Create Cost Categories"
date: 2023-02-12T11:16:09-04:00
chapter: false
weight: 4
pre: "<b>4. </b>"
---

## Overview

AWS **Cost Categories** is a feature within **AWS Cost Management** product
suite that enables you to group cost and usage information into
meaningful categories based on your needs. You can create custom
categories and map your cost and usage information into these categories
based on the rules defined by you using various dimensions such as
account, tag, service, charge type, and even other cost categories. Once
cost categories are set up and enabled, you will be able to view your
cost and usage information by these categories starting at the beginning
of the month in AWS Cost Explorer, AWS Budgets, and AWS Cost and Usage
Report (CUR).

You can create cost categories to **organize your cost and usage information**. Regular accounts and the management account in AWS
Organizations have default access to create cost categories. Rules
aren\'t mutually exclusive, and you can control the order that the rules
apply in.

{{% notice note %}}
**Note** - Allow up to 24 hours after creating a cost category for
your usage records to be updated with values.
{{% /notice %}}

#### Console:

1. Sign in to the AWS Management Console using management account admin
    credentials and open the AWS Billing console at
    [https://console.aws.amazon.com/billing/](https://console.aws.amazon.com/billing/)
 ![Section4 Billing](/Cost/200_Cost_Category/Images/section4/billingService.png)

2. In the navigation pane, choose **AWS Cost Categories**.
 ![Section4 CostCategories](/Cost/200_Cost_Category/Images/section4/costCategoriesService.png)

3. At the top of the page, choose **Create Cost category**. 

  Note: For our current lab purpose we will create two cost categories for
  simplification and better understanding of the service. However you
  can also create complex cost categories by following
  <https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/create-cost-categories.html>
  documentation.
 ![Section4 CreateCostCategories](/Cost/200_Cost_Category/Images/section4/createCostCategory.png)

4. Under **Cost category details**, enter the name of your cost
    category as **cost by team**. Your cost category name must be unique
    within your account. Keep rest of the fields with default values and
    click **Next**
 ![Section4 NameCostCategoryTeam](/Cost/200_Cost_Category/Images/section4/nameCostCategoryTeam.png)

5. In **Define category rules** , Under **new category rule** choose **inherited value** as **rule type** , ** choose **Cost Allocation Tag** as **dimension** and **TeamName** as **Tag Key, ** click **Next.**
 ![Section4 DefineCostCategoriesRulesTeam](/Cost/200_Cost_Category/Images/section4/defineCatgoryRulesTeam.png)

6. Skip **Define split charges** for this lab. 
    
   Note : For more information on **split charges** please visit
   <https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/splitcharge-cost-categories.html>
   ![Section4 DefineSplitCharges](/Cost/200_Cost_Category/Images/section4/defineSplitCharges.png)

8. Choose **Create cost category**.
   

9. Repeat step-1 to step-3 and then under **Cost category details**,
    enter the name of your cost category as "cost by department".
 ![Section4 NameCostCategoryDept](/Cost/200_Cost_Category/Images/section4/nameCostCategoryDept.png)

10. In **Define category rules**, Under **new category rule** choose **inherited value** as **rule type**, ** choose **Cost Allocation Tag** as **dimension** and **Department** as **Tag Key** , click on **Add rule** and choose **inherited value** as **rule type**,  choose **Cost Allocation Tag** as **dimension** and **CostCentre** as **Tag Key**.
 ![Section4 DefineCostCategoriesRulesDept](/Cost/200_Cost_Category/Images/section4/defineCategoryRulesDept.png)

11. Repeat step 6 & 7

### Congratulations!

You have completed this section of the lab. In this section you created
two cost categories using **Cost Categories** under **AWS Billing**
service.

Click on **Next Step** to continue to the next section.

{{< prev_next_button link_prev_url="../3_configure_cost_allocation_tags/" link_next_url="../5_visualize_in_cost_explorer/" />}}
