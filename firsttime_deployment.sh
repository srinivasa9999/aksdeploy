JBNUMBER=`echo $(get_octopusvariable "JBNUM")`
echo "*******jenkins build: $JBNUMBER"
echo "***********3"

sed -i s/imageversion/$JBNUMBER/g ./k8stest/deployments/deploy.yml

DTYPE=`echo $(get_octopusvariable "DEPLOYTYPE")`
echo "**********Deploy Type : $DTYPE"

SERVICE_NAME=shoppingCart

if [[ $DTYPE == "firsttime" ]];then
 kubectl apply -f ./$SERVICE_NAME -R --record
elif [[ $DTYPE == "updatedeploy" ]];then
 kubectl apply -f ./$SERVICE_NAME/deploy.yml -R --record
elif [[ $DTYPE == "stop" ]];then
kubectl scale deploy $SERVICE_NAME --replicas=0
elif [[ $DTYPE == "start" ]];then
kubectl scale deploy $SERVICE_NAME --replicas=3
fi


## dynamic variable in octopus CD
## Repo urls are vailable for K8s Repo URL, & application config containing application config YAML
## and cluster config repo containing cluster config info,(note: each of these repos will have 
## branching by enviroonment  names - dev,QA,prod, SIT)
## there can be multiple k8s repo
## download K8s from repo
## variable are : APpname , ,ENVironment, service name , APPversion, , Namespace,
            ##tags, IMage & image tag,Build strategy[] ,
            ##Action[firsttime,upgrade-canary,upgrade-blueGreen,upgrde-RolingUpdate,Upgrade-recreate]

##Re order -> environemnts -> lifecycle
