# Instahelper Infrastructure (GCP)

## 📋 Краткое описание
Этот репозиторий содержит код для развертывания инфраструктуры приложения Instahelper в Google Cloud Platform с использованием Terraform.

## 🔧 Требования к инфраструктуре
- [Google Cloud Platform аккаунт](https://cloud.google.com/) с активным биллингом
- [Установленный gcloud CLI](https://cloud.google.com/sdk/docs/install)
- [Terraform >= 1.0](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [Git](https://git-scm.com/downloads)

## 📦 Предварительная установка
```bash
# Установка Terraform (Arch Linux)
sudo pacman -S terraform

# Установка gcloud CLI
curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash

# Инициализация gcloud
gcloud init
