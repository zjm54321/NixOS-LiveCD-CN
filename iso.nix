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
    system.activationScripts.setup-gpg-config = ''
            mkdir -p /home/nixos/.gnupg
            cat > /home/nixos/.gnupg/scdaemon.conf << 'EOF'
      disable-ccid
      EOF
            chown -R nixos:users /home/nixos/.gnupg
            chmod 700 /home/nixos/.gnupg
            chmod 600 /home/nixos/.gnupg/scdaemon.conf

            cat >> /home/nixos/.bashrc << 'EOF'
      export GPG_TTY=$(tty)
      export SSH_AUTH_SOCK="$(${pkgs.gnupg}/bin/gpgconf --list-dirs agent-ssh-socket)"
      EOF
            chown nixos:users /home/nixos/.bashrc
    '';
  }
)
