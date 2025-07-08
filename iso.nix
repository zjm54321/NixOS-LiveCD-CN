(
  {
    modulesPath,
    ...
  }:
  {
    imports = [
      # 使用 NixOS Gnome 安装 ISO 镜像做为底本
      (modulesPath + "/installer/cd-dvd/installation-cd-graphical-gnome.nix")
    ];
  }
)
