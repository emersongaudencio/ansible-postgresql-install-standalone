# Ansible PostgreSQL install standalone
### Ansible routines to deploy Standalone PostgreSQL installation on CentOS / Red Hat Linux distros.

# Translation in English en-us

 In this file, I will present and demonstrate how to install PostgreSQL in an automated and easy way.

 For this, I will be using the scenario described down below:
 ```
 1 Linux server for ansible
 1 Linux server for PostgreSQL (the one that we will install PostgreSQL using Ansible)
 ```

 First of all, we have to prepare our Linux environment to use Ansible

 Please have a look below how to install Ansible on CentOS/Red Hat:
 ```
 yum install ansible -y
 ```
 Well now that we have Ansible installed already, we need to install git to clone our git repository on the Linux server, see below how to install it on CentOS/Red Hat:
 ```
 yum install git -y
 ```

 Copying the script packages using git:
 ```
 cd /root
 git clone https://github.com/emersongaudencio/ansible-postgresql-install-standalone.git
 ```
 Alright then after we have installed Ansible and git and clone the git repository. We have to generate ssh heys to share between the Ansible control machine and the database machines. Let see how to do that down below.

 To generate the keys, keep in mind that is mandatory to generate the keys inside of the directory who was copied from the git repository, see instructions below:
 ```
 cd /root/ansible-postgresql-install-standalone/ansible
 ssh-keygen -f ansible
 ```
 After that you have had generated the keys to copy the keys to the database machines, see instructions below:
 ```
 ssh-copy-id -i ansible.pub 172.16.122.142
 ```

 Please edit the file called hosts inside of the ansible git directory :
 ```
 vi hosts
 ```
 Please add the hosts that you want to install your database and save the hosts file, see an example below:

 ```
 # This is the default ansible 'hosts' file.
 #

 ## [dbservers]
 ##
 ## db01.intranet.mydomain.net
 ## db02.intranet.mydomain.net
 ## 10.25.1.56
 ## 10.25.1.57

 [dbservers]
 dblocalhost ansible_connection=local
 dbpg94 ansible_ssh_host=172.16.122.134
 dbpg95 ansible_ssh_host=172.16.122.135
 dbpg96 ansible_ssh_host=172.16.122.136
 dbpg10 ansible_ssh_host=172.16.122.141
 dbpg11 ansible_ssh_host=172.16.122.142
 dbpg12 ansible_ssh_host=172.16.122.143
 ```

 For testing if it is all working properly, run the command below :
 ```
 ansible -m ping dbpg11 -v
 ```

 Alright finally we can install our PostgreSQL 11.0 using Ansible as we planned to, run the command below:
 ```
 sh run_postgresql_install.sh dbpg11 11
 ```

 PS: Just remember that you can do a single installation at the time or a group installation you inform the name of the group in the hosts' files instead of the host itself.

 The versions supported for this script are these between the round brackets (94,95,96,10,11,12).

# Translation in Portuguese pt-br

Neste arquivo, venho apresentar e demonstrar como fazer a instalacao do PostgreSQL de forma automatizada e simples.

Para este post estarei utilizando o seguinte cenario:
```
1 servidor para o ansible
1 servidor que sera o nosso banco de dados PostgreSQL
```

Primeiramente temos que preparar nosso ambiente para utilizar o Ansible.

Veja abaixo com fazer a instalacao do Ansible no CentOS/Red Hat ou derivados:
```
yum install ansible -y
```

Bom agora que ja temos o Ansible instalado, vamos fazer o download do pacote de scripts no GitHub abaixo:
```
yum install git -y
```

Copiando o pacote de scripts com git:
```
cd /root
git clone https://github.com/emersongaudencio/ansible-postgresql-install-standalone.git
```

Bom depois de instalar o ansible, git e clonar o repositorio no servidor do ansible, vamos precisar gerar chaves ssh e compartilhar entre o servidor do ansible e o servidor de banco de dados para que possamos executar os scripts do pacote do ansible.

Para gerar as chaves dentro do diretorio que copiou o repositorio de scripts do git:
```
cd /root/ansible-postgresql-install-standalone/ansible
ssh-keygen -f ansible
```
Depois copie a
```
ssh-copy-id -i ansible.pub 172.16.122.142
```

Edite o arquivo hosts do pacote de diretorio do ansible:
```
vi hosts
```
Adicione os hosts que vai fazer a instalacao e salve o arquivo, veja o exemplo abaixo:

```
# This is the default ansible 'hosts' file.
#

## [dbservers]
##
## db01.intranet.mydomain.net
## db02.intranet.mydomain.net
## 10.25.1.56
## 10.25.1.57

[dbservers]
dblocalhost ansible_connection=local
dbpg94 ansible_ssh_host=172.16.122.134
dbpg95 ansible_ssh_host=172.16.122.135
dbpg96 ansible_ssh_host=172.16.122.136
dbpg10 ansible_ssh_host=172.16.122.141
dbpg11 ansible_ssh_host=172.16.122.142
dbpg12 ansible_ssh_host=172.16.122.143
```

Depois disso faca um teste para verificar se o ansible esta realmente conectando e funcionando corretamente com o script abaixo:
```
ansible -m ping dbpg11 -v
```

Agora finalmente execute o script para fazer a instalacao remota do PostgreSQL 11.0 no seu servidor de banco de dados:
```
sh run_postgresql_install.sh dbpg11 11
```

Obs: Lembrando que tambem eh possivel fazer a instalacao para todo um grupo de servidor de uma soh vez, substituindo o nome do servidor pelo nome do grupo, que no nosso exemplo eh dbservers.

Outra observacao sobre o script eh que as versoes que voce pode instalar sao essas aqui (94,95,96,10,11,12).
