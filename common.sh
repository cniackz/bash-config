#!/bin/bash

######################################
#
# Krew
# https://krew.sigs.k8s.io/docs/user-guide/setup/install/
#
######################################
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)

######################################
#
# Environment Variables
#
######################################
export OPERATOR_DEV_TEST="ON"
export PATH="/opt/homebrew/opt/node@18/bin:$PATH"
export PATH="${PATH}:${HOME}/.krew/bin"
export PATH=/Library/PostgreSQL/15/bin:$PATH # To have psql
export POSTGRESQL_URL='postgres://postgres:testing123@localhost:5432/change-manager?sslmode=disable'
export CONFIG_FILES=/Users/cniackz/bash-config/config-files

######################################
#
# All shared Aliases
#
######################################
alias ext=exit
alias cls=clear
alias k="kubectl"
alias podman=docker
alias gadd="git add"
alias gst="git status"
alias gpush="git push"
alias gdiff="git diff"
alias gpull="git pull"
alias redhatserver="ssh minio@65.49.37.19"
alias wb1="git rev-parse --abbrev-ref HEAD"
alias sshpg="ssh cesar@65.49.37.17 -p 4492"
alias sshasus="ssh ccelis@72.140.145.27 -p 22"
alias sshintel="ssh minio@64.71.151.78 -p 4492"
alias sambaserver="ssh minio@65.49.37.28 -p 4492"

######################################
#
# Common functions:
#
######################################

function deleteCluster() {
    printMessage "kind delete cluster:"
    kind delete cluster
}

function commit() {
    git add .
    git commit -m 'a'
    git push
}

function gcommit() {
    git commit -m "${1}"
}





































# To develop in Operator
function nginxOperator() {
    createcluster ingress
    installoperator ingress
}




# To develop in Operator
function nginxAll() {
    createcluster ingress
    installoperator ingress
    installtenant nginx
}



























######################################
#
# This function call a function to
# create a k8s cluster in kind
#
######################################
function createcluster() {
    
    # To delete cluster if any:
    deleteCluster
    
    ISTHEREACLUSTER=NO

    if [ "$1" == "nodeport" ]
    then
        createclusternp
        ISTHEREACLUSTER=YES
    elif [ "$1" == "8nodes" ]
    then
        createcluster8nodes
        ISTHEREACLUSTER=YES
        # To put pool-0 in these nodes:
        kubectl label nodes kind-worker5 pool=one
        kubectl label nodes kind-worker6 pool=one
        kubectl label nodes kind-worker7 pool=one
        kubectl label nodes kind-worker8 pool=one
    elif [ "$1" == "ingress" ]
    then
        createclusteringress
        ISTHEREACLUSTER=YES
    elif [ "$1" == "oldversion" ]
    then
        createclusteroldversion
        ISTHEREACLUSTER=YES
    elif [ "$1" == "myownip" ]
    then
        createclustermyownip
        ISTHEREACLUSTER=YES
    elif [ "$1" == "base" ]
    then
        createclusterbase
        ISTHEREACLUSTER=YES
    else
        createclusterhelp
        ISTHEREACLUSTER=NO
    fi
    
    # Create Labels for nodes only if we have a cluster:
    if [ "$ISTHEREACLUSTER" == "YES" ]
    then
        # To put pool-0 in these nodes:
        kubectl label nodes kind-worker  pool=zero
        kubectl label nodes kind-worker2 pool=zero
        kubectl label nodes kind-worker3 pool=zero
        kubectl label nodes kind-worker4 pool=zero
    fi
  
}




















































