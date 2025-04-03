---
layout: post
title: LiveReload в IDEA
date: '2025-03-31 22:49:36 +0300'
author: <author_id>
categories: [Java]
tags: [idea, spring-boot]
description: Включение автоперезагрузки проекта
---

Автоперезагрузка проекта нужна, чтобы каждый раз не перезагружать проект для изменения данных. Будь то java код или статические файлы - html/css/jss.

`pom.xml` 
```
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-devtools</artifactId>
  <optional>true</optional>
</dependency>
```

`application.properties` 
```
# Отключаем кэш шаблонов (для разработки)
spring.thymeleaf.cache=false
# Автоматическая перезагрузка devtools
spring.devtools.restart.enabled=true
```

1. Далее идём в `Settings` -> `Advanced Settings` -> `Allow auto-make to start even if developed app..` (ставим галочку)
2. `Settings` -> `Build, Execution, Deployment` -> `Compiler` -> `Build project automatically` (ставим галочку)
3. Сделать изменения в run/debug configuration
   - On 'Update' action : Update classes and resurces
   - On frame deactivation : Update classes and resurces
4. Запускаем проект 

> Перезагрузка работает когда фокус уходит из idea, клик мышью в окно браузера, и последующая перезагрука страницы (F5). Можно настроить авто, через Chrome расширение LiveReload - но оно в данный момент заблочено :(
{: .prompt-info }

[Ссылка ответ на stackoverflow](https://stackoverflow.com/a/63188493/27342989)

p.s. так же можно попробовать запустить через команду в терминале `mvn spring-boot:run`

