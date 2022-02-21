SERVICES=("$@")
for SERVICE_NAME in ${SERVICES[@]};do
    echo $SERVICE_NAME
    DEPLOY_ACTION=$(python3 yamlparser.py $SERVICE_NAME deploy_action)
    DEPLOY_STRATEGY=$(python3 yamlparser.py $SERVICE_NAME deploy_strategy)
    K8S_REPO=$(python3 yamlparser.py $SERVICE_NAME git_url)
    ENVIRONMENT=$(python3 yamlparser.py $SERVICE_NAME environment)
    NAMESPACE=$(python3 yamlparser.py $SERVICE_NAME namespace)
    echo -e "$SERVICE_NAME -> $DEPLOY_ACTION -> $DEPLOY_STRATEGY -> $K8S_REPO"

    git clone $K8S_REPO -b $ENVIRONMENT $SERVICE_NAME/$DEPLOY_STRATEGY

    case $DEPLOY_ACTION in
        firsttime)
            kubectl apply -f ./$SERVICE_NAME/$DEPLOY_STRATEGY -R -n $NAMESPACE
            ;;
        upgrade)
            kubectl apply -f ./$SERVICE_NAME/$DEPLOY_STRATEGY/deploy.yml -n $NAMESPACE ##Version will change
            ;;
        stop)
            kubectl scale deploy $DEPLOY_NAME --replicas=0 -n $NAMESPACE
            ;;
        start)
            kubectl scale deploy $DEPLOY_NAME --replicas=1 -n $NAMESPACE
            ;;
        restart)
            kubectl scale deploy $DEPLOY_NAME --replicas=0 -n $NAMESPACE
            kubectl scale deploy $DEPLOY_NAME --replicas=1 -n $NAMESPACE
            ;;
        *)
        echo "Service name Incorrect"
        exit 1
    esac
done
       
      
