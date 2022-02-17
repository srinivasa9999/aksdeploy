SERVICES=("shoppingCart" "productMgm")
for SERVICE_NAME in ${SERVICES[@]};do
    SERVICES=shoppingCart
    DEPLOY_ACTION=firsttime
    DEPLOY_STRATEGY=rollingupdate
    K8S_REPO="https://github.com/srinivasa9999/shoppingCart.git"
    git checkout $K8S_REPO -b $ENVIRONMENT $SERVICE_NAME

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
       
      
