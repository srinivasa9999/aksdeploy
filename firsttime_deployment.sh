pwd
echo test
ls -ltr
echo 
echo $JBNUM

kubectl apply -f deploy.yml  -n 



## dynamic variable in octopus CD
## Repo urls are vailable for K8s Repo URL, & application config containing application config YAML
## and cluster config repo containing cluster config info,(note: each of these repos will have 
## branching by enviroonment  names - dev,QA,prod, SIT)
## there can be multiple k8s repo
## download K8s from repo
## variable are : APpname , ,ENVironment, service name , APPversion, , Namespace,
            ##tags, IMage & image tag,Build strategy[] ,Action[firsttime,upgrade-canary,upgrade-blueGreen,upgrde-RolingUpdate,Upgrade-recreate]

