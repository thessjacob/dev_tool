# Dev_Tool -- Easy Cloud Container Environment

This tool provisions a small group of AWS resources to test and configure containers in a native cloud environment. It is designed to make creating and testing consistent but also highly configurable. Provisioned instances come with skopeo, buildah, and podman installed for manipulating oci compatible containers.


## Prerequisites
To get started, you will need to make sure that Ansible 2.10 or later is installed and that you have the aws-cli configured in your terminal environment. You will need to have IAM permissions that allow you to create, modify, and destroy VPC and EC2 resources.

You will also need Terraform, however the script can install Terraform for you.

This script was tested on RHEL/CentOS, but should theoretically work from any bash shell.


## Getting Started

Grab the repo using:
```
git clone git@github.com:thessjacob/dev_tool.git
```

Once it's downloaded, you'll need to make changes to one specific variable, which can be found in terraform/terraform.tfvars. The ip address you add should be your external address, as that is what will need to be accepted by the AWS security groups.
```
vim terraform/terraform.tfvars

my_ip = "<your_ip>/32"
```
You should also add the ip to rollback/terraform.tfvars so that you don't have to readd it later if you rollback your environment.


### Using the script

Once you have added your ip address to the appropriate files, you can then run the script using:

```
./my_terraform.sh
```

If aws-cli and ansible are configured correctly, the script should do the following:
- init the terraform directory
- apply the default configuation, which creates a VPC with one private subnet and one public subnet that are only accessible to each other and to your external ip.
- create two AWS instances (one in each subnet) that will, by default, be of size t2.mico and distro RHEL
- generate an ssh key to be used only for accessing those two instances. It will live in a .ssh directory in the root directory of the repo
- run an ansible playbook that will install container tools (buildah, skopeo, podman)
- if used with appropriate tags, the script will run a playbook that will create a volume and rootless container matching any specified tag, as well as tell Terraform to open necessary ports in the VPC security groups


### Options

Currently there are six containers to choose from. Note that creating two containers that use the same default port (such as httpd and nginx both) will not work. However, if you wish to deploy two containers that use the same default ports, you can change the port mapping by editing the role/dev_tool/vars/main.yml file.

The current container tags and their default host ports are shown below:

#### "Front-end"
- httpd     (80)
- nginx     (80)
- jenkins   (8080)

#### "DB"
- mariadb    (3306)
- mysql      (3306)
- postgresql (5432)

You can easily have the script create as many of the containers as you would like as follows:
```
./my_terraform.sh httpd mysql postgresql
```

If you'd prefer not to use the script and wish to run the ansible role manually, you can do so using:
```
ansible-playbook playbook.yml -i inventory --tags "<tag1>,<tag2>,<tag3>"
```
Remember though: if you make changes by running an ansible-playbook manually, you will need to run terraform apply to ensure that the correct security group changes are made.


## Accessing your instances
Use the ips that terraform outputs to ssh to your instances
```
ssh -i .ssh/id_rsa_dev_tool.pub ec2-user@<ip-1>
ssh -i .ssh/id_rsa_dev_tool.pub ec2-user@<ip-2>
```
If you need to find these two ips, use the following method:
```
cd terraform
terraform output
```

By default, ip-1 will be the public instance and have a private ip of 10.0.0.4.
By default, ip-2 will be the private instance and have a private ip of 10.0.1.4.


## Customizing your environment

The first way to easily customize your environment is to use the terraform/terraform.tfvars file to change what is created in aws. These values all have default values but can be easily changed to suit your needs.

You can also edit ansible variables by editing the role vars file at role/dev_tool/vars/main.yml

Everything is made to be as modular as possible, so it should be relatively easy to add tasks to the ansible role to create new containers not currently configured or to edit the terraform config to alter what's provisioned in AWS

I recommend looking specifically at the role/dev_tool/files/ directory to see how a short sed script can be used to automatically edit the terraform resource files to open new ports in the VPC security groups.


## Undoing your changes

The files in the rollback/ directory should not be changed other than to add your external ip to rollback/terraform.tfvars. The files can be copied to terraform/ to overwrite any changes you've made, or you can use
```
./rollback.sh
```
to completely destroy and reset your terraform environment found in terraform/.
