---
layout: post
title: 'Многопоточность: volatile, synchronized, атомарные типы'
date: '2025-04-14 16:27:12 +0300'
author: <author_id>
categories: [Java]
tags: [faq]
description: Часто встечающиюся вопросы о Java
---

## Многопоточность: volatile, synchronized, атомарные типы

### Ключевое слово volatile в Java

Что даёт `volatile`

Ключевое слово `volatile` в Java обеспечивает следующие гарантии:

1. **Видимость изменений** - когда поток записывает значение в volatile-переменную, это значение сразу становится видимым для всех других потоков.
2. **Запрет переупорядочивания** - компилятор и процессор не могут переупорядочивать операции чтения/записи volatile-переменных относительно других операций памяти.
3. **Атомарность** - чтение и запись volatile переменных размером до 64 бит (int, long, float, double, boolean, ссылки) являются атомарными.

Каких гарантий не даёт `volatile`

1. **Не гарантирует атомарность составных операций** - операции вида i++ (инкремент), которые включают чтение-изменение-запись, не являются атомарными даже для volatile переменных.
2. **Не заменяет синхронизацию** - если несколько потоков изменяют volatile-переменную, всё равно может потребоваться синхронизация.
3. **Не решает проблему race condition** - volatile только обеспечивает видимость последнего значения, но не защищает от гонок потоков.


```java
public class VolatileExample {
    private volatile boolean flag = false;
    
    public void start() {
        new Thread(() -> {
            while (!flag) {
                // Ждём изменения флага
            }
            System.out.println("Flag changed!");
        }).start();
        
        new Thread(() -> {
            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            flag = true; // Изменение флага будет видно в первом потоке
        }).start();
    }
}
```

Когда использовать volatile
- Когда только один поток записывает, а другие читают
- Для простых флагов или статусов
- Когда переменная используется как триггер для выхода из цикла ожидания

Для более сложных сценариев взаимодействия потоков обычно используют synchronized, Atomic-классы или другие механизмы синхронизации.

<hr>

### Отличие volatile от synchronized в Java

**Основные различия**


| Характеристика     | volatile                                      | synchronized                        |
| ------------------ | --------------------------------------------- | ----------------------------------- |
| Видимость          | Гарантирует видимость изменений               | Гарантирует видимость + атомарность |
| Атомарность        | Только для одиночных операций                 | Для блока операций                  |
| Блокировки         | Не использует блокировки                      | Использует блокировки (мониторы)    |
| Производительность | Высокая (чтение почти как обычной переменной) | Ниже (из-за блокировок)             |
| Применимость       | Простые атомарные операции                    | Сложные операции или блоки кода     |

Когда применять `volatile`

1. Флаги и статусы - когда нужно просто сигнализировать между потоками:
```java
private volatile boolean isRunning = true;

// В одном потоке
while (isRunning) {
    // работа
}

// В другом потоке
isRunning = false; // безопасно остановит первый поток
```

2. Публикация immutable-объектов:
```java
private volatile ImmutableObject instance;

public ImmutableObject getInstance() {
    if (instance == null) {
        instance = new ImmutableObject(); // безопасная публикация
    }
    return instance;
}
```

3. Одиночные атомарные операции (чтение/запись примитивов или ссылок).

Когда применять `synchronized`

1. Составные операции (read-modify-write):
```java
private int counter = 0;

public synchronized void increment() {
    counter++; // без synchronized было бы небезопасно
}
```

2. Неатомарные операции с несколькими переменными:
```java
private int x, y;

public synchronized void setValues(int x, int y) {
    this.x = x;
    this.y = y; // гарантирует, что оба значения установятся атомарно
}
```

3. Доступ к сложным структурам данных:
```java
private List<String> list = new ArrayList<>();

public synchronized void addItem(String item) {
    list.add(item); // ArrayList не потокобезопасен
}
```  

Комбинированный подход

Иногда используют оба механизма вместе (шаблон "двойной проверки" для ленивой инициализации):
```java
private volatile Singleton instance;

public Singleton getInstance() {
    if (instance == null) {
        synchronized (Singleton.class) {
            if (instance == null) {
                instance = new Singleton();
            }
        }
    }
    return instance;
}
```

