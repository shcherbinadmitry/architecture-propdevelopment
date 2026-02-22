#!/bin/bash

set -Eeuo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

echo "Связываем пользователей с ролями"

shopt -s nullglob
files=(./bindings/*.yaml ./bindings/*.yml)
if [ ${#files[@]} -eq 0 ]; then
  echo "В каталоге ./bindings не найдено YAML-файлов"
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

echo "Пользователи привязаны к ролям"
echo "================="