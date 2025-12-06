#!/bin/bash

set -Eeuo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

echo ""


echo "Очищаем старые ресурсы если существуют"
NAMES=(
  front-end-app
  back-end-api-app
  admin-front-end-app
  admin-back-end-api-app
)
for name in "${NAMES[@]}"; do
  kubectl delete pod "$name" --ignore-not-found || true
  kubectl delete deployment "$name" --ignore-not-found || true
  kubectl delete rc "$name" --ignore-not-found || true
  kubectl delete job "$name" --ignore-not-found || true
  kubectl delete service "$name" --ignore-not-found || true
  # Wait for the pod to be fully deleted if it existed
  if kubectl get pod "$name"  >/dev/null 2>&1; then
    echo "Ожидаем удаление pod $name ..."
    kubectl wait --for=delete pod/"$name" --timeout=60s || true
  fi
done

echo "Создаем сервисы и pod'ы"

kubectl run front-end-app --image=nginx --labels role=front-end --restart=Never --expose --port 80
kubectl run back-end-api-app --image=nginx --labels role=back-end --restart=Never --expose --port 80
kubectl run admin-front-end-app --image=nginx --labels role=admin-front-end --restart=Never --expose --port 80
kubectl run admin-back-end-api-app --image=nginx --labels role=admin-back-end --restart=Never --expose --port 80

echo "Применяем сетевые политики"
kubectl apply -f non-admin-api-allow.yaml

echo "Готово"
