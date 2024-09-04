helm package .\charts\cloud-security\endpoint-connector -d .\releases
helm package .\charts\cloud-security\kubernetes-cluster -d .\releases
helm package .\charts\cloud-security\kubernetes-cluster-connector -d .\releases
helm package .\charts\security-center -d .\releases

helm repo index .