# Дипломная работа: Отказоустойчивая инфраструктура в Yandex Cloud

## Описание

Разработана отказоустойчивая инфраструктура для веб-сайта с мониторингом, сбором логов и резервным копированием. Вся инфраструктура разворачивается через **Terraform**, конфигурация серверов — через **Ansible**.

## Стек технологий

- **Terraform** — IaC для развертывания инфраструктуры
- **Ansible** — конфигурация серверов (роли, плейбуки)
- **Yandex Cloud** — облачная платформа
- **Nginx** — веб-сервер
- **Zabbix 6.4** — мониторинг (закрыт из интернета)
- **Elasticsearch 8.11** — хранение логов (с xpack.security)
- **Kibana 8.11** — визуализация логов (закрыта из интернета)
- **Filebeat 8.11** — сбор логов Nginx
- **Docker** — контейнеризация Elastic-стека

## Архитектура

### Сеть
- VPC: `default`
- Публичная подсеть: `public-subnet-a` (10.1.0.0/24, зона A)
- Приватные подсети:
  - `private-subnet-a` (10.2.0.0/24, зона A) — web1
  - `private-subnet-b` (10.3.0.0/24, зона B) — web2
  - `private-subnet-es` (10.4.0.0/24, зона A) — elasticsearch
- NAT-шлюз для доступа приватных ВМ в интернет
- Route table с маршрутом 0.0.0.0/0 через NAT

### Виртуальные машины

| ВМ | Внутренний IP | Внешний IP | Назначение |
|---|---|---|---|
| bastion | 10.1.0.18 | 111.88.248.183 | SSH-доступ к приватным ВМ |
| web1 | 10.2.0.28 | — | Nginx, Zabbix Agent, Filebeat |
| web2 | 10.3.0.12 | — | Nginx, Zabbix Agent, Filebeat |
| zabbix | 10.1.0.10 | 84.252.129.249 | Zabbix Server, MySQL |
| elasticsearch | 10.4.0.17 | — | Elasticsearch (Docker) |
| kibana | 10.1.0.6 | 111.88.249.107 | Kibana (Docker) |

### Load Balancer
- **IP**: 158.160.188.134
- Target Group: web1, web2
- Backend Group: `web-backend-group` (healthcheck HTTP :80 /)
- HTTP Router: `web-http-router`

### Безопасность

- **Приватные ВМ** (web1, web2, elasticsearch) — без внешних IP
- **SSH-доступ** только через bastion host
- **Security Groups**:
  - `sg-bastion`: SSH (22) отовсюду, egress any
  - `sg-web-new`: HTTP (80) от LB (10.0.0.0/8), SSH (22) от bastion, Zabbix agent (10050) от zabbix
  - `sg-zabbix`: SSH (22) отовсюду, **Web (80) только internal (10.0.0.0/8)**, Zabbix agent/trapper (10050/10051) internal
  - `sg-elasticsearch`: ES (9200) internal, SSH (22) от bastion
  - `sg-kibana`: SSH (22) отовсюду, **Kibana (5601) только internal (10.0.0.0/8)**

### Мониторинг (Zabbix)

- **Zabbix Server 6.4** + MySQL + Apache
- Zabbix Agents на web1, web2, zabbix
- Дашборд **USE Metrics**: CPU, Memory, Disk, Network
- **Закрыт из интернета** — доступ через SSH-туннель:

```bash
ssh -i ~/.ssh/id_rsa -L 8080:10.1.0.10:80 ubuntu@111.88.248.183 -N
# Затем: http://localhost:8080/zabbix (Admin / zabbix)
```

### Логирование (Elastic Stack)

  - Elasticsearch 8.11 с включённой безопасностью (xpack.security.enabled=true)

  - Kibana 8.11 с авторизацией через Elasticsearch

  - Filebeat 8.11 на web1 и web2 — собирает логи Nginx (access.log, error.log)

  - Index pattern: nginx-logs-*

  - Kibana закрыта из интернета — доступ через SSH-туннель:

