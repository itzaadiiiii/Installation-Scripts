echo '######################################'
System Uptime
                                                             
echo '----------------------------------'
uptime
echo '######################################'

Todays Date
echo '----------------------------------'
date

echo '######################################'

echo 'Memory Utilization'
echo '----------------------------------'
free -m

echo '######################################'

echo 'AWS User Details'

aws sts get-caller-identity
echo '######################################'

echo 'Cloud resources Running'
echo 'Instance Id AWS EC2 Instance'
aws ec2 describe-instances | jq '.Reservations[].Instances[].InstanceId'

echo '######################################'