######################################
#
# This function provides help on what
# function to call for creating a
# given k8s cluster:
#
######################################
function createclusterhelp() {
    echo "                           "
    echo "                           "
    echo "                           "
    echo "**SUPPORTED CLUSTERS ARE:  "
    echo "                           "    
    echo "                           "
    echo "                           "
    echo "###########################"
    echo "1. createcluster nodeport"
    echo "2. createcluster 8nodes"
    echo "3. createcluster ingress"
    echo "4. createcluster oldversion"
    echo "5. createcluster myownip"
    echo "6. createcluster base"
    echo "###########################"
    echo "                           "
    echo "                           "
    echo "                           "
    read -p "Option #: " option
    if [ "$option" == "1" ]
    then
        createclusternp
    fi
    if [ "$option" == "2" ]
    then
        createcluster8nodes
    fi
    if [ "$option" == "3" ]
    then
        createclusteringress
    fi
    if [ "$option" == "4" ]
    then
        createclusteroldversion
    fi
    if [ "$option" == "5" ]
    then
        createclustermyownip
    fi
    if [ "$option" == "6" ]
    then
        createclusterbase
    fi
}




















































# Functions to create a cluster based on different config file for kind.
# All of them are being called in the same spot and hence some extra functionality can be
# found at that spot: createcluster()
# Like: deleteCluster, etc.
function createclusternp() {
    kind create cluster --config /Users/cniackz/bash-config/config-files/kind/kind-config-nodeport.yaml
}

function createcluster8nodes() {
    kind create cluster --config /Users/cniackz/bash-config/config-files/kind/kind-config-8-nodes.yaml
}

function createclusteringress() {
    kind create cluster --config /Users/cniackz/bash-config/config-files/kind/kind-config-ingress.yaml
}

function createclusteroldversion() {
    kind create cluster --config /Users/cniackz/bash-config/config-files/kind/kind-config-1-18.yaml
}

function createclustermyownip() {
    kind create cluster --config /Users/cniackz/bash-config/config-files/kind/kind-config-with-my-own-ip.yaml
}

function createclusterbase() {
    kind create cluster --config /Users/cniackz/bash-config/config-files/kind/kind-config-base.yaml
}


































































































function JWTOperator() {
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: console-sa-secret
  namespace: minio-operator
  annotations:
    kubernetes.io/service-account.name: console-sa
type: kubernetes.io/service-account-token
EOF
SA_TOKEN=$(kubectl -n minio-operator  get secret console-sa-secret -o jsonpath="{.data.token}" | base64 --decode)
echo ""
echo ""
echo ""
echo $SA_TOKEN
echo ""
echo ""
echo ""
}

















































function printMessage() {
    MESSAGE=$1
    echo " "
    echo "####################"
    echo "${MESSAGE}"
    echo "####################"
}

function crcStop() {
    printMessage "crc stop:"
    crc stop
}

function crcDelete() {
    printMessage "crc delete -f:"
    crc delete -f
}

function crcCleanUp() {
    printMessage "crc cleanup:"
    crc cleanup
}

function crcConfigSetCpus() {
    printMessage "crc config set cpus 8:"
    crc config set cpus 8
}

function crcConfigSetMemory() {
    printMessage "crc config set memory 16384:"
    crc config set memory 16384
}

function crcSetup() {
    printMessage "crc setup:"
    crc setup
}

function crcStart() {
    printMessage "crc start -c 8 -m 16384:"
    crc start -c 8 -m 16384
}

















































# https://github.com/cniackz/public/wiki/crc
function crcRun() {
    echo "https://github.com/cniackz/public/wiki/crc"
    deleteCluster
    crcStop
    crcDelete
    crcCleanUp
    crcConfigSetCpus
    crcConfigSetMemory
    crcSetup
    crcStart
}

















































function upgradetenant() {

    echo "Current version:"
    helm list -n tenant-ns
    echo " "; echo " "; echo " ";

    echo "Upgrade:"
    helm upgrade --namespace tenant-ns tenant-ns /Users/cniackz/bash-config/config-files/helm/Tenant/helm-tenant-5.0.10
    echo " "; echo " "; echo " ";

    echo "New version:"
    helm list -n tenant-ns
    echo " "; echo " "; echo " ";

}




















































# To upgrade Operator via Helm:
function upgradeoperator() {

    # Before:
    helm list -n minio-operator

    # Upgrade:
    helm upgrade \
         --namespace minio-operator \
         minio-operator /Users/cniackz/bash-config/config-files/helm/Operator/helm-operator-5.0.10

    # After:
    helm list -n minio-operator

}
















































