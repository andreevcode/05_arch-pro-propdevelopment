#!/bin/bash

minikube delete
minikube start
minikube cp audit-policy.yaml /etc/kubernetes/audit-policy.yaml
minikube cp kube-apiserver.yaml /etc/kubernetes/manifests/kube-apiserver.yaml
minikube start