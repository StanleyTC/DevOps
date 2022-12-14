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
????????
container:
  env:
    - name: "insert name here"
      value: "insert name here"
????????
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
We will now need a way to import the values ??????that are in the configmap file into the news pod container, which is our database in db-news; we will return it inside the db-noticias.yaml file and there we will put the env back, but instead of just putting the value of the environment variables, we will inform where it comes from, through the declarative variable "valueFrom:"
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


Portugu??s/BR
# Aplica????es
Nessa pasta, teremos alguns arquivos para uma aplica????o em especifico fazendo uso de servi??os SVC e pods com cubernetes (por favor, para entender melhor, visite as pastas dos tr??s servi??os SVCS que foram explicados anteriormente e a pasta de pods tamb??m).
Para a nossa aplica????o, iremos ent??o criar um pod que ter?? uma imagem com um portal de noticias (essa imagem foi deletada, mas voc?? pode usar outra imagem semelhante para esse teste), esse pode est?? no arquivo portal.yaml

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

basicamente geraremos um pod com o nome de portal, com um app em labels com o nome de portal tamb??m, que configuraremos no arquivo de servi??o para realizar a comunica????o entre o nosso pod e o nosso arquivo de servi??o.
### Ok, temos nosso pod com o portal de noticias, mas como vamos gerenciar o nosso portal de noticias para podemos acessar?
Iremos fazer uso do NodePort para esse pod, ent??o iremos criar o arquivo svc-portal.yaml para isso

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

repare que, em selector, colocamos app: portal, que ?? o mesmo app em labels do nosso pod, nos permitindo fazer essa comunica????o entre o servi??o e o pod.
em ports: port:80, temos que nosso servi??o vai funcionar na porta 80 dele, e em nodePort: 30000, ele vai mapear para a nossa porta 30000 para podemos acessar a aplica????o.
Agora temos uma aplica????o funcionando a partir de um servi??o se comunicando com um POD, que permite acesso do mundo externo (o servi??o NodePort ?? para isso) ao pod do nosso cluster.
O que queremos agora ?? um servi??o e um pod que ser??o respons??veis agora pelo sistema de noticias, onde faremos o cadastramento, e prover?? ao portal (que est?? no pod que j?? criamos) essas not??cias para que possam ser exibidas.
Para isso, teremos que criar outro pod, para o sistema, e outro NodePort, para gerenciar esse sistema. O pod que ser?? criado est?? em sistema.yaml

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
O arquivo do servi??o SVC de NodePort ?? o svc-sistema.yaml

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
Repare que, a porta de saida do nosso host est?? em 30001, isso porque o primeiro pod que criamos com o portal j?? estar?? usando a porta 30000
Pronto! ao darmos os comandos de kubectl apply para todos os pods e sistemas, j?? poderemos acessas nossa aplica????o no nosso navegador, indo direto pra tela de cadastro (que est?? no container de pod em sistema.yaml) gra??as ao NodePort, e que far?? a comunica????o com o portal (primeiro pod criado) para que as noticias sejam exibidas ap??s o cadastramento
Em seguida, temos que salvar as informa????es das noticias que ser??o exibidas em um banco de dados, se n??o nossa tela de exibi????o no navegador ficar?? ilegivel e mostrar?? informa????es at?? demais.

## Subindo o banco de dados
Ok, precisaremos criar um banco de dados, mas, por quest??es de seguran??a, evidentemente, ele n??o pode ser acessado pelo mundo externo ao cluster, portanto o servi??o SVC que gerenciar?? o pod com o banco de dados ser?? o ClusterIP, e ele ser?? conectado ao pod do banco de dados e ao pod do sistema de noticias, j?? que ser?? esse pod que se comunicar?? com o banco de dados; o arquivo que criaremos para o pod do banco de dados ser?? o db-noticias.yaml
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

Repare que a imagem do banco de dados nos informa que ?? um banco de dados relacional (eu tenho um reposit??rio sobre banco de dados, depois se te interessar, de uma olhada)

