# Docker: where did the idea come from?

<p>
In 2016, microsoft decided to make an application to install and start linux on windows, working as a subsystem, called WSL (Windows Subsystem
for Linux). Docker can't be used on Linux in this subsystem because Windows can't process many Linux apps, and this issue made it impossible
to run Docker, so in 2019 Microsoft announced WSL 2, it was now possible to process the entire Linux kernel. Now we can use docker on linux from windows
11/10.
Docker is a platform made to convert applications into a container,

To work with docker, it is recommended to use WSL 2, as windows is so difficult to configure the whole environment to work.
Before we had docker, we already had other solutions, such as virtualization, and a widely used tool was Vagrant, from hashicorp, organizes
a snapshot of an operating system, we can configure the installed tools, databases, programming language,

Vagrant was not a problem for Linux, Windows or Mac == unified system

Heroku, from salesforce, appeared. It said that we could develop our apps in multiple languages ​​without having to worry about organizing our app environment:
I made a command on my machine, and that is enough to create an instance already made with all the settings and all the programming languages.
i do not need to configurate server, FORGET SERVER, i just need to worry about my developing, simplified
Finally, docker appeared. The ideas was about build our aplication based on containers
</p>

## What is containers? 

<p>
Containers are a form of virtualization, in operation system level, and allow to init multiply isolated system in a single real operational system.
Why did we say containers are a FORM of virtualization? because they don't work like 100% like a virtualization we know, the main diference is 
containers can share the same kernel from operational system: Linux has a much better modularized kernel, is possible to provisionate the system so
much simple, so, we can save resourcers.
</p>

## Virtual Machines x Containers
<p>
With a virtual machine, we can use a lot of resources and tools, in the same operational system, but, with containers, the idea is: each container 
do only one thing and assume only one responsability. In our example, I would have one container running mySQL, antoher running php to my application, 
another running myphpadmin, while in a virtual machine, all these needs would run on it.
</p>