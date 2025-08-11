##!/bin/bash

# ------------- привязки ClusterRoleBinding
# просмотр секретов кластера - группа devops
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: cluster-secrets-viewer-binding
subjects:
- kind: Group
  name: devops
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: cluster-secrets-viewer
  apiGroup: rbac.authorization.k8s.io
EOF

# управление секретами кластера - группа security, senior devops
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: cluster-secrets-admin-binding
subjects:
- kind: Group
  name: security
  apiGroup: rbac.authorization.k8s.io
- kind: User
  name: Neo
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: cluster-secrets-admin
  apiGroup: rbac.authorization.k8s.io
EOF

# просмотр всех ресурсов кластера, кроме секретов - группы devops, security
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: cluster-resources-viewer-binding
subjects:
- kind: Group
  name: devops
  apiGroup: rbac.authorization.k8s.io
- kind: Group
  name: security
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: cluster-resources-viewer
  apiGroup: rbac.authorization.k8s.io
EOF

# управление всеми ресурсами кластера, кроме секретов - группа devops
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: cluster-resources-admin-binding
subjects:
- kind: Group
  name: devops
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: cluster-resources-admin
  apiGroup: rbac.authorization.k8s.io
EOF

# ------------- привязки RoleBinding
# ------------- sales
# просмотр всех ресурсов в namespace dev-sales (в том числе секретов) - группа dev-team-sales
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: dev-sales-viewer-binding
  namespace: dev-sales
subjects:
- kind: Group
  name: dev-team-sales
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: dev-sales-viewer
  apiGroup: rbac.authorization.k8s.io
EOF

# управление всеми ресурсами в namespace dev-sales (в том числе секретами) - dev-team-sales senior
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: dev-sales-admin-binding
  namespace: dev-sales
subjects:
- kind: User
  name: Bob
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: dev-sales-admin
  apiGroup: rbac.authorization.k8s.io
EOF

# ------------- tenants
# просмотр всех ресурсов в namespace dev-tenants (в том числе секретов) - группа dev-team-tenants
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: dev-tenants-viewer-binding
  namespace: dev-tenants
subjects:
- kind: Group
  name: dev-team-tenants
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: dev-tenants-viewer
  apiGroup: rbac.authorization.k8s.io
EOF

# управление всеми ресурсами в namespace dev-tenants (в том числе секретами) - dev-team-tenants senior
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: dev-tenants-admin-binding
  namespace: dev-tenants
subjects:
- kind: User
  name: Michael
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: dev-tenants-admin
  apiGroup: rbac.authorization.k8s.io
EOF