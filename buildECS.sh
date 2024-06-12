ecs_cluster_name="ecs-cluster"
image_tag=$IMAGE_TAG

echo "Checking ECS cluster exists or not"

if [ $(aws ecs list-clusters --query clusters --output table | grep -c $ecs_cluster_name) -eq 1 ]; then
    echo "ECS cluster exists"
else
    echo "Creating ECS cluster"
    aws ecs create-cluster --cluster-name $ecs_cluster_name
    echo "ECS cluster created successfully"
fi

# Create ECS task definitions
cd services 

for service in */ ; do
    service=${service%*/}
    echo "Creating task definitions for: $service"
    cd $service
    task_definition_file="${service}Service.json"

    if [ -f "$task_definition_file" ]; then
        echo "Task definition file exists. Creating task..."
        perl -pi -e "s|IMAGE_TAG_PLACEHOLDER|$image_tag|g" $task_definition_file
        aws ecs register-task-definition --cli-input-json file://$task_definition_file
        if [ $? -eq 0 ]; then
            echo "Task definition created successfully"
        else 
            echo "Failed to create task definition"
        fi
    else
        echo "Task definition file does not exist. Skipping task creation."
    fi
    
    cd ..
done

cd ..
# Create ECS service
cd services

for service in */ ; do
    service=${service%*/}
    echo "Creating service for: $service"
    cd $service
    service_name="${service}-service"
    task_definition_name="${service}-task-definition"
    SERVICE_EXISTS=$(aws ecs describe-services --cluster $ecs_cluster_name --services $service_name --query "services[0].serviceName" --output text)
    if [ "$SERVICE_EXISTS" == "$service_name" ]; then
        echo "Service already exists. Updating service..."
        aws ecs update-service --cluster $ecs_cluster_name --service $service_name --task-definition $task_definition_name --desired-count 1 
    else
        echo "Service does not exist. Creating service..."
        aws ecs create-service --cluster $ecs_cluster_name \
        --service-name $service_name --task-definition $task_definition_name --desired-count 1 \
        --launch-type FARGATE
    
    if [ $? -eq 0 ]; then
        echo "Service created/updated successfully"
    else
        echo "Failed to create service"
    fi
    cd ..