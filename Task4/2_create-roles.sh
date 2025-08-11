#!/bin/bash
# ------------ cluster roles
# просмотр секретов кластера
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cluster-secrets-viewer
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "list", "watch"]
EOF

# управление секретами кластера
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cluster-secrets-admin
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["*"]
EOF

# просмотр всех ресурсов кластера, кроме секретов
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cluster-resources-viewer
rules:
- apiGroups: [""]
  resources: ["pods","services","configmaps","endpoints","persistentvolumes","persistentvolumeclaims","namespaces","nodes"]
  verbs: ["get", "list", "watch"]
EOF

# управление всеми ресурсами кластера, кроме секретов
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cluster-resources-admin
rules:
- apiGroups: [""]
  resources: ["pods","services","configmaps","endpoints","persistentvolumes","persistentvolumeclaims","namespaces","nodes"]
  verbs: ["*"]
EOF

# ------------ roles
kubectl create namespace dev-sales
kubectl create namespace dev-tenants

# просмотр всех ресурсов в namespace dev-sales (в том числе секретов)
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: dev-sales
  name: dev-sales-viewer
rules:
- apiGroups: [""]
  resources: ["secrets", "pods","services","configmaps","endpoints","persistentvolumes","persistentvolumeclaims","nodes"]
  verbs: ["get", "list", "watch"]
EOF

# управление всеми ресурсами в namespace dev-sales (в том числе секретами)
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: dev-sales
  name: dev-sales-admin
rules:
- apiGroups: [""]
  resources: ["secrets", "pods","services","configmaps","endpoints","persistentvolumes","persistentvolumeclaims","nodes"]
  verbs: ["*"]
EOF

# просмотр всех ресурсов в namespace dev-tenants (в том числе секретов)
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: dev-tenants
  name: dev-tenants-viewer
rules:
- apiGroups: [""]
  resources: ["secrets", "pods","services","configmaps","endpoints","persistentvolumes","persistentvolumeclaims","nodes"]
  verbs: ["get", "list", "watch"]
EOF

# управление всеми ресурсами в namespace dev-tenants (в том числе секретами)
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: dev-tenants
  name: dev-tenants-admin
rules:
- apiGroups: [""]
  resources: ["secrets", "pods","services","configmaps","endpoints","persistentvolumes","persistentvolumeclaims","nodes"]
  verbs: ["*"]
EOF

