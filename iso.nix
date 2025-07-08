(
  {
    pkgs,
    modulesPath,
    ...
  }:
  {
    # 使用 NixOS Gnome 安装 ISO 镜像做为底本
    imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-graphical-gnome.nix") ];

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
  }
)
