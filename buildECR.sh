regsitry_name=$ECR_REGISTRY
repository_name=$ECR_REPOSITORY
region=$AWS_REGION
image_tag=$IMAGE_TAG

echo "Checking repository exists or not"
# Check if the repository exists
aws ecr describe-repositories --repository-names "${repository_name}" > /dev/null 2>&1

# If the repository does not exist, create it
if [ $? -ne 0 ]
then
    echo "Could not find ECR repository ${repository_name}. Creating it..."
    aws ecr create-repository --repository-name "${repository_name}"
    echo "Repository created Successfully."
fi 

echo "Building services"

cd services 

for service in */ ; do
    service=${service%*/}
    echo "Building service: $service"
    cd $service
    #task_definition_file="${service}Service.json"
    #perl -pi -e "s|IMAGE_TAG_PLACEHOLDER|$image_tag|g" $task_definition_file
    docker build -t $service:latest .
    docker tag $service:latest $regsitry_name/$repository_name:$service-latest
    docker push $regsitry_name/$repository_name:$service-latest
    cd ..
done



