---
layout: post
title: Apache Maven
date: '2025-04-14 14:32:27 +0300'
author: <author_id>
categories: [Maven]
tags: [faq]
description: Смотрим внутренности Maven
---

### Depedency Scope

В Maven зависимости (dependencies) могут иметь различные scope, которые определяют, на каких этапах жизненного цикла сборки проекта зависимость будет доступна.

```
<dependencies>
  <dependency>
    <groupId>jakarta.servlet</groupId>
    <artifactId>jakarta.servlet-api</artifactId>
    <version>5.0.0</version>
    <scope>provided</scope>
  </dependency>
</dependencies>
```
`Scopes`
- compile - выбирается по-умолчанию, если не указан.
  - Зависимость доступна во всех фазах (компиляция, тестирование, выполнение).
  - Включается в итоговый артефакт (например, JAR/WAR).  
- provided
  - Зависимость требуется для компиляции и тестирования, но не включается в итоговый артефакт.
  - Предполагается, что среда выполнения (например, сервер приложений) предоставит её самостоятельно.
  - Примеры: Servlet API, Java EE API.
- runtime
  - Зависимость не нужна для компиляции, но требуется во время выполнения.
  - Включается в итоговый артефакт.
  - Пример: JDBC-драйвер (на этапе компиляции используется только интерфейс, а драйвер подключается в runtime).
- test
  - Зависимость нужна только для тестирования (компиляция и выполнение тестов).
  - Не включается в итоговый артефакт.
  - Примеры: JUnit, Mockito.
- system
  - Аналогичен provided, но путь к JAR-файлу указывается явно через <systemPath>.
  - Не рекомендуется к использованию, так как делает сборку непереносимой.

<hr>

### Настройка Maven в Idea

Идём `Build, Execution, Deployment` -> `Build Tools`
- Reload project after changes in the build scripts:
  - Any changes - автоматически будет подтягивать зависимости (не хорошо для больших проектов)
  - External changes - по нажатию

<hr>

### Просмотр наследования зависимостей

```bash
mvn dependency:help // просмотр goals dependency
```

Выведет 21 goal, из которых интересны `analyze` и `tree`

`mvn dependency:analyze` - покажет статистику по нашим зависимостям. Что можно убрать, что нет. 

`mvn dependency:tree` - покажет дерево зависимостей, а так же транзитивные зависимости

`mvn dependency:tree -Dverbose` - более подробная статистика. Можно увидеть не совместимые зависимости

При конфликте зависмостей можно отключать те или иные зависимости

```
<dependencies>
  <dependency>
    <groupId>org.springframework</groupId>
    <artifactId>spring-webmvc</artifactId>
    <version>5.0.5.RELEASE</version>
    <exclusions>
      <exclusion>
        <groupId>org.springframework</groupId>
        <artifactId>spring-beans</artifactId> // уйдёт из spring-mvc
      </exclusion>
    </exclusions>
  </dependency>
  <dependency>
    <groupId>org.springframework</groupId>
    <artifactId>spring-aop</artifactId>
    <version>5.1.7.RELEASE</version>          // здесь будут bean version 5.1.7
  </dependency>
</dependencies>
```
