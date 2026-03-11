# Instahelper Infrastructure (GCP)

## 📋 Краткое описание
Этот репозиторий содержит код для развертывания инфраструктуры приложения Instahelper в Google Cloud Platform с использованием Terraform и Ansible. Поддерживаются два окружения: **uat** (тестовое) и **prod** (продакшен).

---

## 🔧 Требования
- Google Cloud Platform аккаунт с активным биллингом
- Установленный gcloud CLI
- Terraform >= 1.0
- Ansible >= 2.9
- Git

---

# 📦 Структура проекта

```text
infra/
├── terraform/
│   ├── modules/                 # Переиспользуемые модули
│   │   ├── network/             # Модуль VPC и подсетей
│   │   └── app_instance/        # Модуль ВМ приложения
│   └── environments/
│       ├── uat/                 # Тестовое окружение
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   └── terraform.tfvars
│       └── prod/                # Продакшен окружение
│           ├── main.tf
│           ├── variables.tf
│           └── terraform.tfvars
├── ansible/
│   ├── inventory/
│   │   ├── uat.yml              # Инвентарь для UAT
│   │   └── prod.yml             # Инвентарь для PROD
│   └── playbooks/
│       ├── setup-monitoring.yml     # Установка Prometheus/Grafana
│       ├── setup-node-exporter.yml  # Установка Node Exporter
│       └── setup-runner.yml         # Установка GitLab Runner
└── docs/
    └── ladr-monitoring.md      # LADR документ
```

---

# 🚀 Развертывание окружений

## 1. Клонирование репозитория

```bash
git clone https://gitlab.skillbox.ru/alex_ignatenko/infra.git
cd infra/terraform/environments
```

---

## 2. Настройка переменных

Для каждого окружения создайте `terraform.tfvars`.

### uat/terraform.tfvars

```hcl
project_id          = "instahelper-1772547417"
region              = "us-central1"
zone                = "us-central1-a"
environment         = "uat"
machine_type_app    = "e2-small"
app_instance_count  = 1
domain_name         = "uat.monitoring-2026.ccwu.cc"
```

### prod/terraform.tfvars

```hcl
project_id          = "instahelper-1772547417"
region              = "us-central1"
zone                = "us-central1-a"
environment         = "prod"
machine_type_app    = "e2-small"
app_instance_count  = 1
domain_name         = "prod.monitoring-2026.ccwu.cc"
```

---

# 3. Деплой инфраструктуры

```bash
# Для UAT окружения
cd uat
terraform init
terraform apply -auto-approve

# Для PROD окружения
cd ../prod
terraform init
terraform apply -auto-approve
```

---

# 4. Настройка мониторинга через Ansible

```bash
cd ../../ansible

# Для UAT
ansible-playbook -i inventory/uat.yml playbooks/setup-node-exporter.yml
ansible-playbook -i inventory/uat.yml playbooks/setup-monitoring.yml

# Для PROD
ansible-playbook -i inventory/prod.yml playbooks/setup-node-exporter.yml
ansible-playbook -i inventory/prod.yml playbooks/setup-monitoring.yml
```

---

# 📊 Результаты развертывания

## UAT Окружение

| Ресурс | Адрес |
|------|------|
| Приложение | http://35.223.114.56:8080 |
| Балансировщик | http://34.117.173.214 |
| Prometheus | http://104.154.119.173:9090 |
| Grafana | http://104.154.119.173:3000 |
| Домен | monitoring.monitoring-2026.ccwu.cc (Prometheus) |
| | grafana.monitoring-2026.ccwu.cc (Grafana) |

---

### PROD Окружение
| Ресурс | Адрес |
|--------|-------|
| Приложение через балансировщик | `http://prod.monitoring-2026.ccwu.cc` |
| Прямой доступ к инстансу | `http://34.10.20.104:8080` |
| Prometheus | `http://136.111.88.71:9090` |
| Grafana | `http://136.111.88.71:3000` |
| DNS запись | `prod.monitoring-2026.ccwu.cc` → `34.117.173.214` |

---

# 🔥 Firewall правила

```text
allow-http-prod           # порты 80, 8080
allow-ssh-prod            # порт 22
allow-prometheus-prod     # порт 9090
allow-grafana-prod        # порт 3000
allow-node-exporter-prod  # порт 9100
```

---

# 💾 Хранение состояния Terraform

```hcl
terraform {
  backend "http" {
    address        = "https://gitlab.skillbox.ru/api/v4/projects/YOUR_PROJECT_ID/terraform/state/infra"
    lock_address   = "https://gitlab.skillbox.ru/api/v4/projects/YOUR_PROJECT_ID/terraform/state/infra/lock"
    unlock_address = "https://gitlab.skillbox.ru/api/v4/projects/YOUR_PROJECT_ID/terraform/state/infra/lock"
    username       = "alex_ignatenko"
    password       = "YOUR_GITLAB_ACCESS_TOKEN"
  }
}
```

---

# 📤 КОМАНДЫ ДЛЯ ОБНОВЛЕНИЯ

```bash
cd ~/devops-gcp/infra

nano README.md
# Вставь новый текст

git add README.md
git commit -m "Update README with two environments (uat and prod)"
git push origin master
```
