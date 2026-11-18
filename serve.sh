#!/bin/sh
# 一键：本地静态服务 + 公网隧道
# 用法： sh serve.sh     （终端会打印一个 https://xxx.trycloudflare.com 地址）
cd "$(dirname "$0")" || exit 1
CF="../bin/cloudflared"
[ -x "$CF" ] || CF="/tmp/cloudflared"

# 关掉可能残留的 8765 服务
pkill -f "http.server 8765" 2>/dev/null
sleep 0.5

nohup python3 -m http.server 8765 --bind 0.0.0.0 >/tmp/gym-http.log 2>&1 &
sleep 1

if [ ! -x "$CF" ]; then
  echo "本地服务已开：http://127.0.0.1:8765/index.html"
  echo "没找到 cloudflared，无法开公网隧道"
  exit 0
fi

echo "本地：http://127.0.0.1:8765/index.html"
echo "正在开公网隧道，等下面出现 https://...trycloudflare.com 就是公网地址"
exec "$CF" tunnel --url http://127.0.0.1:8765 --no-autoupdate --metrics 127.0.0.1:39236
