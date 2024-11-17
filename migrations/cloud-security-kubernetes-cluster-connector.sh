 #!/bin/sh

set -e

HELM_RELEASE_DATA="$(helm list -A --deployed -f kubernetes-cluster-connector -o yaml | grep -e name -e namespace)"

if [ "$(echo "${HELM_RELEASE_DATA}" | wc -l)" -ne 2 ]; then
    echo "Could not determine Tenable Kubernetes Cluster Connector release to migrate, please contact support."
    echo "${HELM_RELEASE_DATA}"
    exit
fi

HELM_OLD_RELEASE_NAME=$(echo "${HELM_RELEASE_DATA}" | grep 'name:' | cut -d':' -f2 | xargs)
HELM_OLD_RELEASE_NAMESPACE_NAME=$(echo "${HELM_RELEASE_DATA}" | grep 'namespace:' | cut -d':' -f2 | xargs)
HELM_OLD_VALUES="$(helm get values ${HELM_OLD_RELEASE_NAME} -n ${HELM_OLD_RELEASE_NAMESPACE_NAME} -o yaml)"
HELM_VALUES_FILE_PATH="$(mktemp)"

echo "${HELM_OLD_VALUES}" | sed -e 's/endpoint:.*//'                   \
                                -e 's/configureIdentity:.*//'          \
                                -e 's/configureNetwork:.*//'           \
                                -e 's/resourceNamePrefix:.*//'         \
                                -e 's/containerImagePath:.*//'         \
                                -e 's/containerImagePullSecrets:.*//'  \
                                -e '/^$/d' > ${HELM_VALUES_FILE_PATH}
HELM_CONFIGURE_IDENTITY=""
HELM_CONFIGURE_NETWORK=""

if [[ "${HELM_OLD_VALUES}" =~ configureIdentity:[[:space:]]*false ]]; then
    HELM_CONFIGURE_IDENTITY="--set connector.identity=false"
fi

if [[ "${HELM_OLD_VALUES}" =~ configureNetwork:[[:space:]]*false ]]; then
    HELM_CONFIGURE_NETWORK="--set connector.network=false"
fi

echo Migrating Old Release:
echo -----------------------------------------------------------
echo Name: ${HELM_OLD_RELEASE_NAME}
echo Namespace: ${HELM_OLD_RELEASE_NAMESPACE_NAME}
echo Values:
cat ${HELM_VALUES_FILE_PATH}
echo ""

echo Removing Old Release:
echo -----------------------------------------------------------

if [[ $* == *"--dry-run"* ]]; then
  helm uninstall ${HELM_OLD_RELEASE_NAME} -n ${HELM_OLD_RELEASE_NAMESPACE_NAME} --no-hooks --keep-history --dry-run
else
  helm uninstall ${HELM_OLD_RELEASE_NAME} -n ${HELM_OLD_RELEASE_NAMESPACE_NAME} --no-hooks --keep-history
fi

echo Installing New Release:
echo -----------------------------------------------------------
helm install $* ${HELM_CONFIGURE_IDENTITY} ${HELM_CONFIGURE_NETWORK} -f ${HELM_VALUES_FILE_PATH}
