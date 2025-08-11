#!/usr/bin/env bash

# запомним текущий контекст и вернёмся к нему в конце
PREV_CTX="$(kubectl config current-context 2>/dev/null || true)"

USERS=(Bob Alice Michael Sonya Architect Trinity Neo)

upper() { tr '[:lower:]' '[:upper:]'; }

can_i_cluster() {
  # $1=verb $2=resource
  # || true — чтобы не ронять скрипт на "NO"
  kubectl auth can-i "$1" "$2" 2>/dev/null || true | tr -d '\r' | upper
}
can_i_ns() {
  # $1=verb $2=resource $3=namespace
  kubectl auth can-i "$1" "$2" -n "$3" 2>/dev/null || true | tr -d '\r' | upper
}

line_for_user_cluster() {
  # $1=user
  if ! kubectl config get-contexts -o name | grep -qx "${1}-context"; then
    printf "%s: пользователь не найден\n" "$1"
    return
  fi

  kubectl config use-context "${1}-context" >/dev/null 2>&1 || true
  sget=$(can_i_cluster get secrets)
  screate=$(can_i_cluster create secrets)
  nget=$(can_i_cluster get nodes)
  ncreate=$(can_i_cluster create nodes)
  printf "$1:\n   get/create secrets [$sget/$screate]\n   get/create nodes [$nget/$ncreate]\n"
}

line_for_user_ns() {
  # $1=user $2=namespace
  if ! kubectl config get-contexts -o name | grep -qx "${1}-context"; then
    printf "%s: пользователь не найден\n" "$1"
    return
  fi

  kubectl config use-context "${1}-context" >/dev/null 2>&1 || true
  sget=$(can_i_ns get secrets "$2")
  screate=$(can_i_ns create secrets "$2")
  printf "$1:\n   get/create secrets [$sget/$screate]\n"
}

echo "-----cluster"
for u in "${USERS[@]}"; do line_for_user_cluster "$u"; done
echo

echo "-----namespace dev-sales"
for u in "${USERS[@]}"; do line_for_user_ns "$u" dev-sales; done
echo

echo "-----namespace dev-tenants"
for u in "${USERS[@]}"; do line_for_user_ns "$u" dev-tenants; done

# вернуть исходный контекст
kubectl config use-context minikube