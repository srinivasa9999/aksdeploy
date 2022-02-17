SERVICES=("$@")
for SERVICE_NAME in ${SERVICES[@]};do
    echo $SERVICE_NAME
    DEPLOY_ACTION=$(python3 yamlparser.py $SERVICE_NAME deploy_action)
    DEPLOY_STRATEGY=$(python3 yamlparser.py $SERVICE_NAME deploy_strategy)
    K8S_REPO=$(python3 yamlparser.py $SERVICE_NAME git_url)
    ENVIRONMENT=$(python3 yamlparser.py $SERVICE_NAME environment)
    echo -e "$SERVICE_NAME -> $DEPLOY_ACTION -> $DEPLOY_STRATEGY -> $K8S_REPO"

    git clone $K8S_REPO -b $ENVIRONMENT $SERVICE_NAME

    case $DEPLOY_ACTION in
        firsttime)
            kubectl apply -f ./$SERVICE_NAME/$DEPLOY_STRATEGY -R
            ;;
        upgrade)
            kubectl apply -f ./$SERVICE_NAME/$DEPLOY_STRATEGY/deploy.yml ##Version will change
            ;;
        stop)
            kubectl scale deploy $DEPLOY_NAME --replicas=0
            ;;
        start)
            kubectl scale deploy $DEPLOY_NAME --replicas=1
            ;;
        restart)
            kubectl scale deploy $DEPLOY_NAME --replicas=0
            kubectl scale deploy $DEPLOY_NAME --replicas=1
            ;;
        *)
        echo "Service name Incorrect"
        exit 1
    esac
done
       
      
