# ============================================================================
# ================== from tdeheurles@gmail.com 

# =================================================== ZSHRC
# =========================================================
alias edz="vi ~/.bashrc && uprc"
alias uprc="exec -l $SHELL"


# ==================================================== PATH
# =========================================================
export PATH="/home/core/programs:$PATH"
# TODO __PROGRAMS_PATH__

# ============================================== REPOSITORY
# =========================================================
repository="/home/core/repository"
alias repo="cd $repository"


# =============================================== AFFICHAGE
# =========================================================
alias l="ls -lthg --color"
alias la="l -A"
alias ct="clear && pwd"


# ================================================== DOCKER
# =========================================================
alias dps="docker ps"
alias dpsa="docker ps -a"
alias dim="docker images"
alias dclean="docker kill \`docker ps -q\` && docker rm \`docker ps -a -q\` && docker rmi \`docker images -q -f dangling=true\`"
alias dti="docker run -ti --rm"

alias dbox="dti busybox sh"
alias ddebian="dti debian:latest bash"
alias dubuntu="dti ubuntu:latest bash"


# ==================================================== GIT
# ========================================================
alias ga="git add"
alias gaa="git add -A"
alias gl="git pull"
alias gp="git push"
alias gst="git status"
alias gcmsg="git commit -m"
alias gchmodx="git update-index --chmod=+x"
function gctd() { 
  git clone https://github.com/tdeheurles/$1 ;
}


# ============================================== KUBERNETES
# =========================================================
function servst {
  echo -e "\e[94m CoreOS\e[39m" \
    && echo -n "   fleet             "   \
    && systemctl status fleet | grep --color=never Active \
    && echo -n "   flanneld          "   \
    && systemctl status flanneld | grep --color=never Active \
    && echo -n "   docker            "   \
    && systemctl status docker | grep --color=never Active \
    && echo -n "   etcd2             "   \
    && systemctl status etcd2 | grep --color=never Active \
    && echo -e "\e[94m master services\e[39m" \
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

# to scale replicas of a RC
function gscale {
  kubectl scale --replicas=$2 rc $1
}


# ========================================= JVM-TOOLS
# ===================================================
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


# =========================================== GOLANG
# ==================================================
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


# ========================================== COREOS
# =================================================
alias catcloudconf="sudo cat /var/lib/coreos-vagrant/vagrantfile-user-data"


# ==================================== CLOUD-CONFIG
# =================================================
cloud_config="$repository/homecores/templates/template.cloud-config.yml"
alias validate-cloud-config="coreos-cloudinit -validate=true --from-file $cloud_config"
alias edit-cloud-config="vi $cloud_config && validate-cloud-config"
alias update-cloud-config="repo ; cd homecores ; ./run_baremetal.sh"
alias edit-cloud-config-config="repo ; cd homecores ; vi config.sh"
alias see-cloud-config="sudo cat /var/lib/coreos-install/user_data"
alias ecc="edit-cloud-config"
alias eccc="edit-cloud-config-config"
alias ucc="update-cloud-config && sudo reboot"
alias scc="see-cloud-config"


# ====================================== JOURNALCTL
# =================================================
alias jcc="journalctl -b --no-pager -u \"user-cloudinit@var-lib-coreos\x2dinstall-user_data.service\""
alias jfu="journalctl -fu"


# =========================================== ETCD
# ================================================
e_change_cluster() {
  sudo systemctl stop etcd2
  sudo rm -rf /home/core/bm0-coreos.etcd2/*
  sudo systemctl start etcd2
}

alias e_last_log="sudo journalctl -f -t etcd2"

alias e_new_discovery_token="echo \`curl --silent http://discovery.etcd.io/new\?size\=1\` | sed 's|https://discovery.etcd.io/||g'"
alias e_member_list="etcdctl member list"
alias e_cluster-health="etcdctl cluster-health"
alias e_hostname_to_id="etcdctl member list | grep \`hostname\` | sed 's/:\s.*//g'"

alias ech="e_cluster-health"
alias eml="e_member_list"

alias elsa="etcdctl ls --recursive"
alias eget="etcdctl get "
alias eset="etcdctl set "


# ===================================== SYSTEMCTL
# ===============================================
alias sst="systemctl status"
alias scat="systemctl cat"
alias sstop="systemctl stop"
alias sstart="systemctl start"


# ======================================= FLANNEL
# ===============================================
alias fenv="cat /run/flannel/subnet.env ; cat /run/flannel/options.env ; scat flanneld ; journalctl -fu flanneld"
