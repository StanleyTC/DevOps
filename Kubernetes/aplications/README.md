English/USA
# Applications
In this folder, we will have some files for a specific application making use of SVC services and pods with cubernetes (please, to understand better, visit the folders of the three SVCS services that were explained earlier and the pods folder as well).
For our application, we will then create a pod that will have an image with a news portal (this image has been deleted, but you can use another similar image for this test), this can be in the portal.yaml file

## portal.yaml
```
apiVersion: v1
kind: Pod
metadata:
  name: portal
  labels:
    app: portal
spec:
  containers:
    - name: portal
      image: deletedimage/portal-noticias:1
      ports:
        - containerPort: 80
```

basically we will generate a pod with the name of portal, with an app in labels with the name of portal as well, which we will configure in the service file to carry out the communication between our pod and our service file.
### Ok, we have our pod with the news portal, but how are we going to manage our news portal so we can access it?
We will make use of NodePort for this pod, so we will create the svc-portal.yaml file for that

## svc-portal.yaml
```
spiVersion: v1
kind: Service
metadata:
  name: svc-portal
spec:
  type: NodePort
  ports:
    - port: 80
      nodePort: 30000
  selector:
    app: portal
```

notice that, in selector, we put app: portal, which is the same app in labels of our pod, allowing us to make this communication between the service and the pod.
in ports: port:80, we have that our service will work on its port 80, and in nodePort: 30000, it will map to our port 30000 so we can access the application.
Now we have an application running from a service communicating with a POD, which allows access from the outside world (the NodePort service is for that) to the pod of our cluster.
What we want now is a service and a pod that will now be responsible for the news system, where we will register, and will provide the portal (which is in the pod that we have already created) with these news so that they can be displayed.
For this, we will have to create another pod, for the system, and another NodePort, to manage this system. The pod that will be created is in sistema.yaml

## sistema.yaml
```
apiVersion: v1
kind: Pod
metadata:
  name: portal
  labels:
    app: portal
spec:
  containers:
    - name: portal
      image: deletedimage/portal-noticias:1
      ports:
        - containerPort: 80
```
The NodePort SVC service file is svc-sistema.yaml

## svc-sistema.yaml
```
apiVersion: v1
kind: Service
metadata:
  name: svc-sistema
spec:
  type: NodePort
  ports:
    - port: 80
      nodePort: 30001
  selector:
    app: sistema
```

Notice that our host's output port is set to 30001, because the first pod we created with the portal will already be using port 30000
Ready! when we give the kubectl apply commands to all pods and systems, we will be able to access our application in our browser, going straight to the registration screen (which is in the pod container in sistema.yaml) thanks to NodePort, which will communicate with the portal (first pod created) so that the news is displayed after registration
Next, we have to save the information of the news that will be displayed in a database, otherwise our display screen in the browser will be unreadable and will show too much information.

## Uploading the database
Okay, we will need to create a database, but for security reasons, of course, it cannot be accessed by the world outside the cluster, so the SVC service that will manage the pod with the database will be ClusterIP, and it will be connected to the database pod and the news system pod, as it will be this pod that will communicate with the database; the file we will create for the database pod will be db-noticias.yaml

## db-noticias.yaml
```
apiVersion: v1
kind: Pod
metadata:
  name: db-noticias
  labels:
    app: db-noticias
spec:
  containers:
    - name: db-noticias-container
      image: deletedimage/mysql-db:1
      ports:
        - containerPort: 3306
```
Notice that the image of the database tells us that it is a relational database (I have a repository about database, then if you are interested, take a look)

Next, we will configure our service pod, which is svc-db-noticias.yaml

## svc-db-noticias.yaml
```
apiVersion: v1
kind: Service
metadata:
  name: svc-db-news
spec:
  type: ClusterIP
  ports:
    - port: 3306
  selector:
    app: db-noticias
```

Now we will run the kubectl apply commands on these containers and that's it!
when we access, we will have an error (we can see this with the kubectl get pods command) in db-news, with the kubectl describe db-news command, it will give us details of that pod, and it will show that the database container is restarting the all the time, so we will need to fiddle with mysql environment variables, we have to inform many things about these databases (This is something that will be done in another topic!)

# Environment variables
Let's talk about environment variables. Some services and images need these variables to be able to work, and this happens with our database, which was not running: the environment variables were missing.

