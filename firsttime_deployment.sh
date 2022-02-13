pwd
echo test
ls -ltr
echo "************1"
# echo $JBNUM
echo "************2"
JBNUMBER=`echo $(get_octopusvariable "JBNUM")`
echo "$JBNUMBER"
echo "***********3"

sed -i s/imageversion/$JBNUMBER/g deploy.yml

kubectl apply -f deploy.yml --record



## dynamic variable in octopus CD
## Repo urls are vailable for K8s Repo URL, & application config containing application config YAML
## and cluster config repo containing cluster config info,(note: each of these repos will have 
## branching by enviroonment  names - dev,QA,prod, SIT)
## there can be multiple k8s repo
## download K8s from repo
## variable are : APpname , ,ENVironment, service name , APPversion, , Namespace,
            ##tags, IMage & image tag,Build strategy[] ,
            ##Action[firsttime,upgrade-canary,upgrade-blueGreen,upgrde-RolingUpdate,Upgrade-recreate]

