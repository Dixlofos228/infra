# Instahelper Infrastructure (GCP)

## 📋 Краткое описание
Этот репозиторий содержит код для развертывания инфраструктуры приложения Instahelper в Google Cloud Platform с использованием Terraform.

## 🔧 Требования к инфраструктуре
- [Google Cloud Platform аккаунт](https://cloud.google.com/) с активным биллингом
- [Установленный gcloud CLI](https://cloud.google.com/sdk/docs/install)
- [Terraform >= 1.0](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [Git](https://git-scm.com/downloads)

---

## 📦 Предварительная установка

```bash
# Установка Terraform (Arch Linux)
sudo pacman -S terraform

# Установка gcloud CLI
curl -sSL https://sdk.cloud.google.com | bash
```

---

## 🚀 Развертывание проекта

### 1. Клонирование репозитория

```bash
git clone https://gitlab.skillbox.ru/alex_ignatenko/infra.git
cd infra/terraform/environments/prod
```

### 2. Настройка переменных

Создайте файл `terraform.tfvars`:

```hcl
project_id  = "instahelper-1772547417"
region      = "us-central1"
zone        = "us-central1-a"
domain_name = ""
```

### 3. Создание сервисного аккаунта

```bash
gcloud iam service-accounts create terraform-sa

gcloud projects add-iam-policy-binding instahelper-1772547417 \
    --member="serviceAccount:terraform-sa@instahelper-1772547417.iam.gserviceaccount.com" \
    --role="roles/editor"

gcloud iam service-accounts keys create ~/terraform-key.json \
    --iam-account="terraform-sa@instahelper-1772547417.iam.gserviceaccount.com"
```

### 4. Деплой инфраструктуры

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

### 5. Сохранение выходных данных

```bash
terraform output
```

---

## 🖥️ Состав серверов

- **Виртуальная машина:** 1 инстанс (`e2-small`, 20GB диск)
- **Балансировщик:** Глобальный HTTP балансировщик
- **Сеть:** VPC с подсетью `10.10.0.0/24`
- **Firewall:** Правила для HTTP (80, 8080) и SSH (22)

---

## 🔄 Схема взаимодействия

```text
Пользователь → HTTP (80) → Балансировщик → Backend Service → Instance Group → VM (порт 8080)
```

---

## 📁 Структура файлов

- `providers.tf` — настройка провайдера GCP  
- `variables.tf` — входные переменные  
- `network.tf` — VPC, подсети, firewall правила  
- `vm.tf` — виртуальная машина и instance group  
- `loadbalancer.tf` — балансировщик, health check  
- `outputs.tf` — выходные данные (IP адреса)  

---

## 💾 Хранение состояния Terraform

Рекомендуется использовать удаленный бэкенд:

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

## 📝 Результаты развертывания

После успешного применения Terraform вы получите:

- Балансировщик: http://130.211.25.158  
- Приложение доступно по адресу: http://130.211.25.158  
- Health check: http://130.211.25.158/health  
