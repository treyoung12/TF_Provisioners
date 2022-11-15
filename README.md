# TF_Provisioners
Going into detail on different provisioners used in Terraform 

Has a breakdown of main functions and usability with the help of provisioners.  
Provisioners are tools that automate the installation of software, edits files, and provisions machines created with Terraform.

Use provisioners as a last resort.  Some options are **cloud-init, local-exec, remote-exec, file, connection, and null blocks**.

The folders are missing the ".terraform" and the ".lock" files, because these files are too large for github.
Please use your own environment variables and commit with command "terraform init" to get your own .terraform and .lock files.
