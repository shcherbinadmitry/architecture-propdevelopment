#!/bin/bash

set -Eeuo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

echo ""

echo "Очищаем старые ресурсы если существуют"
APP_DEPLOYMENTS=(
  front-end-app
  back-end-api-app
  admin-front-end-app
  admin-back-end-api-app
)

# Удаляем приложения (Service/Deployment)
for name in "${APP_DEPLOYMENTS[@]}"; do
  kubectl delete service "$name" --ignore-not-found || true
  kubectl delete deployment "$name" --ignore-not-found || true
  # ожидаем удаления
  if kubectl get deployment "$name" >/dev/null 2>&1; then
    echo "Ожидаем удаление deployment $name ..."
    kubectl wait --for=delete deployment/"$name" --timeout=60s || true
  fi
  if kubectl get service "$name" >/dev/null 2>&1; then
    echo "Ожидаем удаление service $name ..."
    kubectl wait --for=delete service/"$name" --timeout=60s || true
  fi
  # На всякий случай удалим оставшиеся pod'ы
  kubectl delete pod -l app="$name" --ignore-not-found || true
  if kubectl get pods -l app="$name" -o name | grep -q .; then
    echo "Ожидаем удаление pod'ов $name ..."
    kubectl wait --for=delete pods -l app="$name" --timeout=60s || true
  fi
done

# Удаляем сетевые политики, чтобы при повторном запуске состояние было воспроизводимым
NETPOL=(
  allow-all-egress
  allow-frontend-from-backend
  allow-backend-from-frontend
  allow-admin-frontend-from-admin-backend
  allow-admin-backend-from-admin-frontend
  default-deny-ingress
)
for np in "${NETPOL[@]}"; do
  kubectl delete networkpolicy "$np" --ignore-not-found || true
done

echo "Создаем сервисы и deployment'ы через декларативные манифесты"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

kubectl apply -f "$SCRIPT_DIR/frontend.yaml"
kubectl apply -f "$SCRIPT_DIR/backend.yaml"
kubectl apply -f "$SCRIPT_DIR/admin-frontend.yaml"
kubectl apply -f "$SCRIPT_DIR/admin-backend.yaml"

# Дожидаемся готовности pod'ов, чтобы политика применилась к существующим объектам
kubectl rollout status deployment/front-end-app --timeout=120s || true
kubectl rollout status deployment/back-end-api-app --timeout=120s || true
kubectl rollout status deployment/admin-front-end-app --timeout=120s || true
kubectl rollout status deployment/admin-back-end-api-app --timeout=120s || true

echo "Применяем сетевые политики"
kubectl apply -f "$SCRIPT_DIR/non-admin-api-allow.yaml"

echo "Готово"
