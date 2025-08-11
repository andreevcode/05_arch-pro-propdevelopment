#!/usr/bin/env bash
set -e

echo "************ Gatekeeper TEST - начало ************"
echo "=== minikube delete/start ==="
minikube delete
minikube start

echo "=== Проверка готовности API ==="
kubectl wait --for=condition=Ready nodes --all --timeout=60s

echo "=== Apply 01-create-namespace_no_psa.yaml ==="
kubectl apply -f 01-create-namespace_no_psa.yaml || echo "FAILED"

echo "=== Проверка готовности sa/default ==="
until kubectl get serviceaccount default -n audit-zone &>/dev/null; do
  echo "Waiting for serviceaccount 'default' in namespace audit-zone..."
  sleep 2
done
echo "serviceaccount 'default' is ready."

echo "=== Установка Gatekeeper ==="
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/release-3.16/deploy/gatekeeper.yaml
kubectl wait --for=condition=Available --timeout=300s deployment/gatekeeper-audit --namespace=gatekeeper-system
kubectl wait --for=condition=Available --timeout=300s deployment/gatekeeper-controller-manager --namespace=gatekeeper-system

echo "=== Проверка, что вебхуки зарегистрированы ==="
kubectl get validatingwebhookconfigurations.admissionregistration.k8s.io | grep gatekeeper
kubectl get mutatingwebhookconfigurations.admissionregistration.k8s.io | grep gatekeeper || true

echo "=== Apply ConstraintTemplates ==="
kubectl apply -f ./gatekeeper/constraint-templates/hostpath.yaml
kubectl apply -f ./gatekeeper/constraint-templates/privileged.yaml
kubectl apply -f ./gatekeeper/constraint-templates/runasnonroot.yaml

echo "=== Apply Constraints ==="
kubectl apply -f ./gatekeeper/constraints/hostpath.yaml
kubectl apply -f ./gatekeeper/constraints/privileged.yaml
kubectl apply -f ./gatekeeper/constraints/runasnonroot.yaml

echo "=== Apply insecure test pods (ожидаем DENIED) ==="
kubectl apply -f ./insecure-manifests/01-privileged-pod.yaml  2>&1 || echo "DENIED as expected"
kubectl apply -f ./insecure-manifests/02-hostpath-pod.yaml 2>&1 || echo "DENIED as expected"
kubectl apply -f ./insecure-manifests/03-root-user-pod.yaml 2>&1 || echo "DENIED as expected"

echo "=== Apply insecure test pods (не ожидаем DENIED) ==="
kubectl apply -f ./secure-manifests/04-unprivileged-pod.yaml --dry-run=server  2>&1  || echo "DENIED not expected"
kubectl apply -f ./secure-manifests/05-non-hostpath-pod.yaml --dry-run=server 2>&1 || echo "DENIED not expected"
kubectl apply -f ./secure-manifests/06-non-root-user-pod.yaml --dry-run=server 2>&1 || echo "DENIED not expected"

echo "************ Gatekeeper TEST - конец ************"