# To install 4.5.2 version of Operator and Tenant
function install452() {
    createclusterbase
    k apply -f /Users/cniackz/bash-config/config-files/kustomize/Operator/kustomize-operator-4-5-2.yaml
    cd /Users/cniackz/bash-config/config-files/kustomize/Tenant
    # kustomize build github.com/minio/operator/examples/kustomization/tenant-lite\?ref\=v4.5.2 > tenant-4-5-2.yaml
    # Then modified and removed logs and prometheus.
    k apply -f /Users/cniackz/bash-config/config-files/kustomize/Tenant/kustomize-tenant-4-5-2.yaml
}





















































######################################
#
# This function install an Operator
# type based on user's input.
#
######################################
function installoperator() {
    if [ "$1" == "nodeport" ]
    then
        installoperatornp
    elif [ "$1" == "ingress" ]
    then
        installoperatoringress
    elif [ "$1" == "fromgithub" ]
    then
        installOperatorFromGitHub
    elif [ "$1" == "withhelm" ]
    then
        installoperatorhelm
    else
        installoperatorhelp
    fi
}



















































######################################
#
# This function offers help on how to
# actually install an Operator
#
######################################
function installoperatorhelp() {
    echo "                              "
    echo "                              "
    echo "                              "
    echo "** SUPPORTED METHODS:         "
    echo "                              "
    echo "                              "
    echo "                              "
    echo "##############################"
    echo "1. installoperator nodeport   "
    echo "2. installoperator ingress    "
    echo "3. installoperator fromgithub "
    echo "4. installoperator withhelm   "
    echo "##############################"
    echo "                              "
    echo "                              "
    echo "                              "
    read -p "Option #: " option
    if [ "$option" == "1" ]
    then
        installoperatornp
    fi
    if [ "$option" == "2" ]
    then
        installoperatoringress
    fi
    if [ "$option" == "3" ]
    then
        installOperatorFromGitHub
    fi
    if [ "$option" == "4" ]
    then
        installoperatorhelm
    fi
}





















































### installoperatornp is for nodeport
function installoperatornp() {
    k apply -f /Users/cniackz/bash-config/config-files/kustomize/Operator/kustomize-operator-5-0-11.yaml
    exposeOperatorViaNodePort
}




















































######################################
#
# This function install Operator using
# NGINX Ingress for its exposure.
#
######################################
function installoperatoringress() {

    # Install NGINX
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

    echo " "
    echo " "
    echo " "
    echo "##########################"
    echo "Wait for NGINX to be ready"
    echo "##########################"
    kubectl wait --namespace ingress-nginx \
      --for=condition=ready pod \
      --selector=app.kubernetes.io/component=controller \
      --timeout=90s

    # Add --enable-ssl-passthrough to enable passthrough in ingress-nginx deployment:
    k apply -f /Users/cniackz/bash-config/config-files/nginx

    echo " "
    echo " "
    echo " "
    echo "##########################"
    echo "Wait for NGINX to be ready"
    echo "##########################"
    kubectl wait --namespace ingress-nginx \
      --for=condition=ready pod \
      --selector=app.kubernetes.io/component=controller \
      --timeout=90s

    ############################################################################
    #
    # I Think we can expose it to nodeport as well, might be useful to have them
    # both enabled at the same time!.
    #
    ############################################################################
    installoperatornp

    echo " "
    echo " "
    echo " "
    echo "##########################"
    echo "Wait for NGINX to be ready"
    echo "##########################"
    kubectl wait --namespace ingress-nginx \
      --for=condition=ready pod \
      --selector=app.kubernetes.io/component=controller \
      --timeout=90s

    ############################################################################
    #
    # To expose the Operator via Ingress with NGINX
    # Note, we removed the NGINX Annotations as they are not needed!:
    #   annotations:
    #     nginx.ingress.kubernetes.io/rewrite-target: /$2 <-- This
    #
    ############################################################################
    k apply -f /Users/cniackz/bash-config/config-files/ingress/operator-ingress.yaml

}










































