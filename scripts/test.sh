#!/bin/zsh
# シミュレータでユニットテストを実行する。
# テストが失敗したとき xcodebuild が終了しないことがあるため、300 秒で強制終了する。
# 使い方: scripts/test.sh [シミュレータ名]   （既定: iPhone 17）
cd "$(dirname "$0")/.." || exit 1
DEVICE="${1:-iPhone 17}"
perl -e 'alarm 300; exec @ARGV' xcodebuild test -scheme CoffeeLog \
  -destination "platform=iOS Simulator,name=${DEVICE}" 2>&1 \
  | grep -E "error:|✔ Test |✘ Test|TEST (SUCCEEDED|FAILED)" | grep -v "Test run"
