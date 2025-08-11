#!/bin/bash

minikube ssh "sudo cat /var/log/audit.log" > ./audit.log
FILTERED_AUDIT="filtered_audit.log"
> "$FILTERED_AUDIT"

printf "\n----------------------------Доступ к секретам----------------------------\n" >> "$FILTERED_AUDIT"
jq -c 'select(.objectRef.resource=="secrets" and (.verb=="get" or .verb=="list"))' audit.log 2>/dev/null >> "$FILTERED_AUDIT"

printf "\n----------------------------Выполнение команд kubectl exec----------------------------\n" >> "$FILTERED_AUDIT"
jq -c 'select(.verb=="get" and .objectRef.subresource=="exec")' audit.log 2>/dev/null >> "$FILTERED_AUDIT"

printf "\n----------------------------Создание privileged пода----------------------------\n" >> "$FILTERED_AUDIT"
jq -c 'select(.objectRef.resource=="pods" and .verb=="create" and (.requestObject.spec.containers // [] | any(.securityContext.privileged==true)))' audit.log 2>/dev/null >> "$FILTERED_AUDIT"

printf "\n----------------------------Повышение привилегий ролей----------------------------\n" >> "$FILTERED_AUDIT"
jq -c 'select((.objectRef.resource=="rolebindings" or .objectRef.resource=="clusterrolebindings") and .verb=="create" and .requestObject.roleRef.name=="cluster-admin")' audit.log 2>/dev/null >> "$FILTERED_AUDIT"

printf "\n---------------------------Попытка удаления политик аудита----------------------------\n" >> "$FILTERED_AUDIT"
jq -c 'select((.verb=="delete" or .verb=="deletecollection") and (.objectRef.resource=="pods" or .objectRef.resource=="secrets" or .objectRef.resource=="configmaps"))' audit.log 2>/dev/null >> "$FILTERED_AUDIT"