# This function install the operator from GitHub using Tag, it is mainly intended
# as documentation, so that we can use it when needed for demos with customers.
function installOperatorFromGitHub() {
    # Make sure to use version or tag so that you don't have to compile against latest master code.
    k apply -k github.com/minio/operator/resources/\?ref\=v5.0.9
}



























# This function creates the Operator YAML
# It requires fast network to work and the kustomize command.
function createOperatorYAML() {
    kustomize build github.com/minio/operator/resources/\?ref\=v5.0.11 > /Users/cniackz/bash-config/config-files/kustomize/Operator/kustomize-operator-5-0-11.yaml
}

function createOperatorYAML_5_0_9() {
    kustomize build github.com/minio/operator/resources/\?ref\=v5.0.9 > /Users/cniackz/bash-config/config-files/kustomize/Operator/kustomize-operator-5-0-9.yaml
}

function createOperatorYAML_5_0_8() {
    kustomize build github.com/minio/operator/resources/\?ref\=v5.0.8 > /Users/cniackz/bash-config/config-files/kustomize/Operator/kustomize-operator-5-0-8.yaml
}

function createOperatorYAML_5_0_7() {
    kustomize build github.com/minio/operator/resources/\?ref\=v5.0.7 > /Users/cniackz/bash-config/config-files/kustomize/Operator/kustomize-operator-5-0-7.yaml
}

function createOperatorYAML_5_0_4() {
    kustomize build github.com/minio/operator/resources/\?ref\=v5.0.4 > /Users/cniackz/bash-config/config-files/kustomize/Operator/kustomize-operator-5-0-4.yaml
}

function createOperatorYAML_4_5_8() {
    kustomize build github.com/minio/operator/resources/\?ref\=v4.5.8 > /Users/cniackz/bash-config/config-files/kustomize/Operator/kustomize-operator-4-5-8.yaml
}






















































function createTenantYAML() {
    # From Master:
    # kustomize build github.com/minio/operator/examples/kustomization/tenant-lite > tenant.yaml
    # From Tag:
    # kustomize build github.com/minio/operator/examples/kustomization/tenant-lite\?ref\=v5.0.8 > tenant.yaml
    kustomize build github.com/minio/operator/examples/kustomization/tenant-lite\?ref\=v5.0.11 > /Users/cniackz/bash-config/config-files/kustomize/Tenant/kustomize-tenant-5-0-11.yaml
}

function createTenantYAMLCertManager() {
    kustomize build github.com/minio/operator/examples/kustomization/tenant-certmanager\?ref\=v5.0.10 > /Users/cniackz/bash-config/config-files/kustomize/Tenant/kustomize-tenant-cert-manager-5-0-10.yaml
}

function createTenantYAMLCertManagerKes_5_0_11(){
    kustomize build github.com/minio/operator/examples/kustomization/tenant-certmanager-kes\?ref\=v5.0.11 > /Users/cniackz/bash-config/config-files/kustomize/Tenant/kustomize-tenant-cert-manager-kes-5-0-11.yaml
}

function createTenantYAMLCertManager_4_5_8() {
    kustomize build github.com/minio/operator/examples/kustomization/tenant-certmanager\?ref\=v4.5.8 > /Users/cniackz/bash-config/config-files/kustomize/Tenant/kustomize-tenant-cert-manager-4-5-8.yaml
}

function createTenantYAMLCertManager_5_0_4() {
    kustomize build github.com/minio/operator/examples/kustomization/tenant-certmanager\?ref\=v5.0.4 > /Users/cniackz/bash-config/config-files/kustomize/Tenant/kustomize-tenant-cert-manager-5-0-4.yaml
}

