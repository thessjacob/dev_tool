#!/bin/bash

sed -i '/description = \"allow ssh into public subnet\"/r'<(cat role/dev_tool/files/nginx) terraform/security.tf