_Вывод_

- Используйте volatile для простых операций с одним полем, где важна видимость изменений.
- Используйте synchronized для сложных операций или когда нужно обеспечить атомарность нескольких действий.

<hr>

### Проблемы многопоточности и способы их избежания

1. Deadlock (Взаимная блокировка)

Что это: Ситуация, когда два или более потока бесконечно ожидают ресурсы, захваченные друг другом.

Пример:
```java
// Поток 1
synchronized (A) {
    synchronized (B) { ... }
}

// Поток 2
synchronized (B) {
    synchronized (A) { ... }
}
```

**Как избежать:**
- Упорядочивание блокировок: Всегда захватывать блокировки в одном и том же порядке
- Таймауты: Использовать tryLock() с таймаутом вместо synchronized
- Избегание вложенных блокировок: По возможности уменьшать количество блокировок
- Использование concurrent-коллекций: ConcurrentHashMap вместо synchronized блоков
  
2. Livelock (Активная блокировка)

Что это: Потоки не блокируются, но постоянно меняют свое состояние в ответ на действия друг друга, не продвигаясь в работе.

Пример:
```java
// Два потока пытаются "уступить" друг другу
while (!acquireLock()) {
    Thread.yield(); // Постоянно уступают друг другу
}
```

**Как избежать:**
- Рандомизация: Добавить случайные задержки между попытками
- Приоритеты: Определить четкие приоритеты доступа
- Координация: Использовать более высокоуровневые механизмы синхронизации
- Ограничение попыток: Ввести максимальное количество попыток

3. Race Condition (Состояние гонки)

Что это: Поведение программы зависит от порядка выполнения потоков, что приводит к недетерминированным результатам.

Пример:
```java
if (!initialized) { // Race condition
    initialize(); 
    initialized = true;
}
```

**Как избежать:**

- Синхронизация: Использовать synchronized блоки или методы
- Атомарные операции: AtomicInteger, AtomicReference и др.
- Неизменяемые объекты: Использовать immutable-объекты там, где возможно
- Потокобезопасные коллекции: ConcurrentHashMap, CopyOnWriteArrayList
- Волатильные переменные: Для простых случаев с volatile


**Общие рекомендации**

1. Минимизируйте shared состояние: Лучшая синхронизация - ее отсутствие
2. Используйте higher-level механизмы:
  - ExecutorService вместо ручного управления потоками
  - CountDownLatch, CyclicBarrier, Semaphore
  - CompletableFuture для асинхронных операций
3. Неизменяемость: final поля, immutable объекты
4.Атомарные классы: AtomicInteger, AtomicReference и др.
5.Тестирование: Stress-тестирование многопоточного кода
1. Анализ кода: Использование статических анализаторов (FindBugs, SpotBugs)
2. Документирование: Четко документировать потокобезопасность классов

**Пример безопасного подхода**

```java
// Вместо synchronized-блоков:
private final ConcurrentMap<String, Object> cache = new ConcurrentHashMap<>();

public Object get(String key) {
    return cache.computeIfAbsent(key, k -> createExpensiveObject(k));
}

// Вместо ручной синхронизации счетчика:
private final AtomicInteger counter = new AtomicInteger();

public void increment() {
    counter.incrementAndGet();
}
```
Правильный выбор стратегии синхронизации зависит от конкретного сценария использования и требований к производительности.

<hr>

### Атомарные типы (AtomicInteger и др.) vs synchronized

Основные преимущества атомарных классов

**Производительность**
- Атомарные классы используют низкоуровневые CPU-инструкции (CAS - Compare-And-Swap)
- synchronized требует блокировки на уровне JVM, что более тяжеловесно

Пример сравнения:

```java
// С synchronized
private int counter = 0;
public synchronized void increment() {
    counter++;
}

// С AtomicInteger
private AtomicInteger counter = new AtomicInteger(0);
public void increment() {
    counter.incrementAndGet();
}
// Второй вариант будет быстрее в условиях высокой конкуренции
```

**Отсутствие блокировок (lock-free)**

- Atomic классы реализуют неблокирующие алгоритмы
- synchronized всегда приводит к блокировке потока

**Более тонкий контроль**

