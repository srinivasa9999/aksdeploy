case $SERVICE_NAME in

  shoppingCart)
    if [[ $DTYPE == "firsttime" ]];then
         kubectl apply -f ./$SERVICE_NAME -R --record
    elif [[ $DTYPE == "updatedeploy" ]];then
        kubectl apply -f ./$SERVICE_NAME/deploy.yml -R --record
    elif [[ $DTYPE == "stop" ]];then
        kubectl scale deploy $SERVICE_NAME --replicas=0
    elif [[ $DTYPE == "start" ]];then
        kubectl scale deploy $SERVICE_NAME --replicas=3
    fi
    ;;

  productMgm)
    if [[ $DTYPE == "firsttime" ]];then
         kubectl apply -f ./$SERVICE_NAME -R --record
    elif [[ $DTYPE == "updatedeploy" ]];then
        kubectl apply -f ./$SERVICE_NAME/deploy.yml -R --record
    elif [[ $DTYPE == "stop" ]];then
        kubectl scale deploy $SERVICE_NAME --replicas=0
    elif [[ $DTYPE == "start" ]];then
        kubectl scale deploy $SERVICE_NAME --replicas=3
    fi
    ;;

  customerMgm)
    if [[ $DTYPE == "firsttime" ]];then
         kubectl apply -f ./$SERVICE_NAME -R --record
    elif [[ $DTYPE == "updatedeploy" ]];then
        kubectl apply -f ./$SERVICE_NAME/deploy.yml -R --record
    elif [[ $DTYPE == "stop" ]];then
        kubectl scale deploy $SERVICE_NAME --replicas=0
    elif [[ $DTYPE == "start" ]];then
        kubectl scale deploy $SERVICE_NAME --replicas=3
    fi
    ;;

  *)
    STATEMENTS
    ;;
esac