function createTenantYAMLCertManager_5_0_7() {
    kustomize build github.com/minio/operator/examples/kustomization/tenant-certmanager\?ref\=v5.0.7 > /Users/cniackz/bash-config/config-files/kustomize/Tenant/kustomize-tenant-cert-manager-5-0-7.yaml
}

function createTenantYAMLCertManager_5_0_9() {
    kustomize build github.com/minio/operator/examples/kustomization/tenant-certmanager\?ref\=v5.0.9 > /Users/cniackz/bash-config/config-files/kustomize/Tenant/kustomize-tenant-cert-manager-5-0-9.yaml
}

function createTenantYAMLCertManager_5_0_8() {
    kustomize build github.com/minio/operator/examples/kustomization/tenant-certmanager\?ref\=v5.0.8 > /Users/cniackz/bash-config/config-files/kustomize/Tenant/kustomize-tenant-cert-manager-5-0-8.yaml
}














































function installoperatorhelm() {
    helm install \
         --namespace minio-operator \
         --create-namespace minio-operator \
         /Users/cniackz/bash-config/config-files/helm/Operator/helm-operator-5.0.9
}




















































# To expose operator via NodePort
function exposeOperatorViaNodePort() {
    k get service console -n minio-operator -o yaml > ~/service.yaml
    yq e -i '.spec.type="NodePort"' ~/service.yaml
    yq e -i '.spec.ports[0].nodePort = 30080' ~/service.yaml
    k apply -f ~/service.yaml
    k get deployment minio-operator -n minio-operator -o yaml > ~/operator.yaml
    yq -i -e '.spec.replicas |= 1' ~/operator.yaml
    k apply -f ~/operator.yaml
    k apply -f /Users/cniackz/bash-config/config-files/others/console-secret.yaml -n minio-operator
    SA_TOKEN=$(k -n minio-operator get secret console-sa-secret -o jsonpath="{.data.token}" | base64 --decode)
    echo ""
    echo ""
    echo ""
    echo "########################################"
    echo "#"
    echo "# START: Operator Token"
    echo "#"
    echo "########################################"
    echo ""
    echo ""
    echo ""
    echo $SA_TOKEN
    echo ""
    echo ""
    echo ""
    echo "########################################"
    echo "#"
    echo "# END: Operator Token"
    echo "#"
    echo "########################################"
    echo ""
    echo ""
    echo ""
}









































# To allow user to pick from a method when installing the tenant:
function installtenant() {
    if [ "$1" == "nginx" ]
    then
        installtenantnginx
    elif [ "$1" == "nodeport" ]
    then
        installtenantnp
    elif [ "$1" == "helm" ]
    then
        installtenanthelm
    else
        installtenanthelp
    fi
}


















































# To provide support on what methods can be used when installing the tenant.
function installtenanthelp() {
    echo "                              "
    echo "                              "
    echo "                              "
    echo "** SUPPORTED METHODS:         "
    echo "                              "
    echo "                              "
    echo "                              "
    echo "##############################"
    echo "1. installtenant nginx        "
    echo "2. installtenant nodeport     "
    echo "3. installtenant helm         "
    echo "##############################"
    echo "                              "
    echo "                              "
    echo "                              "
    read -p "Option #: " option
    if [ "$option" == "1" ]
    then
        installtenantnginx
    fi
    if [ "$option" == "2" ]
    then
        installtenantnp
    fi
    if [ "$option" == "3" ]
    then
        installtenanthelm
    fi
}
































function installtenantkustomize_cert_manager() {
    kubectl apply -k github.com/minio/operator/examples/kustomization/tenant-certmanager
}






function installtenantkustomize() {
    k apply -f /Users/cniackz/bash-config/config-files/kustomize/Tenant/kustomize-tenant-5-0-11.yaml
}





















































# To install tenant for node port
function installtenantnp() {
    installtenantkustomize
    # TODO: Expose tenant via NodePort, remember there are two services one for mc the other for react.
}

































function helm_install_tenant() {

k create namespace tenant-ns
helm install -f /Users/cniackz/operator/helm/tenant/values.yaml minio /Users/cniackz/operator/helm/tenant

}






