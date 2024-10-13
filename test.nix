# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:
let
  unstableTarball =
    fetchTarball
      https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz;

in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nixpkgs.config = {
    packageOverrides = pkgs: with pkgs; {
      unstable = import unstableTarball {
        config = config.nixpkgs.config;
      };
    };
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "BRIX0001";
  networking.networkmanager.enable = true;

  time.timeZone = "UTC";

  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.enable = false;
  hardware.pulseaudio.enable = false;
  services.libinput.enable = false;

  services.logind.extraConfig = ''
    # don’t shutdown when power button is short-pressed
    HandlePowerKey=ignore
  '';

  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };

  virtualisation.podman.enable = true;

  users.users.richardsl = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    packages = with pkgs; [
      pkgs.unstable.chezmoi
    ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys  = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDB7n7NyXkm6OucNqS9ExJPUJk/+jhcIxTJD3RnEt2IywDvHWUOBBEcfpOxprj54UsJDrfAslIvhFZkjEi+3Tgow1qC7+HVS3GfNu1YCP+MmTOnnEXgAhtaM7LTVFgt9QYEZeSpgrIIaKSlb515ln4Ghy+Jehbs06V6TcJYG/qIQd1RXN40O13VEyXmNAVRSf9ra7Emfg1OLzu7wabhxLqeLGBJ2cf0QKf0+ip+jYqbq/D2ZsCBYmGgQcKiopuCW7a51zzu/Df6G+SJS2yzWwZx1PjJ0yqUFWpuVDlRJi2sBbBTL1TUftMzRiZsyQPrS/eAlGLxzGjmvjzZ3pLZtD5xc6Qs7By/r/5Acxbp+2wn3fuo6lVmD5P54R0PsQyw7jrV7C7Zb7Cl7EuXZqW3Pm42aowq4skstTmdXsZZx0RkFvFaxDw5IFtC78E5Dwy/4pECLNXQ8stc6A5MKElGwHhcABK8IdUGf6R0lU4yEzknb7KhvERZRKEslQh3Jcn+7zScc5WBbjT3SMEdySWPMwreOpe1gnt+6MSf/8lpQCyBOP1Mr4/SSa95pJpWyRr1OSPi0KgOvSTVwppG6thcV1fRpGsDtpPB192KKrzInP3fxF0UOT3PhLgn7zZAlyGBAIel4m/zK0tqjL3kG2CNwnOkMrq5CTdK1JS7KnK4a/rxCw==" ];
    hashedPassword = ""
  };

  users.users.podtest = {
    isNormalUser = true;
    shell = pkgs.zsh;
    linger = true;
  };

  environment.systemPackages = with pkgs; [
    pkgs.unstable.neovim
    pkgs.unstable.oh-my-posh
    pkgs.wget
    pkgs.bat
    pkgs.zsh
    pkgs.tmux
    pkgs.fzf
    pkgs.zsh-syntax-highlighting
    pkgs.zsh-autosuggestions
    pkgs.unzip
    pkgs.gnupg
    pkgs.lsb-release
    pkgs.gitMinimal
    pkgs.gcc
    pkgs.gnumake
    pkgs.yarn
  ];

  environment.etc."systemd/user-generators/podman-user-generator" = {
    source = "${pkgs.podman}/lib/systemd/user-generators/podman-user-generator";
    target = "systemd/user-generators/podman-user-generator";
  };

  services.openssh.enable = true;

  networking.firewall.allowedTCPPorts = [ 22 80 443 ];
  #networking.firewall.allowedUDPPorts = [ ... ];

  system.copySystemConfiguration = true;
  system.autoUpgrade.enable = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?
}


