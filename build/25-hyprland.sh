#!/usr/bin/bash

set -eoux pipefail

###############################################################################
# Install Hyprland and Waybar
###############################################################################
# This script installs Hyprland (dynamic tiling Wayland compositor) and
# related utilities. Hyprland can be used alongside GNOME/COSMIC as an
# alternative window manager/compositor.
###############################################################################

# Source helper functions (includes logging utilities)
# shellcheck source=build/copr-helpers.sh
# shellcheck disable=SC1091
if [[ -f /ctx/build/copr-helpers.sh ]]; then
    source /ctx/build/copr-helpers.sh
elif [[ -f "$(dirname "$0")/copr-helpers.sh" ]]; then
    source "$(dirname "$0")/copr-helpers.sh"
else
    echo "copr-helpers.sh not found in /ctx/build or script directory" >&2
    exit 1
fi

log_section "Installing Hyprland and Waybar"
log_info "Hyprland is a dynamic tiling Wayland compositor"

###############################################################################
# Install Waybar and Fonts (from standard repos)
###############################################################################

echo "::group:: Install Waybar and Fonts"
log_step "Installing Waybar and Font Awesome from standard repositories..."

# Install waybar and fontawesome fonts from Fedora repos
dnf5 install -y waybar fontawesome-fonts-all

# Verify installation
verify_package "waybar"
verify_package "fontawesome-fonts-all"

log_success "Waybar and fonts installed successfully"
echo "::endgroup::"

###############################################################################
# Install Hyprland Packages (from COPR)
###############################################################################

echo "::group:: Install Hyprland from COPR"

# Define Hyprland packages to install
HYPRLAND_PACKAGES=(
    xdg-desktop-portal-hyprland
    hyprland
    cliphist
    eww-git
    hypridle
    hyprlock
    hyprshot
    waypaper
)

log_step "Installing Hyprland packages from COPR solopasha/hyprland..."
log_info "Packages to install: ${HYPRLAND_PACKAGES[*]}"

# Install Hyprland and related packages from COPR
# Using isolated pattern to prevent COPR from persisting
copr_install_isolated "solopasha/hyprland" "${HYPRLAND_PACKAGES[@]}"

echo "::endgroup::"

###############################################################################
# Verify Installation
###############################################################################

echo "::group:: Verify Hyprland Installation"
log_step "Verifying Hyprland package installation..."

# Verify all installed Hyprland packages
verification_failed=0
for pkg in "${HYPRLAND_PACKAGES[@]}"; do
    if ! verify_package "$pkg"; then
        verification_failed=1
    fi
done

if [[ $verification_failed -eq 1 ]]; then
    log_error "Some Hyprland packages failed verification!"
    exit 1
fi

log_success "All Hyprland packages verified successfully"
echo "::endgroup::"

###############################################################################
# Configure Hyprland Session
###############################################################################

echo "::group:: Verify Hyprland Session"
log_step "Verifying Hyprland session configuration..."

# Verify Hyprland session file exists
if [[ -f /usr/share/wayland-sessions/hyprland.desktop ]]; then
    log_success "Hyprland session registered: /usr/share/wayland-sessions/hyprland.desktop"
else
    log_warn "Hyprland session file not found at expected location"
    log_info "Checking alternative locations..."
    find /usr/share -name "hyprland*.desktop" 2>/dev/null | while read -r session_file; do
        log_info "Found session file: $session_file"
    done
fi

# List available sessions
log_info "Available desktop sessions:"
if [[ -d /usr/share/wayland-sessions ]]; then
    for session in /usr/share/wayland-sessions/*.desktop; do
        if [[ -f "$session" ]]; then
            session_name=$(grep -E "^Name=" "$session" 2>/dev/null | cut -d= -f2 || basename "$session")
            log_info "  - $session_name ($(basename "$session"))"
        fi
    done
fi

echo "::endgroup::"

###############################################################################
# Summary
###############################################################################

log_section "Hyprland Installation Complete"
log_success "Hyprland and Waybar installed successfully"
log_info ""
log_info "Installed components:"
log_info "  - Hyprland: Dynamic tiling Wayland compositor"
log_info "  - Waybar: Highly customizable status bar"
log_info "  - Font Awesome: Icon fonts for status bar"
log_info "  - xdg-desktop-portal-hyprland: Screen sharing support"
log_info "  - hypridle: Idle daemon"
log_info "  - hyprlock: Screen locker"
log_info "  - hyprshot: Screenshot utility"
log_info "  - cliphist: Clipboard manager"
log_info "  - eww-git: Widget system"
log_info "  - waypaper: Wallpaper manager"
log_info ""
log_info "To use Hyprland:"
log_info "  1. At the GDM login screen, click the gear icon (⚙️)"
log_info "  2. Select 'Hyprland' session"
log_info "  3. Enter your password to log in"
log_info ""
log_info "Configuration files location: ~/.config/hypr/"
