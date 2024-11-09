#!/usr/bin/env bash

# set -x # 実行したコマンドと引数も出力する
set -e # スクリプト内のコマンドが失敗したとき（終了ステータスが0以外）にスクリプトを直ちに終了する
set -E # '-e'オプションと組み合わせて使用し、サブシェルや関数内でエラーが発生した場合もスクリプトの実行を終了する
set -u # 未定義の変数を参照しようとしたときにエラーメッセージを表示してスクリプトを終了する
set -o pipefail # パイプラインの左辺のコマンドが失敗したときに右辺を実行せずスクリプトを終了する
shopt -s inherit_errexit # '-e'オプションをサブシェルや関数内にも適用する

# Bash バージョン 4.4 以上の場合のみ実行
if [[ ${BASH_VERSINFO[0]} -ge 4 && ${BASH_VERSINFO[1]} -ge 4 ]]; then
    shopt -s inherit_errexit # '-e'オプションをサブシェルや関数内にも適用する
fi

# 初期のカレントディレクトリを保存
initial_dir_path=$(pwd)

# スクリプト終了時に初期のカレントディレクトリに戻るよう設定
trap 'cd "${initial_dir_path}"' EXIT

# このスクリプトがあるフォルダへのパス
script_dir_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# このスクリプトがあるフォルダにカレントディレクトリを設定
# cd "${script_dir_path}"

# 各種パス
env_dir_path="$(realpath "${script_dir_path}/..")"  # このスクリプトの操作対象の環境のパス
wk_dir_path="${env_dir_path}/ssh_host_key"

if [ -d ${wk_dir_path} ]; then
    echo -e "\e[33mWARN: ${wk_dir_path} は既に存在するため、処理をスキップしました。生成は行われていません。\e[m"
    exit 0
fi

mkdir -p "${wk_dir_path}"

# RSAキーの生成
ssh-keygen -t rsa -b 4096 -f "${wk_dir_path}/ssh_host_rsa_key" -N ''

# ECDSAキーの生成
ssh-keygen -t ecdsa -b 521 -f "${wk_dir_path}/ssh_host_ecdsa_key" -N ''

# ED25519キーの生成
ssh-keygen -t ed25519 -f "${wk_dir_path}/ssh_host_ed25519_key" -N ''

echo "完了"