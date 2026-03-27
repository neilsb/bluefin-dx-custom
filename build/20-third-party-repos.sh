#!/usr/bin/bash

set -eoux pipefail

###############################################################################
# Install VSCode Insiders from Official Repository
###############################################################################
# Conventions:
# - Use dnf5 exclusively
# - Always use -y for non-interactive installs
# - Remove repo files after installation (repos don't work at runtime)
###############################################################################

# Source helper functions (includes logging utilities)
# shellcheck source=/dev/null
source /ctx/build/copr-helpers.sh

log_section "Installing Third-Party Software"

###############################################################################
# VSCode Insiders
###############################################################################

echo "::group:: Install VSCode Insiders"
log_step "Installing Visual Studio Code Insiders..."

log_info "Adding Microsoft VSCode repository..."
cat > /etc/yum.repos.d/vscode.repo << 'EOF'
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

log_info "Importing Microsoft GPG key..."
rpm --import https://packages.microsoft.com/keys/microsoft.asc

log_info "Installing code-insiders package..."
dnf5 install -y code-insiders

# Verify installation
verify_package "code-insiders"

log_info "Cleaning up Microsoft repository file..."
rm -f /etc/yum.repos.d/vscode.repo

log_success "VSCode Insiders installation complete"
echo "::endgroup::"

###############################################################################
# Noctalia Shell
###############################################################################

echo "::group:: Install Noctalia Shell"
log_step "Installing Noctalia Shell from Terra repository..."

log_info "Noctalia is a modern shell environment from Fyra Labs"

log_info "Installing Terra repository..."
# Install Terra repo using the special command from their docs
# Note: Using --nogpgcheck for initial repo setup as per Fyra Labs instructions
dnf5 install -y --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release

log_info "Installing noctalia-shell package..."
dnf5 install -y noctalia-shell

# Verify installation
verify_package "noctalia-shell"

log_info "Cleaning up Terra repository files..."
# Remove repo files since they won't work at runtime
rm -f /etc/yum.repos.d/terra*.repo

log_success "Noctalia Shell installation complete"
echo "::endgroup::"

###############################################################################
# Ghostty Terminal
###############################################################################

echo "::group:: Install Ghostty Terminal"
log_step "Installing Ghostty Terminal from COPR..."

log_info "Ghostty is a modern, fast, feature-rich terminal emulator"

log_info "Enabling scottames/ghostty COPR repository..."
dnf5 -y copr enable scottames/ghostty

log_info "Downloading ghostty package..."
dnf5 download -y ghostty

log_info "Installing Ghostty runtime dependencies..."
dnf5 install -y gtk4-layer-shell

log_info "Installing ghostty with --replacefiles to handle terminfo conflicts..."
# Use rpm directly with --replacefiles to replace the conflicting terminfo file
# Only install the binary RPM (x86_64), not the source RPM
rpm -ivh --replacefiles ghostty-*x86_64.rpm

# Verify installation
verify_package "ghostty"

log_info "Cleaning up downloaded RPM..."
rm -f ghostty-*.rpm

log_info "Disabling COPR repository..."
dnf5 -y copr disable scottames/ghostty

log_success "Ghostty Terminal installation complete"
echo "::endgroup::"

###############################################################################
# MongoDB Shell (mongosh)
###############################################################################

echo "::group:: Install MongoDB Shell"
log_step "Installing MongoDB Shell from MongoDB repository..."

log_info "Adding MongoDB repository..."
cat > /etc/yum.repos.d/mongodb-org.repo << 'EOF'
[mongodb-org]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/9/mongodb-org/8.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://pgp.mongodb.com/server-8.0.asc
EOF

log_info "Importing MongoDB GPG key..."
rpm --import https://pgp.mongodb.com/server-8.0.asc

log_info "Installing mongodb-mongosh-shared-openssl3 package..."
dnf5 install -y mongodb-mongosh-shared-openssl3

# Verify installation
verify_package "mongodb-mongosh-shared-openssl3"

log_info "Cleaning up MongoDB repository file..."
rm -f /etc/yum.repos.d/mongodb-org.repo

log_success "MongoDB Shell installation complete"
echo "::endgroup::"

###############################################################################
# Vivaldi Browser (Stable)
###############################################################################

echo "::group:: Install Vivaldi Browser"
log_step "Installing Vivaldi Browser (stable) from official repository..."

log_info "Adding Vivaldi repository..."
cat > /etc/yum.repos.d/vivaldi.repo << 'EOF'
[vivaldi]
name=vivaldi
baseurl=https://repo.vivaldi.com/archive/rpm/x86_64
enabled=1
gpgcheck=1
gpgkey=https://repo.vivaldi.com/archive/linux_signing_key.pub
EOF

log_info "Importing Vivaldi GPG key..."
rpm --import https://repo.vivaldi.com/archive/linux_signing_key.pub

log_info "Installing vivaldi-stable package..."
dnf5 install -y vivaldi-stable

# Verify installation
verify_package "vivaldi-stable"

log_info "Cleaning up Vivaldi repository file..."
rm -f /etc/yum.repos.d/vivaldi.repo

log_success "Vivaldi Browser installation complete"
echo "::endgroup::"

log_section "Third-Party Software Installation Complete"
log_success "All third-party applications installed successfully"
