#!/bin/bash
set -euo pipefail

# === НАСТРОЙКИ ===
# Папка для хранения сгенерированных ключей/сертификатов
CERTS_DIR="./user-certs"
mkdir -p "$CERTS_DIR"

# Путь к CA вашего кластера
# Для minikube:
CA_CRT="${HOME}/.minikube/ca.crt"
CA_KEY="${HOME}/.minikube/ca.key"

# Параметры кластера (из kubeconfig)
CLUSTER_NAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].name}')
CLUSTER_SERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')

# === ФУНКЦИЯ СОЗДАНИЯ ПОЛЬЗОВАТЕЛЯ ===
create_user() {
  local GROUP_NAME=$1
  local USER_NAME=$2

  echo "[INFO] Creating user '$USER_NAME' in group '$GROUP_NAME'"

  # 1. Генерация приватного ключа
  openssl genrsa -out "${CERTS_DIR}/${USER_NAME}.key" 2048

  # 2. Генерация CSR (CN = имя пользователя, O = имя группы)
  openssl req -new \
    -key "${CERTS_DIR}/${USER_NAME}.key" \
    -out "${CERTS_DIR}/${USER_NAME}.csr" \
    -subj "/CN=${USER_NAME}/O=${GROUP_NAME}"

  # 3. Подписание CSR с помощью CA кластера
  openssl x509 -req \
    -in "${CERTS_DIR}/${USER_NAME}.csr" \
    -CA "${CA_CRT}" \
    -CAkey "${CA_KEY}" \
    -CAcreateserial \
    -out "${CERTS_DIR}/${USER_NAME}.crt" \
    -days 365

  # 4. Добавление пользователя в kubeconfig
  kubectl config set-credentials "${USER_NAME}" \
    --client-certificate="${CERTS_DIR}/${USER_NAME}.crt" \
    --client-key="${CERTS_DIR}/${USER_NAME}.key"

  # 5. Создание контекста (namespace = default)
  kubectl config set-context "${USER_NAME}-context" \
    --cluster="${CLUSTER_NAME}" \
    --namespace=default \
    --user="${USER_NAME}"

  echo "[INFO] User '${USER_NAME}' created with context '${USER_NAME}-context'"
}
# === СОЗДАНИЕ ВСЕХ ПОЛЬЗОВАТЕЛЕЙ ИЗ СТРУКТУРЫ ===
main() {
  # developers/dev-team-sales
  create_user dev-team-sales Bob # Senior
  create_user dev-team-sales Alice

  # developers/dev-team-tenants
  create_user dev-team-tenants Michael  # Senior
  create_user dev-team-tenants Sonya

  # security
  create_user security Architect

  # devops
  create_user devops Neo # Senior
  create_user devops Trinity

  echo "[INFO] All users created. You can now use 'kubectl --context <user>-context' to operate as them."
}

main "$@"