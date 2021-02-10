#!/bin/bash

sed -i '/description = \"allow ssh into public subnet\"/r'<(cat role/dev_tool/files/httpd) terraform/security.tf