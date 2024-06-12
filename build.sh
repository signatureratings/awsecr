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
    aws ecr create-repository --repository-name "${repository_name}"
fi 

echo "Building services"

cd services 

for service in */ ; do
    service=${service%*/}
    echo "Building service: $service"
    cd $service
    docker build -t $service:latest .
    docker tag $service:latest $regsitry_name/$repository_name:$service-$image_tag
    docker push $regsitry_name/$repository_name:$service-$image_tag
    cd ..
done



