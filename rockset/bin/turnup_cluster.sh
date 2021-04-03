
cd $(dirname $0)
. vars.sh
cd ..

set -e
if [ -z $VERBOSITY ]; then
    # This was 2 and then it did *nothing* for a very long time
    VERBOSITY=3
fi

# The names in the config files and this have to match
CLUSTER_CONFIG_FILE=$(pwd)/eks_config/rockset_eks_cluster.yaml
CLUSTER_CONFIG_DIRECTORY=$(pwd)/eks_config/cluster_config/

# If this already exists, it will sometimes fail
CLUSTER_TURNUP_COMMAND="eksctl create cluster -v ${VERBOSITY?} -f ${CLUSTER_CONFIG_FILE?}"


# Sadly, this isn't idempotent
if eksctl get clusters | grep -q ${CLUSTER_NAME?}; then
    echo "Cluster ${CLUSTER_NAME?} already exists and cannot be created"
    echo "To delete, run \`eksctl delete cluster --name=${CLUSTER_NAME?}\`"
else
    echo "Turning up cluster ${CLUSTER_NAME}"
    set +e
    eval ${CLUSTER_TURNUP_COMMAND?}
    set -e
fi

if ! eksctl get clusters | grep -q ${CLUSTER_NAME?}; then
    while true; do
        echo "Something went wrong with turning up eks cluster ${CLUSTER_NAME?}"
        echo "Please verfiy that the cluster is in an up state before continuing"
        echo ""
        echo "    \`${CLUSTER_TURNUP_COMMAND?}\`"
        echo ""
        echo "To get more turnup output, set VERBOSITY=[1-5](default:2)"
        read -p "continue? [y/n]: " yn
        case $yn in
            [Yy]* )
                break;;
            [Nn]* )
                exit -1;;
            * ) echo "Please answer [y]es or [n]o.";;
        esac
    done
fi

echo "Updating Kubeconfig":
aws eks update-kubeconfig --name ${CLUSTER_NAME?}

echo "Updating cluster ${CLUSTER_NAME?} with the local configuration":
kubectl apply -f ${CLUSTER_CONFIG_DIRECTORY?}

echo "Getting the new endpoint"
until grep -q "elb.amazonaws.com" <<< "$ENDPOINT";
do 
    sleep 1
    ENDPOINT=$(kubectl get svc ${SERVICE_NAME?} | tail -n 1 | awk '{print $4}')
done

echo "ENDPOINT=${ENDPOINT?}"
echo "To test this, wait about 2 minutes, then run\`curl ${ENDPOINT}\`"
