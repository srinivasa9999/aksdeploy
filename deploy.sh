echo "deployment type: $1"
DTYPE=$1
declare -a servicenames=("$2" "$3" "$4")
for SERVICE_NAME in "${servicenames[@]}";do
	DEPLOY_NAME=${SERVICE_NAME,,}
	echo $SERVICE_NAME
	case $SERVICE_NAME in
		shoppingCart)
			if [[ $DTYPE == "firsttime" ]];then
				kubectl apply -f ./$SERVICE_NAME -R --record
			elif [[ $DTYPE == "updatedeploy" ]];then
				kubectl apply -f ./$SERVICE_NAME/deploy.yml -R --record
			elif [[ $DTYPE == "stop" ]];then
				kubectl scale deploy $DEPLOY_NAME --replicas=0
			elif [[ $DTYPE == "start" ]];then
				kubectl scale deploy $DEPLOY_NAME --replicas=3
			fi
			;;
		productMgm)
			if [[ $DTYPE == "firsttime" ]];then
				kubectl apply -f ./$SERVICE_NAME -R --record
			elif [[ $DTYPE == "updatedeploy" ]];then
				kubectl apply -f ./$SERVICE_NAME/deploy.yml -R --record
			elif [[ $DTYPE == "stop" ]];then
				kubectl scale deploy $DEPLOY_NAME --replicas=0
			elif [[ $DTYPE == "start" ]];then
				kubectl scale deploy $DEPLOY_NAME --replicas=5
			fi
			;;
		customerMgm)
			if [[ $DTYPE == "firsttime" ]];then
				kubectl apply -f ./$SERVICE_NAME -R --record
			elif [[ $DTYPE == "updatedeploy" ]];then
				kubectl apply -f ./$SERVICE_NAME/deploy.yml -R --record
			elif [[ $DTYPE == "stop" ]];then
				kubectl scale deploy $DEPLOY_NAME --replicas=0
			elif [[ $DTYPE == "start" ]];then
				kubectl scale deploy $DEPLOY_NAME --replicas=2
			elif [[ $DTYPE == "restart" ]];then
				kubectl scale deploy $DEPLOY_NAME --replicas=0
				kubectl scale deploy $DEPLOY_NAME --replicas=2
			fi
			;;
		*)
			echo "*********$SERVICE_NAME:*Service name is incorrect***"
#			exit 1
			;;
	esac
done
