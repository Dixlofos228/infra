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
---

## 📊 Инфраструктура для логирования

### Обзор
Проект использует **Pydantic Logfire** для сбора и анализа логов. Хотя сам Logfire является облачным SaaS-решением, инфраструктура обеспечивает:

1. **Доступ к серверам** для установки агентов сбора логов  
2. **Сетевую связность** между серверами и внешними API  
3. **Обновление Docker-образов** с интегрированным Logfire SDK  

---

## Компоненты инфраструктуры

| Компонент | Назначение | Реализация |
|-----------|------------|------------|
| **Firewall правила** | Разрешить исходящий трафик к API Logfire | `google_compute_firewall` ресурсы |
| **Service Account** | Права для доступа к метаданным | `service_account` в инстансах |
| **Ansible плейбуки** | Установка зависимостей и настройка окружения | `ansible/playbooks/setup-logging.yml` |
| **Переменные окружения** | Хранение токена Logfire | CI/CD переменные в GitLab |

---

## Настройка доступа к Logfire API

Для отправки логов сервера должны иметь доступ к API Logfire:

- **API endpoint:** `https://logfire-eu.pydantic.dev`  
- **Порты:** HTTPS (`443`)  
- **Домены:** `*.pydantic.dev`  

---

## Terraform-ресурсы для логирования

```hcl
# Пример firewall правила для исходящего трафика
resource "google_compute_firewall" "allow-egress-logfire" {
  name    = "allow-egress-logfire"
  network = google_compute_network.vpc.name
  direction = "EGRESS"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  destination_ranges = ["0.0.0.0/0"]
  target_tags        = ["app-server", "logging-agent"]
}
```

---

## Ansible роль для настройки логирования

Планируется добавить роль для автоматической установки агентов сбора логов (если потребуется self-hosted решение).

---

## 🔗 Ссылки

- **Logfire Dashboard:** https://logfire-eu.pydantic.dev/senb0/instahelper-logs  
- **Документация Logfire:** https://logfire.pydantic.dev/docs  
- **Расчёты и обоснование выбора:** https://docs.google.com/spreadsheets/d/1Pf0uaylurlPbRIMk5au7VQgYIdyeR5WjKGrEsS45Ia8/edit?usp=sharing

---

## 🗺️ План развития платформы (Roadmap)
Документ с планом работ на ближайшие полгода доступен по ссылке:
https://docs.google.com/document/d/1XJfLckaDNwLiiZxcHEHDqfXh-6Z4bw0454sHLGeFF00/edit?usp=sharing

-------------------

## Финальная работа (DevOps-инженер. Advanced)

### Выполненные задачи

#### Раздел 1. Service Discovery (Consul)
- Развернут кластер Consul (сервер на monitoring-prod, агент на instahelper-prod-1)
- Настроена автоматическая регистрация сервисов
- Установлен consul-exporter, метрики собираются в Prometheus
- Создан дашборд в Grafana для мониторинга Consul
- В Consul KV store записаны версии приложения

#### Раздел 2. Автоматическое масштабирование
- Создан образ ВМ instahelper-base-image-final
- Создан instance template instahelper-template-final
- Настроена managed instance group с автоскейлингом (min=1, max=5, target CPU=60%)
- Проведено нагрузочное тестирование, автоскейлер сработал

#### Раздел 3. Оптимизация метрик (VictoriaMetrics)
- Развернута VictoriaMetrics на monitoring-prod
- Настроен remote write из Prometheus в VictoriaMetrics
- Создан дашборд в Grafana с метриками из VictoriaMetrics

#### Раздел 4. EFK Stack (Elasticsearch, Fluentd, Kibana)
- Развернут Elasticsearch в Docker
- Развернута Kibana на отдельной ВМ
- Настроен Curator для удаления старых логов (cron задание)
- Настроены firewall правила для доступа между компонентами

#### Раздел 5. Статический анализ кода (SonarQube)
- Развернут SonarQube на отдельной ВМ
- Создан проект instahelper-service
- Сгенерирован токен и добавлен в GitLab CI/CD
- Настроен пайплайн с этапом sonarqube-check
- Написана документация для разработчиков

#### Раздел 6. Сетевая безопасность
- Создана отдельная VPC security-lab-vpc
- Созданы 5 подсетей (DMZ, app1, app2, db1, db2)
- Настроены firewall правила согласно матрице доступности
- Созданы тестовые ВМ для проверки связности
- Составлена матрица доступности

#### Раздел 7. Бюджетирование
- Составлен годовой бюджет на эталонный сервис
- Добавлены комментарии по оптимизации каждой статьи расходов
- Таблица доступна по ссылке

### Ссылки
- Бюджетирование: https://docs.google.com/document/d/1brk9fGb5lnjPDp-Xv5hFD5RAZIk-Eah1sp91PtcHuSE/edit?usp=sharing
- Матрица доступности: https://docs.google.com/document/d/13EhB5jM08FKXNwjk2R6Bz5LCNEieI_uetMIIP56xXX8/edit?usp=sharing
