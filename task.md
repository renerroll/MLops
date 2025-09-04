Мета

Використовувати модульну структуру Terraform-проєктів;

Автоматизувати створення VPC та EKS за допомогою готових модулів;

Навчитися створювати масштабовані node group-и для CPU та GPU задач;

Працювати з terraform_remote_state, outputs та providers;

Отримувати доступ до кластера через kubectl одразу після terraform apply.



Результати виконання

У вашому AWS-акаунті створено повноцінну VPC-інфраструктуру за допомогою офіційного модуля Terraform.
У цій VPC автоматизовано створено EKS-кластер із двома node group-ами (наприклад, для CPU і GPU задач).
Структура проєкту модульна: є окремі каталоги для vpc/ і eks/, кожен зі своїми variables.tf, outputs.tf, main.tf.
У кореневій директорії проєкту знаходиться main.tf, який викликає обидва модулі (module "vpc", module "eks").
Після terraform apply кластер створений і доступний через kubectl.
(Бонус) Якщо ви хочете, можете розширити кластер з окремими тегами / labels для нод або створити приватний кластер із доступом через bastion-host.




Кроки виконання завдання



1. Створіть модуль vpc/

Використайте офіційний модуль terraform-aws-modules/vpc/aws.
У папці vpc/ мають бути:
main.tf — з викликом модуля;
variables.tf — вхідні параметри (CIDR, імена, availability zones…);
outputs.tf — експорт ідентифікаторів VPC, сабнетів тощо;
terraform.tf і backend.tf — для конфігурації backend-у.


2. Створіть модуль eks/

Використайте модуль terraform-aws-modules/eks/aws.
Мають бути 2 node group-и:
cpu-nodes (звичайні EC2, наприклад t3.medium)
gpu-nodes (опціонально — EC2 з GPU, наприклад g4dn.xlarge або t4g)
Підключіться до VPC, створеної в попередньому кроці, через data.terraform_remote_state.


3. Кореневий main.tf

Створіть main.tf у кореневій директорії, який імпортує обидва модулі:
module "vpc" {
  source = "./vpc"
  ...
}

module "eks" {
  source = "./eks"
  ...
}

Усі значення можна передавати через locals або variables.tf у корені.


4. Після terraform apply

Перевірте, що кластер створено:
aws eks --region <region> update-kubeconfig --name <your-cluster-name>
kubectl get nodes

Ви маєте побачити обидві node group-и.




📦Очікувана структура проєкту

eks-vpc-cluster/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tf
├── backend.tf
├── vpc/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tf
│   └── backend.tf
├── eks/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tf
│   └── backend.tf
└── README.md





Критерії прийняття завдання

Критерії прийняття домашнього завдання є обов’язковою умовою розгляду завдання ментором.

Якщо якийсь із критеріїв не виконано, ментор надішле ДЗ на доопрацювання без оцінювання.


1. Використано офіційний модуль terraform-aws-modules/vpc/aws для створення VPC.

2. Використано офіційний модуль terraform-aws-modules/eks/aws для створення EKS.

3. У проєкті є окремі папки vpc/ і eks/, кожна містить:

main.tf
variables.tf
outputs.tf
terraform.tf
backend.tf
4. У корені є main.tf, який імпортує обидва модулі:

module "vpc" {
  source = "./vpc"
  ...
}

module "eks" {
  source = "./eks"
  ...
}

5. Після terraform apply створюється кластер із двома node group-ами.

6. Конфігурація aws provider-а працює (через профіль або IAM).





Підготовка та завантаження домашнього завдання

Щоб домашнє завдання було зручним для перевірки, а ваші зусилля точно не пропали дарма, дотримуйтеся чіткої структури завантаження й оформлення.



1. Створіть окрему гілку lesson-5-6 у вашому GitHub-репозиторії

У терміналі перейдіть у ваш локальний проєкт і створіть нову гілку:

git checkout -b lesson-5-6



Закомітьте всі зміни та запуште гілку:

git add .
git commit -m "Add lesson-5-6: VPC and EKS infrastructure"
git push --set-upstream origin lesson-5-6





2. Створіть архів .zip із вашим проєктом

Переконайтеся, що всі потрібні файли знаходяться у структурі проєкту:

.
├── main.tf
├── variables.tf
├── outputs.tf
├── vpc/
│   ├── main.tf
│   ├── variables.tf
│   └── ...
├── eks/
│   ├── main.tf
│   ├── variables.tf
│   └── ...
├── README.md




✅ Наприкінці перевірте:

Чи всі terraform apply працюють без помилок?
Чи кластер доступний через kubectl?
Чи README.md пояснює, як користуватись проєктом?
Чи гілка lesson-5-6 запушена та чи посилання на неї в LMS вказано правильно?




Формат оцінювання

Оцінка від 0 до 100 балів:

Створення VPC за допомогою офіційного модуля — 20 балів
Створення EKS з двома node group-ами — 30 балів
Повністю робоча конфігурація Terraform (init + apply без помилок) — 20 балів
Кластер доступний через kubectl — 20 балів
Наявність README.md з інструкціями — 10 балів
