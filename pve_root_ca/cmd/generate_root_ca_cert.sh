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
root_ca_dir_path="$(realpath "${script_dir_path}/..")"

# 現在のディレクトリを保存し、root_ca_dir_path フォルダに移動
pushd "${root_ca_dir_path}" || exit 1

# エラートラップを設定（スクリプト終了時に popd を必ず実行する）
trap 'popd' EXIT

wk_dir_path="./root-ca-cert"

certs_dir_path="${wk_dir_path}/certs"
db_dir_path="${wk_dir_path}/db"
private_dir_path="${wk_dir_path}/private"

key_path="${private_dir_path}/pve-root-ca.key" # 秘密鍵ファイル
csr_path="${wk_dir_path}/pve-root-ca.csr"      # 証明書署名要求ファイル
crt_path="${wk_dir_path}/pve-root-ca.crt"      # 証明書ファイル

if [ -d ${wk_dir_path} ]; then
    echo -e "\e[31mERROR: ${wk_dir_path} は既に存在します。\e[m"
    exit 1
fi

# 必要なディレクトリ（証明書、データベース、秘密鍵用）を作成
mkdir -p "${certs_dir_path}" "${db_dir_path}" "${private_dir_path}"

# 秘密鍵用ディレクトリにセキュリティ設定（アクセス権限700）を適用
chmod 700 "${private_dir_path}"

# 証明書の発行情報を管理するデータベースファイル（index）を作成
touch "${db_dir_path}/index"

# 16進数の乱数を生成して、証明書のシリアル番号（serial）ファイルに保存
openssl rand -hex 16 > "${db_dir_path}/serial"

# 秘密鍵と証明書署名要求（CSR）を生成する
#   -out:    生成したCSRを保存するファイルパス
#   -keyout: 生成した秘密鍵を保存するファイルパス  
#   -nodes:  秘密鍵をパスフレーズなしで生成
openssl req -new -config "./root-ca-cert.conf" \
    -out "${csr_path}" \
    -keyout "${key_path}" \
    -nodes

# 自己署名証明書（ルートCA証明書）を作成する
#   -in:         署名に使用するCSRのファイルパス
#   -out:        生成した証明書を保存するファイルパス
#   -extensions: 証明書に追加する拡張設定（root-ca-cert.conf内で定義）
openssl ca -selfsign -batch -config "./root-ca-cert.conf" \
    -in "${csr_path}" \
    -out "${crt_path}" \
    -extensions req_ext

echo "完了"
