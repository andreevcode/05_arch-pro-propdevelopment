#!/usr/bin/env bash

# Создаем ns
kubectl create namespace network-policies-test

kubectl run front-end-app           --image=nginx --labels role=front-end           --expose --port 80 --namespace=network-policies-test
kubectl run back-end-api-app        --image=nginx --labels role=back-end-api        --expose --port 80 --namespace=network-policies-test
kubectl run admin-front-end-app     --image=nginx --labels role=admin-front-end     --expose --port 80 --namespace=network-policies-test
kubectl run admin-back-end-app      --image=nginx --labels role=admin-back-end      --expose --port 80 --namespace=network-policies-test