#!/bin/bash

set -Eeuo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

NAMESPACE="propdevelopment"

echo "Создаем namespace K8S"
if kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
  echo "Пространство $NAMESPACE уже существует"
else
  kubectl create namespace $NAMESPACE
  kubectl config set-context --current --namespace=$NAMESPACE
  echo "Пространство $NAMESPACE создано"
fi
echo "================="
echo

SVC_ACCOUNTS=(reader-user editor-user admin-user)

echo "Проверяем/создаем сервисные аккаунты: ${SVC_ACCOUNTS[*]}"
for sa in "${SVC_ACCOUNTS[@]}"; do
  if kubectl get serviceaccount "$sa" -n "$NAMESPACE" >/dev/null 2>&1; then
    echo "ServiceAccount $sa в namespace $NAMESPACE уже существует"
  else
    echo "Создаем ServiceAccount $sa в namespace $NAMESPACE"
    kubectl create serviceaccount "$sa" -n "$NAMESPACE"
  fi
done

echo "Cервисные аккаунты созданы"
echo "================="
echo
