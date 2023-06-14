{ config, pkgs, inputs, ... }:

let
  _1pass_config = {
    groupId = 5000;
  };
  screengrab = pkgs.writeScriptBin "screengrab" (
    import ./screengrab.nix {
      inherit (pkgs) imagemagick xclip;
    }
  );
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./nixos-framework-hardware-config.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.kernelPackages = pkgs.linuxPackages_latest;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Enable fingerprint reader
  services.fprintd.enable = true;
  services.dbus.enable = true;
  services.dbus.packages = with pkgs; [ pass-secret-service ];

  # Set udev rules for Corsair HS80
  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1b1c", ATTRS{idProduct}=="0a6b", TAG+="uaccess"
  '';

  # Enable thunderbolt support
  services.hardware.bolt.enable = true;

  # Disable mouse acceleration
  services.xserver.libinput = {
    enable = true;
    touchpad.tapping = false;

    mouse.accelProfile = "flat";
  };

  networking.hostName = "nixos-framework"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };
  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  # Enable the GNOME Desktop Environment.
  services.xserver = {
    displayManager = {
      defaultSession = "none+i3";
    };
    desktopManager = {
      xterm.enable = false;
    };

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        rofi
        i3lock
        polybar
      ];
    };
  };
  services.gnome.gnome-keyring.enable = true;

  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
    ipafont
    kochi-substitute
  ];

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable bluetooth
  hardware.bluetooth = {
    enable = true;
    settings.General.Enable = "Source,Sink,Media,Socket";
  };
  services.blueman.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  programs.fish.enable = true;
  programs.gnupg.agent.enable = true;
  programs.gnupg.agent.pinentryFlavor = "gnome3";
  programs.tmux = {
    enable = true;
    terminal = "xterm-256color";
    extraConfig = ''
      set-option -g escape-time 0
      set-option -ga terminal-overrides ",*256col*:Tc:RGB"
    '';
  };
  programs.dconf.enable = true;
  services.pcscd.enable = true;

  # Enable docker
  virtualisation.docker.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.patrick = {
    isNormalUser = true;
    description = "Patrick Cleavelin";
    extraGroups = [ "networkmanager" "wheel" "docker" "onepassword" ];
    shell = pkgs.fish;
    packages = with pkgs; [
      alacritty
      kitty
      brave
      slack
      ripcord
      yadm
      xclip
      git
      deno
      bat
      sublime-merge-dev
      postman
      dbeaver
      jetbrains.datagrip
      docker-credential-helpers
      pass
      remmina
      nitrogen
      # jetbrains.clion
      # inputs.jetbrains-toolbox.packages.x86_64-linux.default
      # inputs.lapce.packages.x86_64-linux.default
      # inputs.ultorg.packages.x86_64-linux.default
    ];
  };
  users.users.nixosvmtest.isSystemUser = true;
  users.users.nixosvmtest.initialPassword = "test";
  users.users.nixosvmtest.group = "nixosvmtest";
  users.groups.nixosvmtest = {};


  # Allow Wayland support for Slack (to make screen sharing work properly)
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  xdg.portal.wlr.enable = true;
  # xdg.portal = {
  #   enable = true;
  #   extraPortals = with pkgs; [
  #     xdg-desktop-portal-wlr
  #     xdg-desktop-portal-gtk
  #   ];
  #   gtkUsePortal = true;
  # };

  # users.groups.onepassword.gid = _1pass_config.groupId;

  # Setup polkit users for 1Password
  security.pam.services.gdm.enableGnomeKeyring = true;
  security.polkit.enable = true;
  programs._1password-gui = {
    enable = true;
    # gid = _1pass_config.groupId;
    # package = (pkgs._1password-gui.override ({ polkitPolicyOwners = [ "patrick" ]; }));
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
    neovim
    neovide
    ripgrep
    curl
    unzip
    fd
    htop
    zoom-us
    networkmanagerapplet
    dunst
    picom
    screengrab
    lxappearance
    xfce.thunar
    killall
    pavucontrol
  ];
  environment.pathsToLink = [ "/libexec" ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 8080 8100 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}
