# NixOS-LiveCD-CN

这是一个基于 [NixOS Gnome 安装镜像](https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix) 的自定义 Live CD 镜像项目，并为中国用户优化配置。

## 镜像特点
   - 中文本地化
   - 集成 Clash Verge Rev 代理客户端
   - 支持 GPG 智能卡
   - 启用 Nix Flakes 支持

## 使用方法
[使用方法](./INSTALL.md)

## 自主构建
### 前置要求
- 启用了 nix flakes 功能
- 配置了[ direnv ](https://github.com/nix-community/nix-direnv) 或使用 `nix develop` 命令进入开发环境
### 构建 ISO 镜像
```bash
# 启用 direnv
direnv allow
# 构建
just build
```

构建完成后，ISO 镜像文件将位于 `result/iso/` 目录下。

# 许可证

我是以下免责声明的每个文件的作者：
```bash
# @author zjm54321
```

我根据 [GNU GPL-3.0](./LICENSE) 许可证对它们进行许可。在适用法律允许的范围内，不提供任何保证。

一些脚本或配置文件来自其他人，应该标注对相应作者的致谢。

# 贡献

欢迎提交 Issue 和 Pull Request 来改进这个配置！

# 联系方式

- GitHub: [@zjm54321](https://github.com/zjm54321)
- Codeberg: [@zjm54321](https://codeberg.org/zjm54321)