```bash
ssh -i ~/.ssh/id_rsa -L 5601:10.1.0.6:5601 ubuntu@111.88.248.183 -N
# Затем: http://localhost:5601 (elastic / ElasticPass123!)
```

### Резервное копирование

  - Snapshot Schedule daily-snapshots (Terraform)

  - Расписание: ежедневно в 2:00 (0 2 * * *)

  - Хранение: 7 дней (604800s)

  - Все 6 дисков ВМ

### Структура репозитория

.
├── terraform/
│   ├── main.tf                 # Провайдер Yandex Cloud
│   ├── variables.tf            # Переменные
│   ├── network.tf              # VPC, подсети, NAT, route table
│   ├── security_groups.tf      # Security Groups
│   ├── instances.tf            # Виртуальные машины
│   ├── images.tf               # Data source для образа Ubuntu
│   ├── load_balancer.tf        # ALB: Target/Backend/HTTP Router/LB
│   ├── snapshots.tf            # Snapshot Schedule
│   ├── outputs.tf              # IP и FQDN
│   └── terraform.tfvars.example
├── ansible/
│   ├── inventory.ini           # Inventory с ProxyCommand через bastion
│   ├── playbook-nginx.yml
│   ├── playbook-zabbix-agent.yml
│   ├── playbook-zabbix-server.yml
│   ├── playbook-docker.yml
│   ├── playbook-elasticsearch.yml
│   ├── playbook-kibana.yml
│   ├── playbook-filebeat.yml
│   └── roles/
│       ├── nginx/
│       ├── zabbix_agent/
│       ├── zabbix_server/
│       ├── docker/
│       ├── elasticsearch/
│       ├── kibana/
│       └── filebeat/
├── docs/screenshots/           # Скриншоты
└── README.md

### Развертывание

### 1. Terraform

```bash
cd terraform
# Создать key.json (сервисный аккаунт Yandex Cloud)
cp terraform.tfvars.example terraform.tfvars
# Заполнить cloud_id, folder_id
terraform init
terraform apply
```

### 2. Ansible

```bash
cd ansible
# Запустить плейбуки по порядку:
ansible-playbook -i inventory.ini playbook-nginx.yml
ansible-playbook -i inventory.ini playbook-zabbix-agent.yml
ansible-playbook -i inventory.ini playbook-zabbix-server.yml
ansible-playbook -i inventory.ini playbook-docker.yml
ansible-playbook -i inventory.ini playbook-elasticsearch.yml
ansible-playbook -i inventory.ini playbook-kibana.yml
ansible-playbook -i inventory.ini playbook-filebeat.yml
```

### Тестирование

### Сайт через Load Balancer

```bash
curl -v http://158.160.188.134
# HTTP/1.1 200 OK
# <h1>Web Server web1</h1> или <h1>Web Server web2</h1>
```

Балансировка проверена через check-host.net — отвечает 200 OK с 8+ точек мира (Россия, США, Испания, Сербия, Вьетнам, Украина и др.).

### Zabbix (внутренний доступ)

```bash
ssh -i ~/.ssh/id_rsa ubuntu@111.88.248.183 "curl -I http://10.1.0.10/zabbix"
# HTTP/1.1 301 Moved Permanently
```

### Kibana (внутренний доступ)

```bash
ssh -i ~/.ssh/id_rsa ubuntu@111.88.248.183 "curl -s http://10.1.0.6:5601/api/status"
# {"status":{"overall":{"level":"available"}}}
```

### Elasticsearch с авторизацией

```bash
ssh -i ~/.ssh/id_rsa ubuntu@111.88.248.183 "curl -s -u elastic:ElasticPass123! http://10.4.0.17:9200"
# JSON с информацией о кластере
```

### Логи Nginx в Elasticsearch

```bash
ssh -i ~/.ssh/id_rsa ubuntu@111.88.248.183 "curl -s -u elastic:ElasticPass123! 'http://10.4.0.17:9200/_cat/indices?v'"
# .ds-nginx-logs-8.11.0-* с docs.count > 2000
```
