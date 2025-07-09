(
  {
    lib,
    pkgs,
    modulesPath,
    ...
  }:
  {
    # 使用 NixOS Gnome 安装 ISO 镜像做为底本
    imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-graphical-gnome.nix") ];
    environment.systemPackages = with pkgs; [
      git
      wget

      kdePackages.kleopatra # GPG 图形界面
      pcsc-tools
    ];

    # 系统基本设置
    users.users."nixos".initialPassword = "nix";
    users.users."nixos".initialHashedPassword = lib.mkForce null;

    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [ "nixos" ];
      substituters = [
        "https://mirrors.ustc.edu.cn/nix-channels/store"
        "https://cache.nixos.org"
      ];
      trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
      builders-use-substitutes = true;
    };

    # Gnome 配置
    services.xserver.desktopManager.gnome = {
      favoriteAppsOverride = ''
        [org.gnome.shell]
        favorite-apps=['nixos-manual.desktop','org.gnome.Console.desktop','firefox.desktop','org.gnome.Nautilus.desktop','clash-verge.desktop','org.kde.kleopatra.desktop','gparted.desktop']
      '';
      # 覆盖 GNOME 默认设置以禁用 GNOME 导览和禁用挂起
      extraGSettingsOverrides = ''
        [org.gnome.shell]
        welcome-dialog-last-shown-version='9999999999'
        [org.gnome.desktop.session]
        idle-delay=0
        [org.gnome.settings-daemon.plugins.power]
        sleep-inactive-ac-type='nothing'
        sleep-inactive-battery-type='nothing'
      '';
      extraGSettingsOverridePackages = [ pkgs.gnome-settings-daemon ];
    };
    environment.gnome.excludePackages = (
      with pkgs;
      [
        geary
        gnome-contacts
        gnome-weather
        gnome-maps
        gnome-music
        simple-scan
        totem
        snapshot
        decibels
        gnome-tour
        gnome-calendar
        epiphany
      ]
    );

    # 中文环境配置
    time.timeZone = "Asia/Shanghai";
    i18n.defaultLocale = "zh_CN.UTF-8";
    fonts = {
      enableDefaultPackages = false;
      fontDir.enable = true;
      packages = with pkgs; [
        noto-fonts-emoji
        source-han-sans
        source-han-serif
        maple-mono.NF-CN
      ];
      fontconfig.defaultFonts = {
        serif = [
          "Source Han Serif SC"
          "Source Han Serif TC"
          "Noto Color Emoji"
        ];
        sansSerif = [
          "Source Han Sans SC"
          "Source Han Sans TC"
          "Noto Color Emoji"
        ];
        monospace = [
          "Maple Mono NF CN"
          "Noto Color Emoji"
        ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        addons = with pkgs; [
          fcitx5-chinese-addons
          fcitx5-configtool
          fcitx5-gtk
        ];
      };
    };

    # 代理配置
    programs.clash-verge = {
      enable = true;
      package = pkgs.clash-verge-rev;
    };
    services.mihomo.tunMode = true;
    networking.firewall.enable = false; # 禁用防火墙以避免代理问题

    # GnuPG 配置
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = pkgs.pinentry-gnome3;
      settings = {
        default-cache-ttl = 3600;
        max-cache-ttl = 86400;
      };
    };
    hardware.gpgSmartcards.enable = true;
    services.pcscd.enable = true;
    services.udev.packages = with pkgs; [
      yubikey-personalization
      libu2f-host
    ];
    environment.etc."gnupg/scdaemon.conf".text = ''disable-ccid'';

    # SSH 配置
    services.openssh.knownHosts = {
      # https://docs.github.com/zh/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints
      "github/ed25519" = {
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
        hostNames = [ "github.com" ];
      };
      "github/sha2" = {
        publicKey = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=";
        hostNames = [ "github.com" ];
      };
      "github/rsa" = {
        publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=";
        hostNames = [ "github.com" ];
      };
      # https://codeberg.org/Codeberg/org/src/branch/main/Imprint.md#user-content-ssh-fingerprints
      "codeberg/ecdsa" = {
        publicKey = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBL2pDxWr18SoiDJCGZ5LmxPygTlPu+cCKSkpqkvCyQzl5xmIMeKNdfdBpfbCGDPoZQghePzFZkKJNR/v9Win3Sc=";
        hostNames = [ "codeberg.org" ];
      };
      "codeberg/rsa" = {
        publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8hZi7K1/2E2uBX8gwPRJAHvRAob+3Sn+y2hxiEhN0buv1igjYFTgFO2qQD8vLfU/HT/P/rqvEeTvaDfY1y/vcvQ8+YuUYyTwE2UaVU5aJv89y6PEZBYycaJCPdGIfZlLMmjilh/Sk8IWSEK6dQr+g686lu5cSWrFW60ixWpHpEVB26eRWin3lKYWSQGMwwKv4LwmW3ouqqs4Z4vsqRFqXJ/eCi3yhpT+nOjljXvZKiYTpYajqUC48IHAxTWugrKe1vXWOPxVXXMQEPsaIRc2hpK+v1LmfB7GnEGvF1UAKnEZbUuiD9PBEeD5a1MZQIzcoPWCrTxipEpuXQ5Tni4mN";
        hostNames = [ "codeberg.org" ];
      };
      "codeberg/ed25519" = {
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIVIC02vnjFyL+I4RHfvIGNtOgJMe769VTF1VR4EB3ZB";
        hostNames = [ "codeberg.org" ];
      };
      # https://help.gitee.com/account/gitees-ssh-key-fingerprints
      "gitee/ed25519" = {
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEKxHSJ7084RmkJ4YdEi5tngynE8aZe2uEoVVsB/OvYN";
        hostNames = [ "gitee.com" ];
      };
      "gitee/ecdsa" = {
        publicKey = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBMuEoYdx6to5oxR60IWj8uoe1aI0XfKOHWOtLqTg1tsLT1iFwXV5JmFjU46EzeMBV/6EmI1uaRI6HiEPtPtJHE=";
        hostNames = [ "gitee.com" ];
      };
      "gitee/rsa" = {
        publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDMzG3r+88lWSDK9fyjcZmYsWGDBDmGoAasKMAmjoFloGt9HRQX2Qp4f9FY2XK/hsHYinvoh5Xytl9iaUNUWMfYR8q6VEMtOO87DgoAFcfKZHt0/nbAg9RoNTKYt6v8tPwYpr7N0JP/01nE4LFsNDnstr6H0bXSAzbKWCETLZfdPV4l2uSpRn3bU0ugoZ0aSKz5Dc/IloBfGCTvkSsxUydMRd/Chpjt6VxncDbp+Fa6pzsseK8OQzrg6Fgc5783EN3EQqZ2skqyCwExtx95BJlfx1B3luZnWfpkwNDnrZRT/Qx0OrWqyf0q6f9uQr+UG1S8qDcUn3e/9onq3rwBri8/";
        hostNames = [ "gitee.com" ];
      };
    };
  }
)
