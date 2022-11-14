# API gateway using a lambda function to access a database (dynamoDB)
## English USA
## Introduction
the objective is to create an API gateway within the AWS project, which will communicate with a lambda function, and which, in turn, will communicate with a database, using DynamoDB, which is a database service of AWS data. The lambdas that will be created within this repository will be in JavaScript, and the terraform codes, of course, will be in HCL, since that is the language used for this.
## Diagram
below, we have an image of the diagram that was imagined at first, in which we can see all services communicating in the way we want. The diagram was made in .drawio, an extension to draw this diagram model, the model codes are in the gateway api file, lambda, dynamodb terraform.drawio to be opened by anyone who wants to
### Necessary services
* API gateway
* Lambda
* DynamoDB
* CloudWatch

![final](https://user-images.githubusercontent.com/95464654/194374108-92a756bf-d3fe-4b0a-80ac-a97fe8028025.png)

## First steps
Initially we must create the files of our lambdas. For this, the codes_lambdas folder was created, inside this folder, we have a folder for the layers of the lambdas, which we will call utils, and inside utils, we will create a folder called nodejs, and there we will have the normalizer.js and response.js files
For our lambdas, we will create the functions folder, where we will have all the files of our lambdas, made in JavaScript

(The explanation of these files will be in comments inside the codes, here in the README there is only the contextualization of what each file is)

## terraform files

We must create a folder destined only for terraform files, for organization purposes, for that we will create the codes_terraform folder, there we will create a total of 9 files. The first will be main.tf, where we will be informing which provider we will use, and in this case it will be AWS; we will have variables.tf, where we will declare the variables that will be called in all other files; in the lambda.tf file, we will have all the lambda settings and the resource to create the layer; in the iam.tf file we will have the necessary permissions; in the locals.tf file, we will have a place to differentiate where a deploy will be happening, we will have the path of the lambdas and the layers, and we will also have the lambdas and paths methods; our outputs.tf file will have the output in the terminal, which will be our api link; we will have the dynamodb.tf file, which will have the configurations of our database; we will have the api.tf file that will be the file with all the api settings, and finally we will have a file called ssm.tf, which will be a resource for the AWS parameter store, which we will need to use to configure our lambda to access DynamoDB, therefore the diagram drawing will also be updated, looking like the model below (also available at api gateway, lambda, dynamodb, parameter store terraform.drawio):

![final model](https://user-images.githubusercontent.com/95464654/194373423-f067d778-4d30-479c-afff-4840b40366bf.png)

## Português BR
## Introdução
o objetivo é criar um gateway de API dentro do projeto da AWS, que se comunicará com uma função lambda, e que, por sua vez, se comunicará com um banco de dados, usando o DynamoDB, que é um serviço de banco de dados de dados da AWS. Os lambdas que serão criados dentro deste repositório estarão em JavaScript, e os códigos terraform, claro, estarão em HCL, já que essa é a linguagem utilizada para isso.
## Diagrama
abaixo, temos uma imagem do diagrama que foi imaginado a princípio, no qual podemos ver todos os serviços se comunicando da forma que desejamos. O diagrama foi feito em .drawio, uma extensão para desenhar este modelo de diagrama, os códigos do modelo estão no arquivo api do gateway, lambda, dynamodb terraform.drawio para ser aberto por quem quiser
### Serviços necessários
* API GATEWAY
* Lambda
* DynamoDB
* CloudWatch

![final](https://user-images.githubusercontent.com/95464654/194374108-92a756bf-d3fe-4b0a-80ac-a97fe8028025.png)

## Primeiros passos
Inicialmente devemos criar os arquivos dos nossos lambdas. Para isso foi criada a pasta codes_lambdas, dentro dessa pasta temos uma pasta para as camadas dos lambdas, que chamaremos de utils, e dentro de utils criaremos uma pasta chamada nodejs, e lá teremos o normalizador. js e arquivos response.js
Para nossos lambdas, criaremos a pasta de funções, onde teremos todos os arquivos de nossos lambdas, feitos em JavaScript

(A explicação desses arquivos estará nos comentários dentro dos códigos, aqui no README há apenas a contextualização do que é cada arquivo)

## arquivos terraform

Devemos criar uma pasta destinada apenas aos arquivos terraform, para fins de organização, para isso criaremos a pasta codes_terraform, lá criaremos um total de 9 arquivos. O primeiro será o main.tf, onde estaremos informando qual provedor iremos utilizar, e neste caso será AWS; teremos variables.tf, onde declararemos as variáveis ​​que serão chamadas em todos os outros arquivos; no arquivo lambda.tf, teremos todas as configurações do lambda e o recurso para criar a camada; no arquivo iam.tf teremos as permissões necessárias; no arquivo locals.tf, teremos um local para diferenciar onde vai acontecer um deploy, teremos o caminho dos lambdas e das camadas, e também teremos os métodos lambdas e caminhos; nosso arquivo outputs.tf terá a saída no terminal, que será nosso link api; teremos o arquivo dynamodb.tf, que terá as configurações do nosso banco de dados; teremos o arquivo api.tf que será o arquivo com todas as configurações da api, e por fim teremos um arquivo chamado ssm.tf, que será um recurso para o armazenamento de parâmetros da AWS, que precisaremos usar para configurar nosso lambda para acessar o DynamoDB, portanto o desenho do diagrama também será atualizado, ficando parecido com o modelo abaixo (também disponível em api gateway, lambda, dynamodb, parameter store terraform.drawio):

![modelo final](https://user-images.githubusercontent.com/95464654/194373423-f067d778-4d30-479c-afff-4840b40366bf.png)