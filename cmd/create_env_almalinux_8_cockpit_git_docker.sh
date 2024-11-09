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
root_dir_path="$(realpath "${script_dir_path}/..")"
template_dir_path="${root_dir_path}/environments/templates/almalinux_8_cockpit_git_docker_template"
env_dir_path="${root_dir_path}/environments/$1"

if [ -d ${env_dir_path} ]; then
    echo -e "\e[31mERROR: ${env_dir_path} は既に存在します。\e[m"
    exit 1
fi

cp -r "${template_dir_path}" "${env_dir_path}"

echo "完了"
