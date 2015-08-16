# ============================================================================
# ======================= from duffqiu@gmail.co 
# http://duffqiu.github.io/blog/2015/07/09/install-zsh-coreos/

module_path=(/home/core/zsh/lib64/zsh/5.0.2/)

fpath=(/home/core/zsh/share/zsh/5.0.2/functions/ /home/core/zsh/share/zsh/site-functions/ $fpath)

export PATH=$PATH:/home/core/zsh/bin

# ============================================================================
# ======================= from Oh-My-Zsh 

# Path to your oh-my-zsh installation.
export ZSH=/home/core/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="robbyrussell"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

# User configuration

export PATH="~/go/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/bin"
# export MANPATH="/usr/local/man:$MANPATH"

source $ZSH/oh-my-zsh.sh

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# ============================================================================
# ================== from tdeheurles@gmail.com 
# ZSHRC
# =====
alias edz="vi ~/.zshrc && uprc"
alias uprc="exec -l $SHELL"


# repository
# ==========
repository="/home/core/repository"
alias repo="cd $repository"

# Affichage
# =========
alias l="ls -lthg --color"
alias la="l -A"
alias ct="clear && pwd"

# debian
# ======
alias debian="docker run -ti --rm debian:latest bash"

# DOCKER
# ======
alias dps="docker ps"
alias dpsa="docker ps -a"
alias dim="docker images"
# alias dclean="docker kill $(docker ps -q) && docker rm $(docker ps -a -q) && docker rmi $(docker images -q -f dangling=true)"

# GIT
# ===
alias ga="git add"
alias gaa="git add -A"
alias gl="git pull"
alias gp="git push"
alias gst="git status"
alias gcmsg="git commit -m"
alias gchmodx="git update-index --chmod=+x"
function gctd() { git clone https://github.com/tdeheurles/$1 }

# KUBERNETES
# ==========
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

# GOLANG
# ======
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


# KUBECTL
# =======
# kubectl() {
#   docker run --net=host tdeheurles/gcloud-tools kubectl $@
# }

# COREOS
# ======
alias catcloudconf="sudo cat /var/lib/coreos-install/user_data"

# CLOUD-CONFIG
# ============
cloud_config="$repository/homecores/templates/template.cloud-config.yml"
alias validate-cloud-config="coreos-cloudinit -validate=true --from-file $cloud_config"
alias edit-cloud-config="vi $cloud_config && validate-cloud-config"
alias update-cloud-config="repo ; cd homecores ; ./update_user_data.sh"
alias edit-cloud-config-config="repo ; cd homecores ; vi config.sh ; ./generate.sh"
alias see-cloud-config="sudo cat /var/lib/coreos-install/user_data"
alias ecc="edit-cloud-config"
alias eccc="edit-cloud-config-config"
alias ucc="update-cloud-config && sudo reboot"
alias scc="see-cloud-config"


# SYSTEM JOURNAL
# ==============
function jo() {
  journalctl --unit=$@
}

alias jcc="journalctl -b --no-pager -u \"user-cloudinit@var-lib-coreos\x2dinstall-user_data.service\""

alias e_last_log="sudo journalctl -f -t etcd2"