# To install tenant via Helm:
function installtenanthelm() {
    helm install \
      --namespace tenant-ns \
      --create-namespace tenant-ns \
      /Users/cniackz/bash-config/config-files/helm/Tenant/helm-tenant-5.0.9
}











































# To install tenant for nginx with cert-manager
function installtenantnginx_cert_manager() {

    # Install Tenant via Kustomize as our preferred method:
    installtenantkustomize_cert_manager

    # Apply ingress:
    k apply -f /Users/cniackz/bash-config/config-files/ingress/tenant-ingress-certmanager.yaml

}












# To install tenant for nginx
function installtenantnginx() {

    # Install Tenant via Kustomize as our preferred method:
    installtenantkustomize

    # Apply ingress:
    k apply -f /Users/cniackz/bash-config/config-files/ingress/tenant-ingress.yaml

}

















































# To install ubuntu pod on any given namespace
function installubuntu() {
    k apply -f /Users/cniackz/bash-config/config-files/others/ubuntu.yaml -n $1
}


















































function squashmissioncontrol() {
    git remote add upstream git@github.com:miniohq/mission-control.git
    git fetch upstream
    git rebase -i upstream/master
}

function squashdocs() {
    git remote add upstream git@github.com:minio/docs.git
    git fetch upstream
    git rebase -i upstream/main
}

function squashrh() {
    git remote add upstream git@github.com:miniohq/release-hub.git
    git fetch upstream
    git rebase -i upstream/main
}

function squashrm() {
    git remote add upstream git@github.com:miniohq/release-manager.git
    git fetch upstream
    git rebase -i upstream/master
}

function squashdp() {
    git remote add upstream git@github.com:minio/directpv.git
    git fetch upstream
    git rebase -i upstream/master
}

function squashpy() {
    git remote add upstream git@github.com:minio/minio-py.git
    git fetch upstream
    git rebase -i upstream/master
}

function squashoperator() {
    git remote add upstream git@github.com:minio/operator.git
    git fetch upstream
    git rebase -i upstream/master
}

function squashconsole() {
    git remote add upstream git@github.com:minio/console.git
    git fetch upstream
    git rebase -i upstream/master
}

function squashenterprise() {
        git remote add upstream git@github.com:miniohq/enterprise.git
        git fetch upstream
        git rebase -i upstream/master
}

