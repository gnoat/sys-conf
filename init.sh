#!/bin/bash

# read OS to setup
if [[ "$(uname)" == *"Darwin"* ]]; then
    os="MACOS"
else
    os="UBUNTU"
fi

if [[ "" == "$1" ]]; then
    python=true
    rust=true
    node=true
    neovim=true
    kitty=true
    nushell=true
    terraform=true
    sys=true
    go=true
else
    python=false
    rust=false
    node=false
    neovim=false
    kitty=false
    nushell=false
    terraform=false
    sys=false
    go=false
    if [[ "python" == *"$1"* ]]; then
        python=true
    fi
    if [[ "rust" == *"$1"* ]]; then
        rust=true
    fi
    if [[ "node" == *"$1"* ]]; then
        node=true
    fi
    if [[ "neovim" == *"$1"* ]]; then
        neovim=true
    fi
    if [[ "kitty" == *"$1"* ]]; then
        kitty=true
    fi
    if [[ "nushell" == *"$1"* ]]; then
        nushell=true
    fi
    if [[ "terraform" == *"$1"* ]]; then
        terraform=true
    fi
    if [[ "sys" == *"$1"* ]]; then
        sys=true
    fi
    if [[ "go" == *"$1" ]]; then
        go=true
    fi
fi

# if [[]]; then
#     if [[ "$os" == "MACOS" ]]; then
# 
#     elif [[ "$os" == "UBUNTU" ]]; then
# 
#     fi
# fi

# read system dependencies
if [[ neovim ]]; then
    if [[ "$os" == "MACOS" ]]; then
        brew install neovim
    elif [[ "$os" == "UBUNTU" ]]; then
        apt install neovim
    fi
    sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    cp ~/.config/nvim/init.vim ~/.config/nvim/temp_init.vim
    sed '/call plug#end/q' ~/.config/nvim/temp_init.vim > ~/.config/nvim/init.vim
    nvim -c 'PlugInstall' -c 'qa'
    nvim -c 'TSInstall go' -c 'qa'
    nvim -c 'TSInstall bash' -c 'qa'
    nvim -c 'TSInstall scala' -c 'qa'
    cp ~/.config/nvim/temp_init.vim ~/.config/nvim/init.vim
    rm -rf ~/.config/nvim/temp_init.vim
    echo $(nvim --version)
fi


if [[ python ]]; then
    if [[ "$os" == "MACOS" ]]; then
        brew install python@3.11
    elif [[ "$os" == "UBUNTU" ]]; then
        apt install software-properties-common
        add-apt-repository ppa:deadsnakes/ppa
        apt update
        apt install python3.11
    fi
    python3 -m venv venv
    . ./venv/bin/activate
    pip install wheel
    pip install pynvim
    pip install doq
    pip install black
    deactivate
    nvim -c 'TSInstall python' -c 'qa'
    echo $(python3.11 --version)
fi

if [[ rust ]]; then
    if [[ "$os" == "MACOS" ]]; then
        brew install rustup
        rustup-init
    elif [[ "$os" == "UBUNTU" ]]; then
        curl https://sh.rustup.rs -sSf | sh
        source $HOME/.cargo/env
    fi
    nvim -c 'TSInstall rust' -c 'qa'
    rustup component add rust-analyzer
    ln -s "$(rustup which rust-analyzer)" ~/.cargo/bin/rust-analyzer
    echo $(rustc --version)
fi

if [[ node ]]; then
    if [[ "$os" == "MACOS" ]]; then
        brew install node
    elif [[ "$os" == "UBUNTU" ]]; then
        apt install nodejs
        apt install npm
    fi
    npm i -g pyright
    echo $(node -v)
    echo $(npm -v)
fi

if [[ go ]]; then
    if [[ "$os" == "MACOS" ]]; then
        brew install go
    elif [[ "$os" == "UBUNTU" ]]; then
        sudo add-apt-repository ppa:longsleep/golang-backports
        sudo apt update
        sudo apt install golang-go
    fi
    echo $(go version)
fi


if [[ kitty ]]; then
    if [[ "$os" == "MACOS" ]]; then
        brew install --cask kitty
    elif [[ "$os" == "UBUNTU" ]]; then
        curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
        ln -s ~/.local/kitty.app/bin/kitty ~/.local/bin/
    fi
    echo $(kitty --version)
fi

if [[ nushell ]]; then
    if [[ "$os" == "MACOS" ]]; then
        brew install nushell
    elif [[ "$os" == "UBUNTU" ]]; then
        sudo apt install pkg-config libssl-dev
        cargo install nu
        cargo install nu --features=extra
    fi
    echo "echo \$nu.config-path" > cconf
    echo "echo \$nu.env-path" > econf
    if [[ "$(nu econf)" == *"/.config/nushell/env.nu" ]]; then
        ln -sf "$(nu econf)" ~/.config/nushell/env.nu
    fi
    if [[ "$(nu cconf)" == *"/.config/nushell/config.nu" ]]; then
        ln -sf "$(nu cconf)" ~/.config/nushell/config.nu
    fi
    echo $(ls ~/.config/nushell)
    echo $(nu --version)
fi

if [[ terraform ]]; then
    if [[ "$os" == "MACOS" ]]; then
        brew install terraform
        brew install hashicorp/tap/terraform-ls
        brew install tflint
    elif [[ "$os" == "UBUNTU" ]]; then
    sudo apt install gpg
    wget -O- https://apt.releases.hashicorp.com/gpg | \
        gpg --dearmor | \
        sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
    gpg --no-default-keyring \
        --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
        --fingerprint
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
        https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
        sudo tee /etc/apt/sources.list.d/hashicorp.list
    apt update
    curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
    apt install terraform
    sudo apt install terraform-ls
    fi
    nvim -c 'TSInstall hcl' -c 'qa'
fi

if [[ "$sys" == true ]]; then
    if [[ "$os" == "MACOS" ]]; then
        cat ./sys/bashrc.sh >> ~/.zshrc
    elif [[ "$os" == "UBUNTU" ]]; then
        cat ./sys/bashrc.sh >> ~/.bashrc
    fi
    if [[ "$nushell" == true ]]; then
        cat ./sys/nuconf.nu >> ~/.config/nushell/env.nu
    fi
fi