Em seguida, iremos configurar nosso pod de servi??o, sendo ele svc-db-noticias.yaml
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
ao acessarmos, teremos um erro (podemos ver isso com o comando kubectl get pods) no db-noticias, com o comando kubectl describe db-noticias, ele nos dar?? detalhes desse pod, e mostrar?? que o container do banco de dados est?? reiniciando o tempo todo, ent??o precisaremos mexer nas vari??veis de ambiente do mysql, temos que informar muitas coisas sobre esses banco de dados (Isso ?? algo que ser?? feito em outro t??pico!)

# Vari??veis de ambiente
iremos falar sobre vari??veis de ambientes. Alguns servi??os e imagens necessitam dessas vari??veis para poderem funcionar, e isso acontece com o nosso banco de dados, que n??o estava executando: faltou as vari??veis de ambiente.

### Como elas s??o definidas:
```
container:
  env:
    - name: "insert name here"
      value: "insert name here"
```
S??o definidas dentro do bloco de container.

No nosso caso, deveremos definir as vari??veis de ambiente MySQL_Password e MySQL_Database

o bloco completo ficar?? assim:
```
      env:
        - name: "MYSQL_ROOT_PASSWORD"
          value: "q1w2e3r4"
        - name: "MYSQL_DATABASE"
          value: "testing"
        - name: "MYSQL_PASSWORD"
          value: "q1w2e3r4"
```

quando dermos kubectl apply, teremos que informar as senhas, e agora poderemos mexer com o banco de dados, atrav??s do comando use testing (testing ?? o nome que eu dei para esse banco) e podemos ir dando comandos, j?? que ?? um banco MySQL. Agora teremos de configurar esse banco para que as informa????es de sistemas de noticias possam ficar salvas

Iremos extrair nossas informa????es de configura????o para fora do nosso arquivo de defini????o do banco de dados, atrav??s do ConfigMap.
O ConfigMap ?? um servi??o do kubernetes para guardar essas informa????es contidas em env. Para isso, iremos criar um arquivo chamado db-configmap.yaml e l?? faremos toda a configura????o. Removeremos esse env do db-noticias e colocaremos dentro do db-configmap.yaml

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
e depois podemos dar um kubectl apply para esse pod desse servi??o.

## Aplicando o ConfigMap ao projeto
Precisaremos agora de uma maneira de importar os valores que est??o no arquivo de configmap para o container do pod de noticias, que ?? o nosso banco de dados em db-noticias; retornaremos dentro do arquivo db-noticias.yaml e l?? colocaremos o env de volta, mas em vez de botarmos apenas o value das vari??veis de ambiente, n??s iremos informar de onde vem, atrav??s da vari??vel declarativa "valueFrom:"
Ficar?? assim
```
      env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom: 
            configMAPKEYREF:
              name: db-configmap
              key: MYSQL_ROOT_PASSWORD
```
Como queremos fazer declara????o de todas as vari??veis, podemos fazer uma declara????o mais simples, fazendo toda a configMap de uma vez (porque no bloco acima s?? temos uma vari??vel, mas a principio s??o 3, ter que fazer a estrutura acima deixa o c??digo desnecess??riamente grande), iremos ent??o usar envFrom:
```
      envFrom:
        - configMapRef:
            name: db-configmap
```
Agora s?? falta fazermos a refer??ncia ao banco, para isso, a imagem do banco de dados que estamos usando faz uso de um arquivo em php (contido na pr??pria imagem, mas como essa imagem n??o est?? mais disponivel, n??o ser?? possivel demonstrar). Nesse arquivo, teremos quatro vari??veis que precisaremos declarar:
* $host
* $usuario
* $senha
* $banco

Portanto precisaremos criar outro ConfigMap, mas dessa vez para o nosso sistema, e ser?? o arquivo sistema-configmap.yaml

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
E agora iremos importar para o arquivo de sistema.yaml seguindo o mesmo esquema de importa????o de envFrom:
```
      envFrom:
        - configMapRef:
            name: sistema-configmap
```

Agora sim nossa aplica????o funcionar??! agora iremos querer que o portal que conseguimos acessar no navegador se comunique com o sistema para fazer a exibi????o da noticia. Para isso, ser?? feito via vari??vel de ambiente. entrando de modo interativo na imagem do portal, l?? tamb??m ter?? um arquivo pedindo uma vari??vel, que ser?? de IP. Teremos ent??o que criar o portal-configmap.yaml

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
dando um apply em tudo, agora sim nossa aplica????o funcionar?? sem problemas!