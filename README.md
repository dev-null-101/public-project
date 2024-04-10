# README
#### Project Date Started: 04/01/2024
#### Note: This project focuses on DevOps Engineer, Cloud Engineer and Devops Security Engineer Roles
* This project will include security, automation and CICD.
* Public Cloud Providers:  Azure, GCP, AWS, Linode ...
* Ansible, Terraform, Python, API, Bash, Powershell, Web Services...
* Clouds Services: Kubernetes, GKE, Network, DNS etc.
* Pipeline: Github Action, Azure DevOps

#### git ssh config in jumpvm:
```
ssh-keygen -b 1024 -f <key>

git clone -b master git@github.com:user/repository.git --single-branch --depth 1 --recurse-submodules=recursive -c core.sshCommand='ssh -i /path/to/private-key'
```

#### Reference: 
```
README:
https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax

GHA SYNTAX:
https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions
```