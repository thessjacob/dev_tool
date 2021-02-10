# Dev_Tool -- thessjacob

This repo generates a small AWS environment to test and configure containers in a cloud environment. It is designed to make creating a testing ground consistent but also highly configurable.

### Prerequisites
To get started, you will need to make sure that Ansible 2.10 or later is installed and that you have the aws-cli configured in your environment. You will need to have IAM permissions that allow you to create, modify, and destroy VPC and EC2 resources.

You will also need Terraform, however the script can install terraform for you.

This has currently been tested for RHEL/CentOS.

### Getting Started

- grab the repo using:
```
git clone git@github.com:thessjacob/dev_tool.git
```

Once it's downloaded, you'll need to make changes to one specific variable.

- first, add your external ip to terraform/terraform.tfvars
```
vim terraform/terraform.tfvars

    my_ip = "<your_ip>/32"
```
- you should also add it to rollback/terraform.tfvars so that you don't have to readd it if you reset your environment.

### Using the script

Once you have added your ip address to the appropriate file, you can run the script using:

```
./my_terraform.sh
```

If aws-cli and ansible are configured correctly, this script should do the following:
- init the terraform directory
- apply the default configuation, which creates a VPC with one private subnet and one public subnet that are only accessible to each other and to your external ip, in which there will be 1 ec2 instance of default size t2.mico and distro RHEL
- generate an ssh key to be used only for accessing those two instances
- run an ansible playbook that will install container tools (buildah, skopeo, podman)
- if used with appropriate tags, the playbook will also create a volume and rootless container matching the tag, as well as open necessary ports in the VPC security groups

## Options

Currently there are six containers to choose from. Note that creating two containers that use the same default port (such as httpd and nginx both) will not work.

# "Front-end"
- httpd
- nginx
- jenkins

# "DB"
- mariadb
- mysql
- postgresql

You can have the script create them as follows:
```
./my_terraform.sh httpd mysql postgresql
```

If you'd prefer not to use the script and wish to use the ansible role manually, you can do so using:
```
ansible-playbook playbook.yml -i inventory --tags "<tag1>,<tag2>,<tag3>"
```
Remember though: if you make changes by running an ansible-playbook manually, you will need to terraform apply to ensure that the correct security group changes are made.

### Accessing your instances
Use the ips that terraform outputs to ssh to your instances
```
ssh -i .ssh/id_rsa_dev_tool.pub ec2-user@<ip-1>
ssh -i .ssh/id_rsa_dev_tool.pub ec2-user@<ip-2>
```
By default, ip-1 will be the public instance and have a private ip of 10.0.0.4.
By default, ip-2 will be the private instance and have a private ip of 10.0.1.4.

### Customizing your environment

The first way to easily customize your environment is to use the terraform.tfvars file to change what is created in aws. These values all have default values but can be easily changed to suit your needs.

You can also edit ansible variables by editing the role vars file: role/dev_tool/vars/main.yml

Everything is made to be as modular as possible, so it should be relatively easy to add tasks to the ansible role to create new containers, or to edit the terraform config to change the number of instances or the networking setup.

I recommend looking specifically at the role/dev_tool/files/ directory to see how a short sed script can be used to automate the opening of ports in the VPC security group.

### Undoing your changes

The rollback/ directory should not be changed other than to add your external ip. The files can be copied to terraform/ to overwrite any changes you've made, or you can use
```
./rollback.sh
```
to completely destroy and reset your terraform environment.