### How they are defined:
🇧🇷
container:
  env:
    - name: "insert name here"
      value: "insert name here"
🇧🇷
They are defined inside the container block.

In our case, we must set the MySQL_Password and MySQL_Database environment variables

the complete block will look like this:
```
      env:
        - name: "MYSQL_ROOT_PASSWORD"
          value: "q1w2e3r4"
        - name: "MYSQL_DATABASE"
          value: "testing"
        - name: "MYSQL_PASSWORD"
          value: "q1w2e3r4"
```

when we give kubectl apply, we will have to inform the passwords, and now we will be able to mess with the database, through the use testing command (testing is the name I gave to this database) and we can go giving commands, since it is a MySQL database . Now we will have to configure this database so that information from news systems can be saved

We will extract our configuration information out of our database definition file, through ConfigMap.
ConfigMap is a Kubernetes service to store this information contained in env. For this, we will create a file called db-configmap.yaml and there we will do all the configuration. We will remove this env from db-noticias and put it inside db-configmap.yaml

## db-configmap.yaml
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: db-configmap
data:
  MYSQL_ROOT_PASSWORD: "q1w2e3r4"
  MYSQL_DATABASE: "testing"
  MYSQL_PASSWORD: "q1w2e3r4"
```
and then we can give a kubectl apply to that pod of that service.

## Applying the ConfigMap to the project
We will now need a way to import the values ​​that are in the configmap file into the news pod container, which is our database in db-news; we will return it inside the db-noticias.yaml file and there we will put the env back, but instead of just putting the value of the environment variables, we will inform where it comes from, through the declarative variable "valueFrom:"
it will be like this:
```
      env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom: 
            configMAPKEYREF:
              name: db-configmap
              key: MYSQL_ROOT_PASSWORD
```
As we want to declare all the variables, we can make a simpler declaration, making the entire configMap at once (because in the above block we only have one variable, but in principle there are 3, having to make the structure above makes the code unnecessarily large ), we will then use envFrom:

```
      envFrom:
        - configMapRef:
            name: db-configmap
```

Now we just need to make a reference to the database, for that, the database image we are using makes use of a php file (contained in the image itself, but as this image is no longer available, it will not be possible to demonstrate). In this file, we will have four variables that we will need to declare:
* $host
* $user
* $password
* $bank

So we will need to create another ConfigMap, but this time for our system, and it will be the file sistema-configmap.yaml
## sistema-configmap.yaml
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: sistema-configmap
data:
  HOST_DB: svc-db-noticias:3306
  USER_DB: root
  PASS_DB: q1w2e3r4
  DATABASE_DB: testing
```
And now we will import to the system.yaml file following the same envFrom import we were using:
```
      envFrom:
        - configMapRef:
            name: sistema-configmap
```
Now our application will work! now we will want the portal that we can access in the browser to communicate with the system to display the news. For this, it will be done via environment variable. interactively entering the portal image, there will also be a file asking for a variable, which will be IP. We will then have to create the portal-configmap.yaml
## portal-configmap.yaml
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal-configmap
data:
  IP_SISTEMA: http://localhost:30001
```
At portal.yaml, we will insert envFrom:
```
      envFrom:
        - configMapRef:
            name: portal-configmap
```
using apply command at terminal, our application can work withou problems!
<p>.</p>
<p>.</p>
<p>.</p>
<p>.</p>
<p>.</p>


Português/BR
# Aplicações
Nessa pasta, teremos alguns arquivos para uma aplicação em especifico fazendo uso de serviços SVC e pods com cubernetes (por favor, para entender melhor, visite as pastas dos três serviços SVCS que foram explicados anteriormente e a pasta de pods também).
Para a nossa aplicação, iremos então criar um pod que terá uma imagem com um portal de noticias (essa imagem foi deletada, mas você pode usar outra imagem semelhante para esse teste), esse pode está no arquivo portal.yaml

## portal.yaml
```
apiVersion: v1
kind: Pod
metadata:
  name: portal
  labels:
    app: portal
spec:
  containers:
    - name: portal
      image: deletedimage/portal-noticias:1
      ports:
        - containerPort: 80
