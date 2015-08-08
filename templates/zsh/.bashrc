# /etc/skel/.bashrc

# ================== from CoreOS ===================
# ==================================================
if [[ $- != *i* ]] ; then
        # Shell is non-interactive.  Be done now!
        return
fi


# ============= from duffqiu@gmail.co ==============
# ==================================================
# http://duffqiu.github.io/blog/2015/07/09/install-zsh-coreos/

export PATH=$PATH:/home/core/zsh/bin/
export LD_LIBRARY_PATH=/home/core/zsh/lib64/

# launch zsh
zsh
