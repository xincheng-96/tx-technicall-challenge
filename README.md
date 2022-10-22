This code deploys in AWS:
- VPC
- EKS cluster
- autoscaler and metrics
- ALB ingress
- AWS user

Technical challenge

1) Please develop an application in Python or Nodejs which encodes the text passed as input.
Encoding will add 5 positions. For example :

“AbcXyz” -> “FghCde”
“012789” -> “567234”
“TX Group was found in 2019” ->

Make the application expose a REST API with the following routes on the port 80
- GET /{n} returns a JSON payload with the result of the application transformation
- GET /status return the JSON payload : {"status":"ok"}
 
2) A docker image of the App has to be built and pushed to a container registry. We expect this process to be triggered whenever a pull request to change the content of the Docker folder is made.
Structure:
	.github/workflows - stores github action code
	values - stores helm charts values
	doker - stores the docker file and scripts
 
3) The docker image has to be retrieved from the registry and deployed as a Docker container in the EKS cluster (through helm or terraform).
Requirements:
	2 replicas, in different AZ
	use the already defined ingress

There's no need to test the deployment in AWS, since it might cause some costs. Our goal is to test:
- coding skills
- docker skills
- CICD skills
- terraform skills
- AWS understanding






