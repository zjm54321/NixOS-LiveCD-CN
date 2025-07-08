set shell := ["bash", "-c"]

# 列出所有 just 命令
default:
    @just --list

# 构建镜像
build:
  nix build path:$PWD