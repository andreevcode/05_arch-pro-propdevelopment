#!/usr/bin/env bash

echo "************ PSA TEST - начало ************"
echo "=== minikube delete/start ==="
minikube delete
minikube start

echo "=== Проверка готовности API ==="
kubectl wait --for=condition=Ready nodes --all --timeout=30s

echo "=== Apply 01-create-namespace.yaml ==="
kubectl apply -f 01-create-namespace.yaml 2>&1 || echo "FAILED"

echo "=== Проверка готовности sa/default ==="
until kubectl get serviceaccount default -n audit-zone; do
  echo "Waiting for serviceaccount 'default' in namespace audit-zone..."
  sleep 2
done
echo "serviceaccount 'default' is ready."

echo "=== Apply insecure test pods (ожидаем DENIED) ==="
kubectl apply -f ./insecure-manifests/01-privileged-pod.yaml 2>&1 || echo  "DENIED as expected"
kubectl apply -f ./insecure-manifests/02-hostpath-pod.yaml 2>&1 || echo  "DENIED as expected"
kubectl apply -f ./insecure-manifests/03-root-user-pod.yaml 2>&1 || echo  "DENIED as expected"

echo "=== Apply secure test pods (не ожидаем DENIED) ==="
kubectl apply -f ./secure-manifests/04-unprivileged-pod.yaml --dry-run=server 2>&1 || echo "DENIED not expected"
kubectl apply -f ./secure-manifests/05-non-hostpath-pod.yaml --dry-run=server 2>&1 || echo "DENIED not expected"
kubectl apply -f ./secure-manifests/06-non-root-user-pod.yaml --dry-run=server 2>&1 || echo "DENIED not expected"

echo "************ PSA TEST - конец ************"

