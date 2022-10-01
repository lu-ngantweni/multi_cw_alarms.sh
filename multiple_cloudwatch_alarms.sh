#The provided script will assist with creating multiple "StatusCheckFailed" alarms, As currently EC2 does not provide the option to create alarms for multiple instances at once.

#!/bin/bash
listInstances='/tmp/Instances.txt'
instances=$(aws ec2 describe-instances --region eu-west-2 --query "Reservations[*].Instances[*].[InstanceId]" --filters Name=instance-state-name,Values=running --output text)
echo ${instances} > ${listInstances}
for Instance in `cat ${listInstances}`
do
	 echo $Instance
	 aws cloudwatch put-metric-alarm \
        --region eu-west-2\
        --alarm-name status-check-${Instance} \
        --alarm-description "Alarm when instance experience status check fail" \
        --metric-name "StatusCheckFailed" \
        --namespace "AWS/EC2" \
        --statistic "Sum" \
        --period 300 \
        --threshold 0 \
        --comparison-operator "GreaterThanThreshold"  \
        --dimensions "Name=InstanceId","Value=${Instance}" \
        --evaluation-periods 1 \
        --alarm-actions "arn:aws:sns:eu-west-2:<AccountID>:StatusCheckFailed" \
        --unit Count
done
