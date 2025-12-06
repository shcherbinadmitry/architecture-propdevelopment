#!/bin/bash

set -Eeuo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

echo "Применяем ролевую модель K8S"

shopt -s nullglob
files=(./roles/*.yaml ./roles/*.yml)
if [ ${#files[@]} -eq 0 ]; then
  echo "В каталоге ./roles не найдено YAML-файлов"
else
  for file in "${files[@]}"; do
    if kubectl get -f "$file" >/dev/null 2>&1; then
      echo "Ресурсы из $file уже существуют — пропускаем"
    else
      echo "Применяем $file"
      kubectl apply -f "$file"
    fi
  done
fi

echo "Ролевая модель K8S настроена"
echo "================="
echo