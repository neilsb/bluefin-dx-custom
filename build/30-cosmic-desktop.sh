#!/usr/bin/bash

set -eoux pipefail

###############################################################################
# Install COSMIC Desktop (System76) on base-main
###############################################################################
# This script installs COSMIC from the System76 COPR repository.
# Base image is ghcr.io/ublue-os/base-main:latest (no desktop included).
###############################################################################

# Source helper functions
# shellcheck source=/dev/null
source /ctx/build/copr-helpers.sh

echo "::group:: Install COSMIC Desktop"

# Install COSMIC desktop from System76's COPR
# Using isolated pattern to prevent COPR from persisting
copr_install_isolated "ryanabx/cosmic-epoch" \
    cosmic-session \
    cosmic-greeter \
    cosmic-comp \
    cosmic-panel \
    cosmic-launcher \
    cosmic-applets \
    cosmic-settings \
    cosmic-files \
    cosmic-edit \
    cosmic-term \
    cosmic-workspaces \
    xdg-desktop-portal-cosmic

echo "COSMIC desktop installed successfully"
echo "::endgroup::"

echo "::group:: Configure Display Manager"

# Enable cosmic-greeter (COSMIC's display manager)
systemctl enable cosmic-greeter

echo "Display manager configured"
echo "::endgroup::"

echo "COSMIC desktop installation complete!"
