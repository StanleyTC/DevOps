### Dockerfile Instructions definitions: 

* First Line: FROM node:14, here I'm telling to my image I'm creating I want the node 14 from the node image (from docker.hub)

* Second Line:WORKDIR /app-node, here, I am instructing that every instruction placed in the file will be saved inside the app-node directory of the container

* Third Line: COPY . ., here, in the first ".", I am informing that I want all the files present in this repository where this instruction file is saved, and I want them to be placed inside the container that will be generated (from the second ".")
Detail: if I hadn't created the WORKDIR /app-node line, the file wouldn't know where to save it with the second point because I didn't define it, so the command would have to be COPY . /app-node to work


* Fourth Line: RUN npm install , here, command to install all the node dependencies that I want to run in the container and I defined it on the first line (as I defined on the second line where it should be done, I won't need to put it here, otherwise I would have to enter RUN npm install app-node)

* Fifth Line: ENTRYPOINT npm start, start node



### At Terminal:
insert command 

```docker build -t <NAME>/app-node:1.0 .```

at our directory, so, he will do everything we want to create our image
