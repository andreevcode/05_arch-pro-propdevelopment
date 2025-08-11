## RBAC для Kubernetes

### Решение
Несколько допущений, которые брались в расчет при решении задания:
- viewer: это чтение (get, list, watch);
- admin: это все verbs "*";
- структура функциональной команды PropDevelopment (приблизительно), которой могло бы понадобиться внедрение RBAC-политик:
  - Group dev-team-sales
    - Bob (senior)
    - Alice
  - Group dev-team-tenants
    - Michael (senior)
    - Sonya
  - Group security
    - Architect
  - Group devops
    - Neo (senior)
    - Trinity

| Роль                     | Права роли                                                               | Группы пользователей             | 
|--------------------------|--------------------------------------------------------------------------|----------------------------------|
| cluster-secrets-viewer    | Просмотр всех секретов кластера                                          | devops                           |
| cluster-secrets-admin     | Управление всеми секретами кластера                                      | security, Neo (devops senior)    |
| cluster-resources-viewer | Просмотр всех ресурсов кластера (кроме секретов)                         | devops, security                 |
| cluster-resources-admin  | Управление всеми ресурсами кластера (кроме секретов)                     | devops                           |
| dev-sales-viewer         | Просмотр всех ресурсов (в том числе секретов) в namespace dev-sales      | dev-team-sales                   |
| dev-sales-admin          | Управление всеми ресурсами (в том числе секретами) в namespace dev-sales | Bob (dev-team-sales senior)      |
| dev-tenants-viewer        | Просмотр всех ресурсов (в том числе секретов) в namespace dev-tenants    | dev-team-tenants                 |
| dev-tenants-admin        | Управление всеми ресурсами (в том числе секретами) в namespace dev-tenants | Michael (dev-team-tenants senior) |

### Как проверить?
1. Создать пользователей `chmod +x 1_create_users.s && ./1_create_users.sh`.
2. Создать роли `chmod +x 2_create_roles.sh && ./2_create_roles.sh`.
3. Создать привязки `chmod +x 3_create-role-bindings.sh && ./3_create-role-bindings.sh`.
4. Посмотреть роли по пользователям: `chmod +x 4_check_users.sh && ./4_check_users.sh`.
   - под капотом по каждому юзеру:
     - `config use-context Bob-context`;
     - `kubectl auth can-i get secrets` (кластерные секреты);
     - `kubectl auth can-i get nodes` (проверка кластерных ресурсов);
     - `kubectl auth can-i get secrects -n dev-sales` (проверка секретов (как любого ресурса) в namespace);
5. Очистка добавленных пользователей, ролей и привязок `chmod +x 5_cleanup.sh && ./5_cleanup.sh`