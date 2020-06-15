# ECS Agent Monitor

### Context

The ECS Agent is responsible for managing containers on behalf of Amazon ECS, if the ECS agent is not running on an ECS container instance, ECS will be unable to start/stop containers and receive events.

### Solution

I have developed a simple script which checks the status of the ECS agent and sends data points to a CloudWatch metric. If the health of the ECS agent is ok, it will report a value of "0" and if the ECS agent is not working, it will report a value of "1". Then, we can create a CloudWatch alarm, send a notification to a SNS topic and trigger a Lambda function to terminate the instance or alert us to investigate what happened.

You can use the following cron job to run the monitor every minute.

```
* * * * * /opt/ecs_agent_monitor.sh
```

This is how the metric looks like in CloudWatch.

![CW Metric](/images/cw_metric.png)

This is the only IAM permission needed to send the data points to CloudWatch:

```
"Action": "cloudwatch:PutMetricData"
```

Last, I also considered the following options to monitor the status of the agent, but they are not reliable:

- Trigger a CloudWatch Event when the ECS service triggers the event type "Container Instance State Change Events" [1] and use a pattern to filter in the json the status of the ECS agent. This is not convenient because the ECS agent periodically disconnects and reconnects (several times per hour) as a part of its normal operation, so agent connection events should be expected.

- Trigger a CloudWatch Event when CloudTrail logs a "RunTask" operation and use a pattern to filter by ""reason": "AGENT"" [2]. It will only happen if the ECS agent of the ECS container instance where the scheduler decided to place the task is disconnected. For example, if we have 20 instances and only 1 has the ECS agent disconnected, the task will be placed and we will not receive this error.

References:

[1] https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_cwe_events.html

[2] https://docs.aws.amazon.com/AmazonECS/latest/developerguide/api_failures_messages.html
