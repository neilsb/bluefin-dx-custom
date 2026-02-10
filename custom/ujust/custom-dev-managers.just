# vim: set ft=make :
################################
### custom-dev-managers.just
################################
## Install and configure NVM and SDKMAN

# Install NVM (Node Version Manager)
[group('Dev Managers')]
install-nvm:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Installing NVM (Node Version Manager)"
    if [ -d "$HOME/.nvm" ]; then
        echo "NVM already installed at $HOME/.nvm"
    else
        mkdir -p "$HOME/.nvm"
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
        echo "NVM installation complete."
    fi

    echo ""
    echo "Add to ~/.zshrc:"
    echo "  export NVM_DIR=\"$HOME/.nvm\""
    echo "  [ -s \"$NVM_DIR/nvm.sh\" ] && . \"$NVM_DIR/nvm.sh\""
    echo "  [ -s \"$NVM_DIR/bash_completion\" ] && . \"$NVM_DIR/bash_completion\""
    echo ""
    echo "Reload: source ~/.zshrc"

# Install SDKMAN (SDK Manager)
[group('Dev Managers')]
install-sdkman:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Installing SDKMAN (SDK Manager)"
    if [ -d "$HOME/.sdkman" ]; then
        echo "SDKMAN already installed at $HOME/.sdkman"
    else
        curl -s "https://get.sdkman.io" | bash
        echo "SDKMAN installation complete."
    fi

    echo ""
    echo "Add to ~/.zshrc:"
    echo "  source \"$HOME/.sdkman/bin/sdkman-init.sh\""
    echo ""
    echo "Reload: source ~/.zshrc"

# Alias: install both NVM and SDKMAN
[group('Dev Managers')]
install-dev-managers:
    @ujust install-nvm
    @ujust install-sdkman
