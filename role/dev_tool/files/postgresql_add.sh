#!/bin/bash

sed -i '/description = \"allow ssh into private subnet\"/r'<(cat role/dev_tool/files/postgresql) /home/jss/project/terraform/security.tf