Методы типа compareAndSet(), getAndUpdate() позволяют реализовывать сложные неблокирующие алгоритмы

```java
AtomicReference<String> ref = new AtomicReference<>("old");

// Условное обновление
boolean updated = ref.compareAndSet("old", "new");
```

**Когда атомарные классы лучше**
- Простые атомарные операции (инкремент, декремент, обновление)
- Высококонкурентные сценарии (много потоков, мало блокировок)
- Реализация неблокирующих алгоритмов
- Счетчики, флаги, простые состояния

**Когда synchronized предпочтительнее**

Сложные составные операции (несколько действий должны быть атомарными)

```java
public synchronized void transfer(Account from, Account to, int amount) {
    from.withdraw(amount);
    to.deposit(amount);
}
```

Работа с не-thread-safe коллекциями

```java
synchronized(list) {
    if (!list.contains(item)) {
        list.add(item);
    }
}
```

Когда нужно синхронизировать несколько методов/операций вместе

**Ограничения атомарных классов**

- Нет возможности для сложных составных операций
- Могут возникнуть проблемы с ABA (хотя в Java это редко критично)
- Не подходят для синхронизации нескольких переменных/операций

**Современные альтернативы**

Java 8+ предлагает дополнительные варианты:
```java
// Для сложных обновлений
AtomicInteger counter = new AtomicInteger();
counter.updateAndGet(x -> x * 2);

// LongAdder для высококонкурентных счетчиков
LongAdder adder = new LongAdder();
adder.increment();
```

**Вывод**

Используйте Atomic классы, когда:
- Нужны простые атомарные операции
- Важна высокая производительность при конкуренции
- Можно обойтись одиночными операциями

Используйте synchronized, когда:
- Нужны сложные составные операции
- Требуется синхронизировать доступ к нескольким полям/методам
- Работаете с legacy-кодом или не-thread-safe объектами

Для большинства случаев счетчиков и простых состояний Atomic-классы - более производительная и удобная альтернатива synchronized.

<hr>

### Разница между Runnable и Callable в Java

**Основные различия**

| Характеристика        | Runnable                                | Callable<V>                          |
| --------------------- | --------------------------------------- | ------------------------------------ |
| Пакет                 | java.lang                               | java.util.concurrent                 |
| Возвращаемое значение | Нет (void)                              | Есть (тип V)                         |
| Исключения            | Не может выбрасывать checked-исключения | Может выбрасывать checked-исключения |
| Метод                 | run()                                   | call()                               |
| Использование         | Классические потоки                     | ExecutorService, Future              |
| Версия Java           | С Java 1.0                              | С Java 5 (1.5)                       |


**Примеры реализации**

Runnable
```java
Runnable task = new Runnable() {
    @Override
    public void run() {
        System.out.println("Выполняется Runnable задача");
    }
};

// Или с лямбдой:
Runnable lambdaTask = () -> System.out.println("Runnable лямбда");
```

Callable
```java
Callable<String> task = new Callable<String>() {
    @Override
    public String call() throws Exception {
        return "Результат Callable задачи";
    }
};

// Или с лямбдой:
Callable<String> lambdaTask = () -> {
    if (Math.random() > 0.5) {
        throw new IOException("Проверяемое исключение");
    }
    return "Callable лямбда";
};
```

**Когда что использовать**

Используйте Runnable, когда:
- Нужно просто выполнить код в отдельном потоке
- Не требуется возвращать результат
- Не нужно обрабатывать checked-исключения внутри задачи
- Работаете с классическим Thread

Используйте Callable, когда:
- Нужно получить результат из потока
- Требуется обрабатывать checked-исключения
- Работаете с ExecutorService и Future
- Нужна возможность отмены задачи через Future.cancel()

**Примеры с ExecutorService**

```java
ExecutorService executor = Executors.newSingleThreadExecutor();

// Runnable
Future<?> future1 = executor.submit(() -> {
    System.out.println("Runnable задача");
});

// Callable
Future<String> future2 = executor.submit(() -> {
    Thread.sleep(1000);
    return "Результат Callable";
});

try {
    System.out.println(future2.get()); // Блокирует пока задача не завершится
} catch (ExecutionException e) {
    // Обработка исключений из call()
}
executor.shutdown();
```

