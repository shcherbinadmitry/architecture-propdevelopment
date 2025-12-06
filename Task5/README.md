# Задача 5: Управление трафиком внутри кластера Kubernetes

## Описание

Настройка сетевой политики для кластера K8S

## Файлы
1. [init.sh](init.sh) - скрипт для настройки политики

## Инструкция по применению

### 1 Назначение меток, применение сетевой политки
```bash
./init.sh
```

### 2 Тестирование сетевой политики

Меняем:
- ROLE (front-end, back-end, admin-front-end, admin-back-end)
- URL (http://front-end-app, http://back-end-api-app, http://admin-front-end-app, http://admin-back-end-api-app)
- 
Запросы должны проходить между front-end <-> back-end ролями и сервисами. Но не проходить по admin-* ролям и к admin-*-app сервисам. Для admin ролей аналогично.
Если запрос прошел, должен вернуться html от Nginx. Если не прошел, wget должен выдать ошибку по таймауту.
С неизвестной ролью запрос должен так же выдавать ошибку по таймауту

```bash
      ROLE=front-end
      URL=http://back-end-api-app
      kubectl run test-pod --rm -i --image=alpine --labels=role=$ROLE --restart=Never -- sh -c "wget -qO- --timeout=2 $URL"
```


