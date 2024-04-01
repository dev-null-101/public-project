README
======

Service Principal Naming convention
-----------------------------------
| <service>-sp-<environment>
| az ad sp create-for-rbac --name <your-service-principal-name>
| az role assignment create --assignee <appId> --role <Role>



Reference
---------
https://gist.github.com/javiertejero/4585196