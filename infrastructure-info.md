# Инфраструктура — текущие данные

## ВМ (внутренние IP)
| ВМ | Внутренний IP | Внешний IP |
|---|---|---|
| bastion | 10.1.0.18 | 111.88.248.183 |
| web1 | 10.2.0.28 | — |
| web2 | 10.3.0.12 | — |
| zabbix | 10.1.0.10 | 84.252.129.249 |
| elasticsearch | 10.4.0.17 | — |
| kibana | 10.1.0.6 | 111.88.249.107 |

## Load Balancer
- IP: 158.160.188.134

## Пароли (для диплома)
- Zabbix: Admin / zabbix
- Elasticsearch: elastic / ElasticPass123!
- Kibana: elastic / ElasticPass123!
- Zabbix DB: zabbix / ChangeMe123!

## Доступ
- Zabbix: через SSH-туннель `ssh -L 8080:10.1.0.10:80 ubuntu@111.88.248.183 -N` → http://localhost:8080/zabbix
- Kibana: через SSH-туннель `ssh -L 5601:10.1.0.6:5601 ubuntu@111.88.248.183 -N` → http://localhost:5601
