#!/bin/bash

sed -i '/description = \"allow ssh into private subnet\"/r'<(cat role/dev_tool/files/mysql) terraform/security.tf