# Instructions
# - Use space if you want to indent
# - To update your basrhc you can run uprc

# update .basrhc
alias uprc="cat < /repository/coreos-vagrant/templates/.bashrc > ~/.bashrc && exec -l $SHELL"

# repository
alias repo="cd /repository"

# ls
alias l="ls -lthg --color"
alias la="l -A"

# Affichage
alias ct="clear && pwd"

# Edit .bashc
alias edb="vi ~/.bashrc"

# debian
alias debian="docker run -ti --rm debian:latest bash"

# DOCKER
alias dps="docker ps"
alias dpsa="docker ps -a"
alias dim="docker images"
# alias dclean="docker kill $(docker ps -q) && docker rm $(docker ps -a -q) && docker rmi $(docker images -q -f dangling=true)"

# GIT
alias ga="git add"
alias gaa="git add -A"
alias gl="git pull"
alias gp="git push"
alias gst="git status"
alias gcmsg="git commit -m"
alias gchmodx="git update-index --chmod=+x"

# GCLOUD
kube_default_zone="europe-west1-b"

# main function for running docker gcloud
function gcloud-tools {
  docker run                                         \
    --rm                                             \
    -v /home/core/.kube/:/.kube/                     \
    -v /home/core/.config/gcloud/:/.config/gcloud/   \
    -v `pwd`:/workspace                              \
    -w /workspace                                    \
    -ti tdeheurles/gcloud-tools                      \
   $@
}

function gcloud {
  gcloud-tools gcloud $@
}

function kubectl {
  gcloud-tools kubectl $@
}


# kubernetes
function kubestatus {
  echo -e "\e[94m master services\e[39m" \
    && echo -n "   api-server        "   \
    && systemctl status kube-apiserver | grep --color=never Active \
    && echo -n "   controller-manager"   \
    && systemctl status kube-controller-manager | grep --color=never Active \
    && echo -n "   scheduler         "   \
    && systemctl status kube-scheduler | grep --color=never Active \
    && echo -e "\e[94m node services\e[39m" \
    && echo -n "   kubelet           " \
    && systemctl status kube-kubelet | grep --color=never Active \
    && echo -n "   proxy             " \
    && systemctl status kube-proxy | grep --color=never Active \
    && echo " "
}

function kst {
  if [[ -z $1 ]]; then
    namespace="--namespace=default"
  else
    namespace="--namespace=$1"
  fi

  clear                                        \
    && echo -e "\e[92mSERVICES\e[39m"          \
    && kubectl get services $namespace         \
    && echo " "                                \
    && echo -e "\e[92mRC\e[39m"                \
    && kubectl get rc $namespace               \
    && echo " "                                \
    && echo -e "\e[92mPODS\e[39m"              \
    && kubectl get pods $namespace             \
    && echo " "                                \
    && echo -e "\e[92mENDPOINTS\e[39m"         \
    && kubectl get endpoints $namespace        \
    && echo " "
}

# deploy rc & service
function kcreate {
  . ./config/release.cfg
  kubectl create -f ./deploy/kubernetes/rc_latest.$template_extension -f ./deploy/kubernetes/service_latest.$template_extension
}
alias kstop="kubectl stop rc,service -l "

# to scale eplicas of a RC
function gscale {
  kubectl scale --replicas=$2 rc $1
}

# Set gcloud project to argument
function gsp {
  gcloud config set project $1
}


# Get credentials for kubectl
function ggc {
  gcloud alpha container get-credentials --zone=$kube_default_zone --cluster=$1
}

alias gfo="gcloud compute forwarding-rules list"
alias gfi="gcloud compute firewall-rules list"

alias glogin="gcloud auth login"
alias gal="gcloud auth list"
alias gsa="gcloud config set account"
alias kcv="echo \" \" ; gcloud config list | grep account ; gcloud config list | grep project ; kubectl config view | grep current-context ; echo \" \" ; echo -e \"\e[92mAvailable contexts\e[39m\" ; kubectl config view | egrep \"user: \" | sed s/user:/-/g ; echo \" \""
alias kuse="kubectl config use-context"

# jvm-tools
function jvm-tools {
  docker run                            \
    --rm                                \
    -v ~/.ivy2:/root/.ivy2              \
    -v ~/.sbt:/root/.sbt                \
    -v ~/.activator:/root/.activator    \
    -v `pwd`:/workspace                 \
    -w /workspace                       \
    -ti tdeheurles/jvm-tools /bin/bash -c "$@"
}

# golang
export PATH="~/go/bin:$PATH"
function goinstall {
  docker run \
  --rm \
  -v ~/go:/go \
  -v `pwd`:/usr/src/`basename $(pwd)` \
  golang:latest \
    /bin/bash -c "mkdir -p /go/src/`basename $(pwd)` ; cp -r /usr/src/`basename $(pwd)` /go/src/ ; cd /go/src/`basename $(pwd)` ; go install"
}

function go {
  docker run \
  --rm \
  -v ~/go:/go \
  -v `pwd`:/usr/src/`basename $(pwd)` \
  -w /usr/src/`basename $(pwd)` \
  golang:latest \
  go $@
}


function goget {
  docker run \
  --rm \
  -v ~/go:/go \
  -v `pwd`:/usr/src/`basename $(pwd)` \
  golang:latest \
    /bin/bash -c "go get $@"
}
