#!/usr/bin/env bash
set -euo pipefail

NS="network-policies-test"
IMG="busybox"
TO=2   # timeout, сек

run_check () {
  local src_role="$1"   # пример: back-end-api | front-end | admin-back-end | admin-front-end
  local dst_svc="$2"    # пример: front-end-app
  local name="npcheck-$src_role-$(od -An -N2 -tu2 < /dev/urandom | tr -d '[:space:]')"

  kubectl run "$name" -n "$NS" \
    --restart=Never --rm -i \
    --image="$IMG" \
    --labels "role=$src_role" \
    --command -- sh -c "wget -qO- --timeout=$TO http://$dst_svc >/dev/null" \
    >/dev/null 2>&1 \
    && echo " $src_role -> $dst_svc [ALLOWED]" \
    || echo " $src_role -> $dst_svc [BLOCKED]"
}

echo "=== API contour checks ==="
run_check back-end-api front-end-app
run_check front-end    back-end-api-app

echo "=== ADMIN contour checks ==="
run_check admin-back-end  admin-front-end-app
run_check admin-front-end admin-back-end-app

echo "=== Cross-contour must be blocked ==="
# из API в ADMIN
run_check back-end-api admin-front-end-app
run_check back-end-api admin-back-end-app
run_check front-end    admin-front-end-app
run_check front-end    admin-back-end-app

# из ADMIN в API
run_check admin-back-end  front-end-app
run_check admin-back-end  back-end-api-app
run_check admin-front-end front-end-app
run_check admin-front-end back-end-api-app
