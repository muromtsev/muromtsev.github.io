---
layout: post
title: ArrayList vs LinkedList
date: '2025-04-06 09:39:56 +0300'
author: <author_id>
categories: [Java]
tags: [faq]
description: Часто встечающиюся вопросы о Java
---

## ArrayList vs LinkedList, сложность
### ArrayList и LinkedList: устройство, вставка, поиск 

#### 1. Внутреннее устройство

`ArrayList`
- Основан на динамическом массиве (Object[] elementData).
- Автоматически расширяется при заполнении (обычно в 1.5 раза).
- Прямой доступ по индексу за O(1).
- Неэффективен при частых вставках/удалениях в середину.
```java
  ArrayList<Integer> list = new ArrayList<>();
  // Внутри: Object[10] (по умолчанию), при переполнении -> Object[15] и т.д.
```

`LinkedList`
- Основан на двусвязном списке (узлы Node<E> с ссылками prev/next).
- Нет затрат на расширение массива.
- Эффективен для вставок/удалений в начало/середину/конец.
- Медленный доступ по индексу (требуется обход с начала или конца).
```java
  LinkedList<Integer> list = new LinkedList<>();
  // Внутри: first -> Node(prev=null, item=1, next=Node2) <-> Node2(prev=Node1, item=2, next=null) <- last
```
<hr>

#### 2. Сложность операций `add/insert/get/remove`

`ArrayList` (динамический массив)

| Операция                                 | Сложность (Big O)       | Пояснение                                                     |
| ---------------------------------------- | ----------------------- | ------------------------------------------------------------- |
| Добавление в конец (add(E e))            | O(1) (амортизированная) | Вставка в конец обычно O(1), но при расширении массива — O(n) |
| Вставка по индексу (add(int index, E e)) | O(n)                    | Требуется сдвиг всех элементов правее index                   |
| Получение по индексу (get(int index))    | O(1)                    | Прямой доступ к элементу массива                              |
| Удаление по индексу (remove(int index))  | O(n)                    | Сдвиг всех элементов правее index                             |
| Поиск по значению (contains(E e))        | O(n)                    | Линейный поиск (перебор всех элементов)                       |
| Удаление по значению (remove(Object o))  | O(n)                    | Поиск (O(n)) + удаление (O(n))                                |

_Особенности:_
- Доступ по индексу (get/set) — очень быстрый (O(1)), так как используется массив.
- Вставка/удаление в начало/середину — медленные (O(n)), так как требуют сдвига элементов.
- Расширение массива — при заполнении создаётся новый массив (обычно в 1.5 раза больше), и все элементы копируются (O(n)).

`LinkedList` (двусвязный список)

| Операция                                 | Сложность (Big O) | Пояснение                                                                      |
| ---------------------------------------- | ----------------- | ------------------------------------------------------------------------------ |
| Добавление в конец (add(E e))            | O(1)              | Просто создаётся новый узел и связывается с last                               |
| Вставка по индексу (add(int index, E e)) | O(n)              | Поиск позиции (O(n)) + вставка (O(1))                                          |
| Получение по индексу (get(int index))    | O(n)              | Требуется обход с начала или конца (оптимизируется для индексов ближе к краям) |
| Удаление по индексу (remove(int index))  | O(n)              | Поиск (O(n)) + удаление (O(1))                                                 |
| Поиск по значению (contains(E e))        | O(n)              | Линейный поиск (перебор всех узлов)                                            |
| Удаление по значению (remove(Object o))  | O(n)              | Поиск (O(n)) + удаление (O(1))                                                 |
| Добавление в начало (addFirst(E e))      | O(1)              | Просто обновляются ссылки first и next                                         |
| Удаление из начала (removeFirst())       | O(1)              | Просто обновляется ссылка first                                                |

_Особенности:_
- Вставка/удаление в начало/конец — очень быстрые (O(1)), так как не требуют сдвига элементов.
- Доступ по индексу (get/set) — медленный (O(n)), так как требует обхода списка.
- Использование памяти — каждый элемент (Node) хранит 3 поля: item, next, prev (больше накладных расходов, чем у ArrayList).

_Сравнительная таблица_

| Операция           | ArrayList | LinkedList                    |
| ------------------ | --------- | ----------------------------- |
| Доступ по индексу  | O(1)      | O(n)                          |
| Вставка в конец    | O(1)*     | O(1)                          |
| Вставка в начало   | O(n)      | O(1)                          |
| Вставка в середину | O(n)      | O(n) (поиск) + O(1) (вставка) |
| Удаление из начала | O(n)      | O(1)                          |
| Удаление из конца  | O(1)      | O(1)                          |
| Поиск по значению  | O(n)      | O(n)                          |