```

basicamente geraremos um pod com o nome de portal, com um app em labels com o nome de portal também, que configuraremos no arquivo de serviço para realizar a comunicação entre o nosso pod e o nosso arquivo de serviço.
### Ok, temos nosso pod com o portal de noticias, mas como vamos gerenciar o nosso portal de noticias para podemos acessar?
Iremos fazer uso do NodePort para esse pod, então iremos criar o arquivo svc-portal.yaml para isso

## svc-portal.yaml
```
spiVersion: v1
kind: Service
metadata:
  name: svc-portal
spec:
  type: NodePort
  ports:
    - port: 80
      nodePort: 30000
  selector:
    app: portal
```

repare que, em selector, colocamos app: portal, que é o mesmo app em labels do nosso pod, nos permitindo fazer essa comunicação entre o serviço e o pod.
em ports: port:80, temos que nosso serviço vai funcionar na porta 80 dele, e em nodePort: 30000, ele vai mapear para a nossa porta 30000 para podemos acessar a aplicação.
Agora temos uma aplicação funcionando a partir de um serviço se comunicando com um POD, que permite acesso do mundo externo (o serviço NodePort é para isso) ao pod do nosso cluster.
O que queremos agora é um serviço e um pod que serão responsáveis agora pelo sistema de noticias, onde faremos o cadastramento, e proverá ao portal (que está no pod que já criamos) essas notícias para que possam ser exibidas.
Para isso, teremos que criar outro pod, para o sistema, e outro NodePort, para gerenciar esse sistema. O pod que será criado está em sistema.yaml

## sistema.yaml
```
apiVersion: v1
kind: Pod
metadata:
  name: portal
  labels:
    app: portal
spec:
  containers:
    - name: portal
      image: deletedimage/portal-noticias:1
      ports:
        - containerPort: 80
```
O arquivo do serviço SVC de NodePort é o svc-sistema.yaml

## svc-sistema.yaml
```
apiVersion: v1
kind: Service
metadata:
  name: svc-sistema
spec:
  type: NodePort
  ports:
    - port: 80
      nodePort: 30001
  selector:
    app: sistema
```
Repare que, a porta de saida do nosso host está em 30001, isso porque o primeiro pod que criamos com o portal já estará usando a porta 30000
Pronto! ao darmos os comandos de kubectl apply para todos os pods e sistemas, já poderemos acessas nossa aplicação no nosso navegador, indo direto pra tela de cadastro (que está no container de pod em sistema.yaml) graças ao NodePort, e que fará a comunicação com o portal (primeiro pod criado) para que as noticias sejam exibidas após o cadastramento
Em seguida, temos que salvar as informações das noticias que serão exibidas em um banco de dados, se não nossa tela de exibição no navegador ficará ilegivel e mostrará informações até demais.

## Subindo o banco de dados
Ok, precisaremos criar um banco de dados, mas, por questões de segurança, evidentemente, ele não pode ser acessado pelo mundo externo ao cluster, portanto o serviço SVC que gerenciará o pod com o banco de dados será o ClusterIP, e ele será conectado ao pod do banco de dados e ao pod do sistema de noticias, já que será esse pod que se comunicará com o banco de dados; o arquivo que criaremos para o pod do banco de dados será o db-noticias.yaml
## db-noticias.yaml
```
apiVersion: v1
kind: Pod
metadata:
  name: db-noticias
  labels:
    app: db-noticias
spec:
  containers:
    - name: db-noticias-container
      image: deletedimage/mysql-db:1
      ports:
        - containerPort: 3306
```

Repare que a imagem do banco de dados nos informa que é um banco de dados relacional (eu tenho um repositório sobre banco de dados, depois se te interessar, de uma olhada)

Em seguida, iremos configurar nosso pod de serviço, sendo ele svc-db-noticias.yaml
## svc-db-noticias.yaml
```
apiVersion: v1
kind: Service
metadata:
  name: svc-db-noticias
spec:
  type: ClusterIP
  ports:
    - port: 3306
  selector:
    app: db-noticias
```
Agora iremos rodar os comandos de kubectl apply nesses containers e pronto!
ao acessarmos, teremos um erro (podemos ver isso com o comando kubectl get pods) no db-noticias, com o comando kubectl describe db-noticias, ele nos dará detalhes desse pod, e mostrará que o container do banco de dados está reiniciando o tempo todo, então precisaremos mexer nas variáveis de ambiente do mysql, temos que informar muitas coisas sobre esses banco de dados (Isso é algo que será feito em outro tópico!)

# Variáveis de ambiente
iremos falar sobre variáveis de ambientes. Alguns serviços e imagens necessitam dessas variáveis para poderem funcionar, e isso acontece com o nosso banco de dados, que não estava executando: faltou as variáveis de ambiente.

### Como elas são definidas:
```
container:
  env:
    - name: "insert name here"
      value: "insert name here"