**Важные особенности**

Исключения:
- В Runnable исключения нужно обрабатывать внутри run()
- Callable может пробрасывать исключения через Future.get()

Future:
- Callable возвращает Future, который позволяет получить результат или исключение
- Runnable при использовании с ExecutorService.submit() возвращает Future<?>, который может только указывать на завершение задачи

Отмена выполнения:
- Оба типа задач можно отменять через Future.cancel()
- Callable обычно лучше подходит для отменяемых задач


**Совместимость**

Начиная с Java 8, оба интерфейса являются функциональными, поэтому их можно реализовывать через лямбда-выражения:

```java
ExecutorService executor = Executors.newCachedThreadPool();

// Runnable как лямбда
executor.submit(() -> System.out.println("Runnable"));

// Callable как лямбда
Future<Integer> future = executor.submit(() -> {
    TimeUnit.SECONDS.sleep(1);
    return 42;
});
```

<hr>

### Что такое ThreadLocal, для чего нужен

`ThreadLocal` — это специальный класс в Java, который предоставляет локальные переменные потока. Это означает, что каждое значение, хранящееся в ThreadLocal, доступно только для одного конкретного потока и изолировано от других потоков.

**Для чего нужен ThreadLocal**

Основные сценарии использования:
- Хранение контекста потока (например, пользовательской сессии в веб-приложении)
- Избегание синхронизации при работе с не-потокобезопасными объектами
- Передача параметров вглубь цепочки вызовов без явной передачи через аргументы
- Кэширование временных данных, специфичных для потока

**Как работает ThreadLocal**

Каждый поток имеет свою собственную копию переменной:
- При первом вызове get() инициализируется значение (через initialValue())
- Последующие вызовы get() возвращают значение для текущего потока
- set() изменяет значение только для текущего потока

Пример использования
```java
public class ThreadLocalExample {
    // Создаем ThreadLocal с начальным значением
    private static final ThreadLocal<Integer> threadLocalCounter = 
        ThreadLocal.withInitial(() -> 0);
    
    public static void main(String[] args) {
        // Запускаем несколько потоков
        for (int i = 0; i < 3; i++) {
            new Thread(() -> {
                // Увеличиваем счетчик для каждого потока
                int counter = threadLocalCounter.get();
                threadLocalCounter.set(counter + 1);
                
                // Выводим значение (у каждого потока свое)
                System.out.println(Thread.currentThread().getName() 
                    + ": " + threadLocalCounter.get());
            }).start();
        }
    }
}
```
Вывод может выглядеть так:
```
Thread-0: 1
Thread-1: 1
Thread-2: 1
```

**Практические примеры использования**

Веб-приложения (хранение информации о пользователе):
```java
public class UserContextHolder {
    private static final ThreadLocal<User> currentUser = new ThreadLocal<>();
    
    public static void setUser(User user) {
        currentUser.set(user);
    }
    
    public static User getUser() {
        return currentUser.get();
    }
    
    public static void clear() {
        currentUser.remove();
    }
}
```

Форматирование дат (SimpleDateFormat не потокобезопасен):
```java
public class DateFormatter {
    private static final ThreadLocal<SimpleDateFormat> formatter = 
        ThreadLocal.withInitial(() -> new SimpleDateFormat("yyyy-MM-dd"));
    
    public static String format(Date date) {
        return formatter.get().format(date);
    }
}
```

**Важные особенности**

Память:
- Значения хранятся в памяти до завершения потока
- Может приводить к утечкам памяти в пулах потоков
- Всегда вызывайте remove() после завершения работы

Наследование:
- По умолчанию значения не передаются дочерним потокам
- Для наследования используйте InheritableThreadLocal

Производительность:
- Доступ к ThreadLocal быстрее, чем синхронизация
- Под капотом используется быстрый хэш-массив в классе Thread


**Очистка ресурсов**

Всегда очищайте ThreadLocal после использования, особенно в веб-приложениях и при использовании пулов потоков:
```java
try {
    // Используем ThreadLocal
    threadLocal.set(someValue);
    // ... работа со значением
} finally {
    threadLocal.remove(); // Важно!
}
```
