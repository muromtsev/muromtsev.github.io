---
layout: post
title: Apache Kafka Quickstart
date: '2025-07-09 13:16:00 +0300'
author: <author_id>
categories: [Kafka]
tags: [faq]
description: Быстрый старт Apache Kafka
---


## Запуск нескольких серверов Kafka

- файл конфигурации под каждый сервер - `server.properties`
- обновить свойства
  - `node.id` - определяет уникальный идентификатор для сервера Kafka в кластере
  - `listeners` - определяет список адресов (host:port) для броокеров и контроллеров. Это сетевые интерфейсы которые Kafka использует для общения с другими серверами и клиентами
  - `controller.quorum.voters` - список votes (избирателей), которые составляют кворум в кластере, принимая решения по обеспечению согласованности данных и оказоустойчивости
  - `advertised.listeners` - список адресов для сединения с брокером, отличается от свойства "listeners", которое определяет адреса и порты, которые брокер Kafka использует для прослушивания входящих подключений
  - `logs.dirs` - докальная директория метаданных, логоов, снапшотв данного сервера

## Запуск Kafka

1. Генерируем ID для Kafka кластера
  ```bash
  kafka-storage.bat random-uuid
  ```
2. Формируем логи для совместимоости с kraft режимом
  ```bash
  kafka-storage.bat format -t your_uuid -c ..\..\config\kraft\server.properties
  ```
3. Запуск Kafka с дефоолтным конфигом
  ```bash
  kafka-server-start.bat ..\..\config\kraft\server.properties
  ```

## Создание топика CLI

```bash
  kafka-topics.bat --create --topic payment-created-events-topic --partitions 3 --replication-factor 3 --bootstrap-server localhost:9092.locahost:9094
```
`--create --topic payment-created-events-topic` - создать новый тпик с именем _payment-created-events-topic_

`--partitions 3` - количество партиций, количеств consumers не может превышать количество партиций. Т.е. если партиция одна, то параллельной обработки не будет даже если много consumers запустили

`--replication-factor 3` - 3 копии каждой партиции(одна в лидере, две в репликах), не может быть больше чем серверов

`--bootstrap-server localhost:9092,localhost:9094` - список брокероов в кластере, можно указать только один и он найдет остальных, но лучше список для надежности


## Список топиков

```bash
  kafka-topics.bat --list --bootstrap-server localhost:9092,localhost:9094
```

## Детальная инфа по топикам

```bash
  kafka-topics.bat --describe --boostrap-server localhost:9092,localhost:9094
```

## Удаление топиков

```bash
  kafka-topics.bat --delete --topic payment-created-events-topic --bootstrap-server localhost:9092
```

> `delete.topic.enable=true` в файле properties, по умолчанию true
{: .prompt-info }

> в Windows возможна ошибка `AccessDeniedException`
> 
> версия <= 2.8
> 
> То бишь команда на удаление уже записалась в брокер, и последующий запуск серверов будет невозможен.
> 
> Радикально починить - можно удалением папки `tmp`, путь до которой можно найти в свойствах `log.dirs`
{: .prompt-warning }

## Отправка сообщения (Producer)

```bash
  kafka-console-producer.bat --bootstrap-server localhost:9092,localhost:9094 --topic payment-canceled-events-topic
```

> После чего можем писать сообщения в топик, но после первого соообщения будет ошибка.
> 
> Это случается потому что топика такого ещё нет, и при первой отправке сообщения топик только создаётся и уже поосле сооздания может далее отправлять сообщения.
> 
> По умлочанию в файле properties есть поле `auto.create.topics.enable=true` - котороое как раз и отвечает за это
> 
> Плохая практика.
> 
> Топик создается автоматически, с кофигом по умолчанию.
> 
> Сначала создать топик, а уже потом отправлять собщения.
{: .prompt-info }

```bash
  kafka-console-producer.bat --bootstrap-server localhost:9092,localhost:9094 --topic payment-canceled-events-topic --property "parse.kay=true" --property "key.separator=:"
```
`--property "parse.kay=true"` - парсить ключ при выводе

`--property "key.separator=:"` - ключ : значение

## Чтение сообщения из топика

```bash
  kafka-cinsole-cunsumer.bat --bootstrap-server localhost:9092,localhost:9094 --topic payment-canceled-events-topic --from-beginning --property "print.key=true"
```

Читает и выводит все соообщения с начала

`--property "print.key=true"` - читает и выводит и ключ и значение

`--property "print.value=false"` - читает и выводит только ключи..

Если убрать параметр `--from-beginning`, будет  читать только новые сообщения

> Чтобы добавить сообщения в одну партицию и читать их необходимо указывать одинаковый ключ для каждого сообщения
{: .prompt-info }