* В среднем O(1), но при расширении массива — O(n).
<hr>

#### 3. Когда что использовать?

`ArrayList:`
- Частый доступ по индексу (например, get(i)).
- Редкие вставки/удаления (или только в конец).
- Пример: Хранение списка студентов для быстрого поиска по номеру в журнале.
```java
  ArrayList<String> students = new ArrayList<>();
  students.add("Анна");  // O(1)
  students.get(0);       // O(1)
```

`LinkedList:`
- Частые вставки/удаления в начало/середину.
- Реализация очереди/стека (например, Deque).
- Пример: История действий в приложении с возможностью отмены (добавление и удаление с обоих концов).
```java
  LinkedList<String> history = new LinkedList<>();
  history.addFirst("Action1");  // O(1)
  history.removeLast();         // O(1)
```
<hr>

#### 4. Память и накладные расходы

- ArrayList:
  - Требует меньше памяти на элемент (только данные + запас массива).
  - Избыточный размер массива может привести к "пустому" расходу памяти.

- LinkedList:
  - Каждый элемент хранит 2 ссылки (prev и next), что увеличивает потребление памяти на 16-24 байта на элемент (в 64-битной JVM).
  - Нет избыточного выделения памяти.
<hr>

#### 5. Примеры операций

*_Вставка в середину_*
```java
  // ArrayList: O(n)
  list.add(5, "element");  // Сдвигает все элементы правее 5-й позиции

  // LinkedList: O(n) на поиск позиции + O(1) на вставку
  list.add(5, "element");  // Быстрее для больших списков, если индекс ближе к началу/концу
```

*_Итерация_*
- Для ArrayList итерация быстрее (данные расположены в памяти последовательно, что дружественно к кэшу процессора).
- Для LinkedList итерация медленнее (переход по ссылкам, нет локалиности данных).

```java
  // Быстрее для ArrayList
  for (String item : arrayList) { ... }

  // Медленнее для LinkedList
  for (String item : linkedList) { ... }
```
<hr>

#### Как расширяется ArrayList при достижении capacity?

1. Начальная емкость (Initial Capacity)
   - По умолчанию ArrayList создаётся с начальной емкостью 10:
   ```java
    ArrayList<Integer> list = new ArrayList<>(); // capacity = 10
   ```
   - Можно задать свою начальную емкость:
   ```java
    ArrayList<Integer> list = new ArrayList<>(100); // capacity = 100
   ```
2. Что происходит при добавлении элементов?
   Когда массив заполняется, ArrayList автоматически расширяется:
   - Проверка заполненности:
      - При вызове add(element) проверяется, хватает ли места:
      ```java
        if (size + 1 > elementData.length) {
            grow(); // Вызов метода расширения
        }
      ```
   - Расширение (grow()):
    - Новый размер = старый размер * 1.5 (в OpenJDK) или старый размер + (старый размер >> 1).
    - Например:
      - Было 10 → станет 15.
      - Было 15 → станет 22 (15 + 7).
    - Внутри создаётся новый массив большего размера, и все элементы копируются в него:
    ```java
      int newCapacity = oldCapacity + (oldCapacity >> 1); // Увеличение в ~1.5 раза
      elementData = Arrays.copyOf(elementData, newCapacity);
    ```
3. Пример процесса расширения
  Допустим, у нас ArrayList с начальной capacity = 3:

  
    | Операция    | Размер (size) | Вместимость (capacity) | Что происходит?                       |
    | ----------- | ------------- | ---------------------- | ------------------------------------- |
    | list.add(1) | 1             | 3                      | Массив [1, null, null]                |
    | list.add(2) | 2             | 3                      | Массив [1, 2, null]                   |
    | list.add(3) | 3             | 3                      | Массив [1, 2, 3] (заполнен)           |
    | list.add(4) | 4             | 4 + (4 >> 1) = 6       | Новый массив [1, 2, 3, 4, null, null] |

4. Как избежать частых расширений?
  Если известно примерное количество элементов, лучше сразу задать capacity:
  ```java
    ArrayList<Integer> list = new ArrayList<>(1000); // Минимизирует ресайзы
  ```
5. Итог
- ArrayList расширяется в ~1.5 раза при заполнении.
- Копирование элементов при расширении требует времени (O(n)).
- Оптимизация: задавайте начальный размер, если знаете примерное количество элементов.
<hr>
