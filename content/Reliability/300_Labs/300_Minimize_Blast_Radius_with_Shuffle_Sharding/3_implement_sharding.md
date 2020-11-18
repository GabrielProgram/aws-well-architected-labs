---
title: "Implement sharding"
date: 2020-11-18T11:16:09-04:00
chapter: false
pre: "<b>3. </b>"
weight: 3
---

In this section we will update the architectural design of the workload and implement a sharding mechanism. Similar to sharding a database where a large database or table is broken up into smaller chunks distributed across multiple servers, we will shard the overall capacity of the workload and segment it so that each shard is responsible for handling a subset of customers only. By minimizing the number of "components" a single customer is able to interact with within the workload, we will be able to reduce the impact of a potential posion pill. This will result in a much smaller blast radius depending on the number of shards within the workload. In a sharded system, blast radius of failures can be calculated using the following formula:

                                              Blast radius = |customers|/|shards|

For example if there were 100 customers, and the workload was divided into 10 shards, then the failure of any 1 shard will only impact 10% of customers.

![ArchitectureSharding](/Reliability/300_Minimize_Blast_Radius_with_Shuffle_Sharding/Images/Architecture-sharding.png)

### Update the workload architecture

1. Go to the AWS CloudFormation console at <https://console.aws.amazon.com/cloudformation> and select the stack that was created as part of this lab - `Shuffle-sharding-lab`
1. Click on **Update**

    ![CFNUpdateStack](/Reliability/300_Minimize_Blast_Radius_with_Shuffle_Sharding/Images/CFNUpdateStack.png)

1. Under **Prerequisite - Prepare template**, select **Replace current template**

    * For **Template source** select **Amazon S3 URL**
    * In the text box under **Amazon S3 URL** specify `https://aws-well-architected-labs-virginia.s3.amazonaws.com/Reliability/300_Minimize_Blast_Radius_with_Shuffle_Sharding/sharding.yaml`

    ![CFNReplaceTemplateSharding](/Reliability/300_Minimize_Blast_Radius_with_Shuffle_Sharding/Images/CFNReplaceTemplateSharding.png)

1. Click **Next**
1. No changes are required for **Parameters**. Click **Next**
1. For **Configure stack options** click **Next**
1. On the **Review** page:
    * Scroll to the end of the page and select **I acknowledge that AWS CloudFormation might create IAM resources with custom names.** This ensures CloudFormation has permission to create resources related to IAM. Additional information can be found [here](https://docs.aws.amazon.com/AWSCloudFormation/latest/APIReference/API_CreateStack.html).

    **Note:** The template creates an IAM role and Instance Profile for EC2. These are the minimum permissions necessary for the instances to be managed by AWS Systems Manager. These permissions can be reviewed in the CloudFormation template under the "Resources" section - *InstanceRole*.

    * Click **Update stack**

    ![CFNIamCapabilities](/Reliability/300_Minimize_Blast_Radius_with_Shuffle_Sharding/Images/CFNIamCapabilities.png)

This will take you to the CloudFormation stack status page, showing the stack update in progress. The stack takes about 1 minute to go through all the updates. Periodically refresh the page until you see that the **Stack Status** is in **UPDATE_COMPLETE**.

With this stack update, the architecture of the workload has been updated by introducing 2 Application Load Balancer listener rules and Target Groups. These listener rules have been configured to inspect the incoming request for a query-string **name**. Depending on the value provided, the request is routed to one of two target groups where each target group consists of 2 EC2 instances.

### Test the sharded application

Now that the application has been deployed, it is time to test it to understand how it works. The sample application used in this lab is a simple web application that returns a message with the instance ID of the instance that responded to the request. Customers pass in a query string with the request to identify themselves. The query string used here is **name**.

1. Copy the URL provided in the **Outputs** section of the CloudFormation stack created in the previous string. Append the query string `/?name=Alpha` to the URL and paste it into a web browser. The full string should look similar to this - http://shuffle-alb-1p2xbmzo541rr-1602891463.us-east-1.elb.amazonaws.com/?name=Alpha

    ![CFNOutputs](/Reliability/300_Minimize_Blast_Radius_with_Shuffle_Sharding/Images/CFNOutputs.png)

1. Refresh the web browser a few times to see that responses are being returned from different EC2 instances on the back-end. Notice that after implementing sharding, you are seeing responses being returned from only 2 instances for customer Alpha's requests. No matter how many times you refresh the page or try a different browser, customer Alpha will only receive responses from 2 EC2 instances. This is because we have created Application Load Balancer listener rules that divert traffic to a specific subset of the overall capacity of the workload, also known as a shard. In this case, customers Alpha, Bravo, and Charlie are mapped to Node 1 and Node 2, and customers Delta, Echo, and Foxtrot are mapped to Node 3 and Node 4.

    ![ShardedFlow](/Reliability/300_Minimize_Blast_Radius_with_Shuffle_Sharding/Images/ShardedFlow.png)

1. Update the value for the query string to one of the other customers, the possible values are - Alpha, Bravo, Charlie, Delta, Echo, and Foxtrot

    * http://shuffle-alb-8vonmf2ywl5z-682850122.us-east-1.elb.amazonaws.com/?name=Alpha
    * http://shuffle-alb-8vonmf2ywl5z-682850122.us-east-1.elb.amazonaws.com/?name=Bravo
    * http://shuffle-alb-8vonmf2ywl5z-682850122.us-east-1.elb.amazonaws.com/?name=Charlie
    * http://shuffle-alb-8vonmf2ywl5z-682850122.us-east-1.elb.amazonaws.com/?name=Delta
    * http://shuffle-alb-8vonmf2ywl5z-682850122.us-east-1.elb.amazonaws.com/?name=Echo
    * http://shuffle-alb-8vonmf2ywl5z-682850122.us-east-1.elb.amazonaws.com/?name=Foxtrot

1. Refresh the web browser multiple times to verify that customers are receiving responses only from EC2 instances in the shard they are mapped to