function clearMinIO() {
    rm -rf /Volumes/data1/*
    rm -rf /Volumes/data2/*
    rm -rf /Volumes/data3/*
    rm -rf /Volumes/data4/*
    rm -rf /Volumes/data1/.minio.sys/
    rm -rf /Volumes/data2/.minio.sys/
    rm -rf /Volumes/data3/.minio.sys/
    rm -rf /Volumes/data4/.minio.sys/
}

function upgradeMinIO() {
    echo "Removing old MinIO binary..."
    sudo rm -rf /usr/local/bin/minio
    echo "Download new MinIO binary..."
    curl --progress-bar -O https://dl.min.io/server/minio/release/darwin-arm64/minio
    chmod +x minio
    sudo mv minio /usr/local/bin/minio
}

function upgradeMC() {
    echo "Removing old mc binary..."
    sudo rm -rf /usr/local/bin/mc
    echo "Download new mc binary..."
    curl --progress-bar -O https://dl.min.io/client/mc/release/darwin-amd64/mc
    chmod +x mc
    sudo mv mc /usr/local/bin/mc
}

































##########################################
#
# Create PR
#
##########################################
REPO=none
BRANCH=none
ACCOUNT=none
function createPR() {

    if [ "$1" == "help" ]
    then
        echo "                                        "
        echo "                                        "
        echo "                                        "
        echo "########################################"
        echo "# Examples you can use:                 "
        echo "########################################"
        echo "                                        "
        echo "                                        "
        echo "createPR rm name-of-the-pr              "
        echo "          |                             "
        echo "          |___ release-manager          "
        echo "                                        "
        echo "                                        "
        echo "                                        "
        echo "createPR enterprise name-of-the-pr      "
        echo "          |                             "
        echo "          |___ enterprise               "
        echo "                                        "
        echo "                                        "
        echo "                                        "
        echo "createPR dp name-of-the-pr              "
        echo "          |                             "
        echo "          |___ directpv                 "
        echo "                                        "
        echo "                                        "
        echo "                                        "
        echo "createPR docs name-of-the-pr            "
        echo "          |                             "
        echo "          |___ docs                     "
        echo "                                        "
        echo "                                        "
        echo "                                        "
        echo "createPR minio-1 name-of-the-pr         "
        echo "          |                             "
        echo "          |___ minio                    "
        echo "                                        "
        echo "                                        "
        echo "                                        "
        echo "createPR mission-control name-of-the-pr "
        echo "          |                             "
        echo "          |___ mission-control          "
        echo "                                        "
        echo "                                        "
        echo "                                        "
        return 0
    fi

    REPO=$1
    NEW_BRANCH_FOR_PR=$2 # This is different than original branch BRANCH wich normally is master or main

    # It gets the values for:
    #     REPO=none
    #     BRANCH=none
    #     ACCOUNT=none
    convert_short_name_to_proper_name $REPO

    echo "If repo is not set, we can't continue..."
    if [ -z "$REPO" ]
    then
        echo "createPR(): REPO is empty, stop here"
        exit 1
    fi

    echo "Provided parameters are:"
    echo "REPO: ${REPO}"
    echo "NEW_BRANCH_FOR_PR: ${NEW_BRANCH_FOR_PR}"

    echo "1. Removing old Repository"
    echo "rm -rf ~/$REPO"
    rm -rf ~/$REPO

    echo "Changing to home directory"
    echo "cd ~/"
    cd ~/

    echo "Cloning Repository at Home:"
    echo "gc $REPO"
    gc $REPO # git clone repo

    echo "Changing to cloned repo directory:"
    echo "cd ~/$REPO"
    cd ~/$REPO

    echo "Updating the cloned repo:"
    echo "update $REPO"
    update $REPO

    echo "Pushing changes to update"
    echo "git push"
    git push

    echo "Creating new branch: ${NEW_BRANCH_FOR_PR}"
    echo "git checkout -b $NEW_BRANCH_FOR_PR"
    git checkout -b $NEW_BRANCH_FOR_PR

    echo "To Start working Open sublime here:"
    echo "subl ."
}


























######################################
#
# Clone Function
#
######################################

# Git Clone <Repo>
# gc enterprise
# gc operator
# gc minio-1
# gc rh
# gc console
function gc() {
    REPO=$1

    if [ "$REPO" == "rm" ]
    then
        REPO=release-manager
    fi

    if [ "$REPO" == "rh" ]
    then
        REPO=release-hub
    fi

    if [ "$REPO" == "mission-control" ]
    then
        REPO=mission-control
    fi

    git clone git@github.com:cniackz/${REPO}.git
}





































######################################
#
# Helper functions
#
######################################

function convert_short_name_to_proper_name() {

    echo "Check that REPO argument is provided if calling convert_short_name_to_proper_name()"
    if [ -z "$REPO" ]
    then
        echo "ERROR: REPO argument has to be provided when calling convert_short_name_to_proper_name()"
        exit 1
    fi

    echo "convert_short_name_to_proper_name(): We receive only one parameter and from there we determine values"
    REPO=$1

    if [ "$REPO" == "enterprise" ]
    then
        REPO=enterprise
        BRANCH=master
        ACCOUNT=miniohq
    fi

    if [ "$REPO" == "rh" ]
    then
        REPO=release-hub
        BRANCH=main
        ACCOUNT=miniohq
    fi

    if [ "$REPO" == "docs" ]
    then
        REPO=docs
        echo "convert_short_name_to_proper_name(): REPO: ${REPO}"
        BRANCH=main
        echo "convert_short_name_to_proper_name(): BRANCH: ${BRANCH}"
        ACCOUNT=minio
        echo "convert_short_name_to_proper_name(): ACCOUNT: ${ACCOUNT}"
    fi

    if [ "$REPO" == "operator" ]
    then
        REPO=operator
        BRANCH=master
        ACCOUNT=minio
    fi

    if [ "$REPO" == "directpv" ] || [ "$REPO" == "dp" ]
    then
        REPO=directpv
        BRANCH=master
        ACCOUNT=minio
    fi

    if [ "$REPO" == "console" ]
    then
        REPO=console
        BRANCH=master
        ACCOUNT=minio
    fi

    if [ "$REPO" == "minio" ]
    then
        REPO=minio
        BRANCH=master
        ACCOUNT=minio
    fi

    if [ "$REPO" == "minio-1" ]
    then
        REPO=minio-1
        BRANCH=master
        ACCOUNT=minio
    fi

    if [ "$REPO" == "mission-control" ]
    then
        REPO=mission-control
        BRANCH=master
        ACCOUNT=miniohq
    fi

    if [ "$REPO" == "rm" ]
    then
        echo "convert_short_name_to_proper_name(): REPO is rm then REPO will be release-manager"
        REPO=release-manager
        BRANCH=master
        ACCOUNT=miniohq
    fi

}








######################################
#
# Update function
#
######################################

function update() {

    echo "###########################"
    echo "update():"
    echo "###########################"
    echo " "
    echo "We receive only one parameter and from there we determine values"
    REPO=$1
    echo "REPO: ${REPO}"
    echo "convert_short_name_to_proper_name"
    convert_short_name_to_proper_name $REPO # REPO arg is required in this function

    echo "Check REPO is not empty after calling convert_short_name_to_proper_name"
    if [ -z "$REPO" ]
    then
        echo " "
        echo "##################################"
        echo "ERROR: REPO is needed and is empty"
        echo "##################################"
        echo " "
        exit 1
    fi

    echo "Check BRANCH is not empty after calling convert_short_name_to_proper_name"
    if [ -z "$BRANCH" ]
    then
        echo " "
        echo "##################################"
        echo "ERROR: BRANCH is needed and is empty"
        echo "##################################"
        echo " "
        exit 1
    fi 

    echo "git checkout ${BRANCH}"
    git checkout $BRANCH


    # https://stackoverflow.com/questions/35281797/missing-in-bash-script
    if [[ "$REPO" == "minio" || "$REPO" == "minio-1" ]]
    then
        echo "REPO is minio, meaning is a PR for minio golden repo"
        echo "Hence proper name is required not minio-1 but minio just."
        REPO=minio
    fi


    # https://stackoverflow.com/questions/35281797/missing-in-bash-script
    if [[ "$REPO" == "mission-control" || "$REPO" == "mission-control" ]]
    then
        echo "REPO is mission-control, meaning is a PR for mission-control repo"
        echo "Hence proper name is required not other but mission-control."
        REPO=mission-control
    fi


    echo "git remote add upstream git@github.com:${ACCOUNT}/${REPO}.git"
    git remote add upstream git@github.com:${ACCOUNT}/${REPO}.git


    echo "git fetch upstream"
    git fetch upstream
    echo "git rebase upstream/$BRANCH"
    git rebase upstream/$BRANCH
    echo "check if all ok, git push is next:"
    git push
    echo " "
    echo " "

}



















































######################################
#
# The k8s contexts
#
######################################

function intelcontext() {
    kubectl config use-context kubernetes-admin@kubernetes
}

function kindcontext() {
    kubectl config use-context kind-kind
}

function dpcontext() {
    kubectl config use-context directpv-admin@directpv
}























######################################
#
# Other functions
#
######################################
function ghpr() {
    gh repo set-default
    gh pr checkout $1
}

function getminio() {
    sudo rm -rf /usr/local/bin/minio
    curl --progress-bar -O https://dl.min.io/server/minio/release/darwin-arm64/minio
    chmod +x minio
    sudo mv minio /usr/local/bin/minio
}






















