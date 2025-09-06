
🎯 Мета

Розгорнути ArgoCD у Kubernetes через Terraform;
Створити Git-репозиторій з Helm-деплоєм (MLflow);
Створити ArgoCD Application, який автоматично підхопить цей застосунок;
Переконатися, що кластер розгортає поди автоматично з Git.


Кроки виконання завдання
⚠️ УВАГА! ⚠️ При роботі з хмарними провайдерами завжди пам'ятайте: невикористані ресурси можуть призвести до значних витрат. Щоб уникнути непередбачуваних рахунків, після перевірки вашого коду обов'язково видаляйте створені ресурси. Використовуйте команду terraform destroy.

⚠️ УВАГА! ⚠️ Пам'ятайте порядок запуску інфраструктури після видалення! При видаленні всієї інфраструктури за допомогою terraform destroy ви також видаляєте S3-бакети, які використовуються для збереження Terraform стейту. Ви можете залишити S3-бакет для зберігання стейтів.

AWS S3 cost — $0.023 per GB/per month



1. Розгорніть ArgoCD через Terraform

У кластері, який ви вже створили, розгорніть ArgoCD як Helm-реліз через Terraform.
Створіть окремий namespace (наприклад, infra-tools).
Усі значення для чарту винесіть у файл argocd-values.yaml.
📁 Очікувана структура:

argocd/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tf
├── backend.tf
└── values/
    └── argocd-values.yaml

2. Створіть окремий Git-репозиторій з Helm-деплоєм

Створіть простий публічний або приватний репозиторій (GitHub / GitLab).
Додайте туди application.yaml, який описує деплой Helm-чарту.
Наприклад, використайте MLflow.
3. Створіть ArgoCD Application

Додайте application.yaml у той самий або інший Git-репозиторій.
Цей YAML описує:
				- repoURL, path, chart, values

				- destination (namespace, кластер)

				- syncPolicy.automated з CreateNamespace=true

4. Додайте Application у кластер

Застосуйте application.yaml вручну або через ArgoCD UI.
Перевірте, що сервіс зʼявився:
kubectl get pods -n <namespace>

5. Відкрийте доступ до сервісу

Або через kubectl port-forward, або через LoadBalancer.
Додайте інструкцію в README.md.


📝 README.md має містити:

Як запустити Terraform (init, apply);
Як перевірити, що ArgoCD працює;
Як відкрити UI ArgoCD (port-forward, логін);
Як перевірити, що деплой відбувся;
Посилання на Git-репозиторій з application.yaml.


📦 Очікувана структура проєкту

mlops-argocd-demo/
├── argocd/
│   ├── main.tf
│   ├── values/
│   │   └── argocd-values.yaml
├── README.md



Результати виконання

У кластері EKS, створеному раніше, розгорнуто ArgoCD через Terraform із власним argocd-values.yaml, де описані value Helm-чарту;
ArgoCD підключено до Git-репозиторію, у якому зберігається конфігурація Helm-деплою;
У Git-репозиторії створено application.yaml, що описує деплой тестового застосунку (MLflow);
Після git push кластер автоматично створює відповідні ресурси: Deployment, Service, Pod;
Сервіс доступний через port-forward;
У репозиторії є README.md з інструкціями запуску, перевірки, доступу до ArgoCD та сервісу.


Критерії прийняття завдання

Критерії прийняття домашнього завдання є обов’язковою умовою розгляду завдання ментором. Якщо якийсь із критеріїв не виконано, ментор надішле ДЗ на доопрацювання без оцінювання. Якщо вам «тільки уточнити»😉 або ви застопорилися на якомусь з етапів виконання — звертайтеся до ментора у Slack).


1. ArgoCD розгорнуто через Terraform як helm_release у namespace infra-tools;

2. Файл argocd-values.yaml містить налаштування сервісу (ClusterIP, extraArgs, rbac, timeouts);

3. У Git-репозиторії є application.yaml, який:

описує Helm-деплой (repoURL, chart / path, values)
використовує auto-sync і self-heal
створює namespace автоматично
4. Application застосовується в кластері, і після цього:

створюються поди, сервіси, ingress (за потреби)
можна отримати доступ через port-forward або LoadBalancer
5. У проєкті є README.md, що містить:

Інструкції запуску Terraform
Як увійти в ArgoCD UI
Як перевірити деплой
Посилання на репозиторій з application.yaml


Критерії оцінювання

Розділ	Макс. балів
ArgoCD через Terraform	30
Application у Git	25
Успішний деплой Helm-сервісу	30
README.md з інструкціями	15
Разом	100