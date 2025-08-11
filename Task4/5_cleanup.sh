#!/usr/bin/env bash
# set -euo pipefail

# Пользователи, роли и bindings до очистки
echo "[1/6] Проверка конфигурации до очистки"
echo "-----------Текущие пользователи:"
kubectl config get-users || echo '(ничего не найдено)'
echo "-----------Добавленные кластерные роли и биндинги:"
kubectl get clusterrole,clusterrolebinding | grep -E 'cluster-resources|cluster-secrets' || echo '(ничего не найдено)'
echo "-----------Добавленные роли и биндинги в неймспейсах dev-sales и dev-tenants"
kubectl get role,rolebinding -A | grep -E 'dev-sales|dev-tenants' || echo '(ничего не найдено)'

# Настройки (правь по мере надобности)
USERS=(Trinity Neo Architect Bob Alice Michael Sonya)
NAMESPACES=(dev-sales dev-tenants)
CLUSTER_ROLES=(cluster-secrets-viewer cluster-secrets-admin cluster-resources-viewer cluster-resources-admin)
CLUSTER_BINDINGS=(cluster-secrets-viewer-binding cluster-secrets-admin-binding cluster-resources-viewer-binding cluster-resources-admin-binding )

echo "[2/6] Удаляем кластерные роли и биндинги..."
kubectl delete clusterrole "${CLUSTER_ROLES[@]}"  2>/dev/null || true
kubectl delete clusterrolebinding "${CLUSTER_BINDINGS[@]}"  2>/dev/null || true

echo "[3/6] Удаляем namespaces (это автоматически удалит Role/RoleBinding внутри)..."
kubectl delete ns "${NAMESPACES[@]}" 2>/dev/null || true
# Если не хотите ждать финализации:
# kubectl delete ns "${NAMESPACES[@]}" --wait=false 2>/dev/null || true

echo "[4/6] Чистим kubeconfig (contexts и users)..."
for u in "${USERS[@]}"; do
  kubectl config delete-context "${u}-context" 2>/dev/null || true
  kubectl config unset "users.${u}" 2>/dev/null || true
done

echo "[5/6] Удаляем локальные сертификаты из ./user-certs..."
rm -rf ./user-certs 2>/dev/null || true

# Пользователи, роли и bindings после очистки
echo "[6/6] Проверка конфигурации после очистки"
echo "-----------Текущие пользователи:"
kubectl config get-users || echo '(ничего не найдено)'
echo "-----------Добавленные кластерные роли и биндинги:"
kubectl get clusterrole,clusterrolebinding | grep -E 'cluster-resources|cluster-secrets' || echo '(ничего не найдено)'
echo "-----------Добавленные роли и биндинги в неймспейсах dev-sales и dev-tenants"
kubectl get role,rolebinding -A | grep -E 'dev-sales|dev-tenants' || echo '(ничего не найдено)'

echo "Done."