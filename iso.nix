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
    services.desktopManager.gnome = {
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

  }
)