```
São definidas dentro do bloco de container.

No nosso caso, deveremos definir as variáveis de ambiente MySQL_Password e MySQL_Database

o bloco completo ficará assim:
```
      env:
        - name: "MYSQL_ROOT_PASSWORD"
          value: "q1w2e3r4"
        - name: "MYSQL_DATABASE"
          value: "testing"
        - name: "MYSQL_PASSWORD"
          value: "q1w2e3r4"
```

quando dermos kubectl apply, teremos que informar as senhas, e agora poderemos mexer com o banco de dados, através do comando use testing (testing é o nome que eu dei para esse banco) e podemos ir dando comandos, já que é um banco MySQL. Agora teremos de configurar esse banco para que as informações de sistemas de noticias possam ficar salvas

Iremos extrair nossas informações de configuração para fora do nosso arquivo de definição do banco de dados, através do ConfigMap.
O ConfigMap é um serviço do kubernetes para guardar essas informações contidas em env. Para isso, iremos criar um arquivo chamado db-configmap.yaml e lá faremos toda a configuração. Removeremos esse env do db-noticias e colocaremos dentro do db-configmap.yaml

## db-configmap.yaml
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: db-configmap
data:
  MYSQL_ROOT_PASSWORD: "q1w2e3r4"
  MYSQL_DATABASE: "testing"
  MYSQL_PASSWORD: "q1w2e3r4"
```
e depois podemos dar um kubectl apply para esse pod desse serviço.

## Aplicando o ConfigMap ao projeto
Precisaremos agora de uma maneira de importar os valores que estão no arquivo de configmap para o container do pod de noticias, que é o nosso banco de dados em db-noticias; retornaremos dentro do arquivo db-noticias.yaml e lá colocaremos o env de volta, mas em vez de botarmos apenas o value das variáveis de ambiente, nós iremos informar de onde vem, através da variável declarativa "valueFrom:"
Ficará assim
```
      env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom: 
            configMAPKEYREF:
              name: db-configmap
              key: MYSQL_ROOT_PASSWORD
```
Como queremos fazer declaração de todas as variáveis, podemos fazer uma declaração mais simples, fazendo toda a configMap de uma vez (porque no bloco acima só temos uma variável, mas a principio são 3, ter que fazer a estrutura acima deixa o código desnecessáriamente grande), iremos então usar envFrom:
```
      envFrom:
        - configMapRef:
            name: db-configmap
```
Agora só falta fazermos a referência ao banco, para isso, a imagem do banco de dados que estamos usando faz uso de um arquivo em php (contido na própria imagem, mas como essa imagem não está mais disponivel, não será possivel demonstrar). Nesse arquivo, teremos quatro variáveis que precisaremos declarar:
* $host
* $usuario
* $senha
* $banco

Portanto precisaremos criar outro ConfigMap, mas dessa vez para o nosso sistema, e será o arquivo sistema-configmap.yaml

## sistema-configmap.yaml
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: sistema-configmap
data:
  HOST_DB: svc-db-noticias:3306
  USER_DB: root
  PASS_DB: q1w2e3r4
  DATABASE_DB: testing
```
E agora iremos importar para o arquivo de sistema.yaml seguindo o mesmo esquema de importação de envFrom:
```
      envFrom:
        - configMapRef:
            name: sistema-configmap
```

Agora sim nossa aplicação funcionará! agora iremos querer que o portal que conseguimos acessar no navegador se comunique com o sistema para fazer a exibição da noticia. Para isso, será feito via variável de ambiente. entrando de modo interativo na imagem do portal, lá também terá um arquivo pedindo uma variável, que será de IP. Teremos então que criar o portal-configmap.yaml

## portal-configmap.yaml
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal-configmap
data:
  IP_SISTEMA: http://localhost:30001
```
No portal.yaml, colocaremos envFrom:
```
      envFrom:
        - configMapRef:
            name: portal-configmap
```
dando um apply em tudo, agora sim nossa aplicação funcionará sem problemas!