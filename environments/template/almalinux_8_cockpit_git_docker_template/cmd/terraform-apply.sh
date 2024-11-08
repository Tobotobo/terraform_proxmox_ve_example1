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

# 各種パス
script_dir_path="$(dirname "$0")"                   # このスクリプトがあるフォルダへのパス
env_dir_path="$(realpath "${script_dir_path}/..")"  # このスクリプトの操作対象の環境のパス
root_dir_path="$(realpath "${env_dir_path}/../..")" # プロジェクトルート

terraform -chdir="${env_dir_path}" \
    apply \
    -var-file="${root_dir_path}/common.tfvars" \
    -var-file="${root_dir_path}/secrets.tfvars"
