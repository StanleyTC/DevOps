# API gateway using a lambda function to access a database (dynamoDB)
## Introduction
the objective is to create an API gateway within the AWS project, which will communicate with a lambda function, and which, in turn, will communicate with a database, using DynamoDB, which is a database service of AWS data. The lambdas that will be created within this repository will be in JavaScript, and the terraform codes, of course, will be in HCL, since that is the language used for this.
## Diagram
below, we have an image of the diagram that was imagined at first, in which we can see all services communicating in the way we want. The diagram was made in .drawio, an extension to draw this diagram model, the model codes are in the gateway api file, lambda, dynamodb terraform.drawio to be opened by anyone who wants to
### Necessary services
* API gateway
* Lambda
* DynamoDB
* CloudWatch

![apiterraform](https://user-images.githubusercontent.com/95464654/194354186-df07ca53-c8b0-4dfc-b227-6571aa097575.png)

## First steps
Initially we must create the files of our lambdas. For this, the codes_lambdas folder was created, inside this folder, we have a folder for the layers of the lambdas, which we will call utils, and inside utils, we will create a folder called nodejs, and there we will have the normalizer.js and response.js files
For our lambdas, we will create the functions folder, where we will have all the files of our lambdas, made in JavaScript

(The explanation of these files will be in comments inside the codes, here in the README there is only the contextualization of what each file is)