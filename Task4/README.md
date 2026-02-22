# Задача 4: Организация ролевого доступа к Kubernetes

## Описание

Настройка RBAC для кластера K8S компании PropDevelopment.

## Файлы
1. [roles.md](roles.md)  - описание ролей
2. [create-users.sh](./scripts/create-users.sh)  - скрипт для создания пользователей
3. [create-roles.sh](./scripts/create-roles.sh)  - скрипт для создания ролей
4. [create-bindings.sh](./scripts/create-bindings.sh) - скрипт для связывания пользователей с ролями

## Инструкция по применению


### 1 Запуск Minikube

```bash
minikube start --driver=docker
```

### 2 Создание пользователей

```bash
./scripts/create-users.sh
```

### 3: Создание ролей

```bash
./scripts/create-roles.sh
```

### 4: Связывание пользователей с ролями

```bash
./scripts/create-bindings.sh
```