## Network policies для Kubernetes
### Решение
- Создать поды в отдельном `namespace`, имитирующие API и ADMIN контура с 2 подами в каждом (фронт и бэк).
- Настроить разрешенные соединения только внутри контуров через сетевые политики.
- **API контур**
  - back-end-api -> front-end [ALLOWED]
  - front-end -> back-end-api [ALLOWED]
- **ADMIN контур**
  - admin-back-end -> admin-front-end [ALLOWED]
  - admin-front-end -> admin-back-end [ALLOWED]


### Как проверить?
1. Убедиться, что minikube запущен с профилем, где добавлен один из аддонов, поддерживающих сетевые политики.
    ```sh
    kubectl -n kube-system get pods | egrep -i 'calico|cilium|antrea|canal'
    ```
2. Если нет, то сетевые политики даже после `kubectl apply` не сработают и будут являться только декларацией о намерениях. Нужно удалить текущий профиль и стартовать minikube c одним из аддонов, например:
    ```sh
      minikube delete
      minikube minikube start --cni=calico
      kubectl -n kube-system get pods | egrep -i 'calico|cilium|antrea|canal'
    ```
   - **Примечание**: после перезапуска `minikube stop/minibe start` аддон по-прежнему будет доступен.
3. Создать поды `chmod +x 1_create_pods.sh && ./1_create_pods.sh`.
4. Применить сетевые политики `kubectl apply -f 2_api_and_admin_network_policies.yaml`.
5. Проверить сетевые доступы:
- использовать скрипт для проверки всех сетевых связей `chmod +x 3_check_network_policies.sh && ./3_check_network_policies.sh`.
- под капотом скрипта `wget`; при этом т.к. на `nginx` подах `wget` нет, то будет делать так:
  - создавать временный под (который удаляется после выполнения команды) с `linux-alpine` и `wget` в комплекте в нашем namespace и с нужной меткой (имитируя реальный под);
  - с него ходить в тот или иной реальный под как в примере ниже (где должно быть `BLOCKED):
  ```sh
  kubectl run t$RANDOM -n network-policies-test --restart=Never --rm -it \
  --image=busybox --labels role=back-end-api \    
  --command -- sh -c "wget -qO- --timeout=2 http://admin-front-end-app >/dev/null && echo ALLOWED || echo BLOCKED"
  ```
6. Удалить namespace (и все поды с сетевыми политиками одновременно): `chmod +x 4_cleanup.sh && ./4_cleanup.sh`
    
