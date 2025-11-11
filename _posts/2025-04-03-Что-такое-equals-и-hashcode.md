---
layout: post
title: Что такое equals() и hashCode()?
date: '2025-04-03 06:24:42 +0300'
author: <author_id>
categories: [Java]
tags: [faq]
description: Часто встечающиюся вопросы о Java
---
## Что такое equals() и hashCode()? Контракт, зачем переопределять вместе
`equals()`
- Определяет логическое равенство объектов (по содержимому полей, а не по ссылке).
- По умолчанию (в классе Object) сравнивает ссылки (==).
- Пример переопределения:
```java
@Override
public boolean equals(Object o) {
    if (this == o) return true;  // один и тот же объект
    if (o == null || getClass() != o.getClass()) return false;
    Cat cat = (Cat) o;
    return age == cat.age && Objects.equals(name, cat.name);
}
```
`hashcode()`
- Возвращает числовой хеш-код объекта (используется в HashMap, HashSet и других хеш-коллекциях).
- По умолчанию (в Object) возвращает уникальный код на основе адреса в памяти.
- Пример переопределения:
```java
@Override
public int hashCode() {
    return Objects.hash(name, age);  // хеш на основе полей
}
```

### Контракт между equals() и hashCode()
При переопределении одного из методов обязательно нужно переопределять и второй, соблюдая правила:
1. Если equals() возвращает true → hashCode() должен быть одинаковым
2. Обратное не обязательно: одинаковый hashCode() не гарантирует равенство объектов.
3. Если equals() возвращает false → hashCode() может быть как одинаковым, так и разным (но для производительности лучше, чтобы был разным).

### Почему переопределять вместе?
1. Некорректная работа HashMap/HashSet
  - Если equals() переопределён, а hashCode() нет — объекты с одинаковыми полями могут попасть в разные "корзины" (buckets) хеш-таблицы.
  - пример
```java
Set<Cat> cats = new HashSet<>();
cats.add(new Cat("Мурзик", 3));
cats.contains(new Cat("Мурзик", 3));  // вернет false, если hashCode() не переопределён!
```
2. Потеря объектов в коллекциях
Объект, добавленный в HashSet, может "потеряться" при поиске, если hashCode() не согласован с equals().

### Как правильно переопределять?
Используйте Objects.hash()
```java
@Override
public int hashCode() {
    return Objects.hash(name, age, breed);  // все поля, участвующие в equals()
}
```
Правила для equals()
1. Рефлексивность: x.equals(x) == true.
2. Симметричность: если x.equals(y) == true, то y.equals(x) == true.
3. Транзитивность: если x.equals(y) и y.equals(z), то x.equals(z).
4. Консистентность: повторные вызовы equals() должны возвращать одно и то же значение.
5. Сравнение с null: x.equals(null) == false.
```java 
public class Cat {
    private String name;
    private int age;

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Cat cat = (Cat) o;
        return age == cat.age && Objects.equals(name, cat.name);
    }

    @Override
    public int hashCode() {
        return Objects.hash(name, age);
    }
}
```
### Когда переопределять не нужно?
1. Уникальность объектов определяется ссылкой (например, Thread).
2. Класс не используется в хеш-коллекциях (HashMap, HashSet).

## Если hashCode() всегда возвращает одно и то же число — что будет? 
Если метод hashCode() всегда возвращает одно и то же число (константу), это нарушает принцип работы хеш-коллекций (HashMap, HashSet, HashTable), но код останется корректным с точки зрения компиляции. Вот что произойдёт:

### 1. Последствия для хеш-коллекций
#### Производительность деградирует до O(n)
- Все объекты будут попадать в одну "корзину" (bucket) внутри хеш-таблицы.
- Поиск, вставка и удаление элементов будут работать как в LinkedList (линейный поиск).

Пример для HashMap:
```java
Map<Cat, String> map = new HashMap<>();
map.put(new Cat("Мурзик", 3), "Домашний");  // Все коты попадут в один bucket
map.put(new Cat("Барсик", 5), "Уличный");

// Поиск будет медленным, так как перебирается цепочка в одном bucket
String owner = map.get(new Cat("Мурзик", 3)); 
```
#### Техническая корректность
- Коллекции будут работать, но крайне неэффективно
- equals() остаётся главным для сравнения объектов
- Контракт hashCode() не нарушен (если equals() вернет true, хеши одинаковые)

#### Пример с HashSet
```java
Set<Cat> cats = new HashSet<>();
cats.add(new Cat("Мурзик", 3));  // hash = 1
cats.add(new Cat("Барсик", 5));  // hash = 1

System.out.println(cats.size());  // 2 (объекты разные по equals())
```
- Размер HashSet будет правильным, но внутри он превратится в список.

#### Когда это может быть нужно?
1. Для тестирования — чтобы гарантировать коллизии и проверить устойчивость кода.
2. В специфичных сценариях — когда все объекты должны быть в одном bucket (крайне редко).
