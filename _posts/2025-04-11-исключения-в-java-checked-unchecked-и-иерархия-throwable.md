---
layout: post
title: 'Исключения в Java: checked/unchecked и иерархия Throwable'
date: '2025-04-11 18:34:43 +0300'
author: <author_id>
categories: [Java]
tags: [faq]
description: Часто встечающиюся вопросы о Java
---

### Иерархия классов исключений

В Java все исключения являются подклассами базового класса Throwable:

```
Throwable
├── Error (непроверяемые)
│   ├── VirtualMachineError
│   │   ├── OutOfMemoryError
│   │   └── StackOverflowError
│   └── ...
├── Exception
│   ├── RuntimeException (непроверяемые)
│   │   ├── NullPointerException
│   │   ├── IndexOutOfBoundsException
│   │   ├── IllegalArgumentException
│   │   └── ...
│   └── Проверяемые исключения
│       ├── IOException
│       │   ├── FileNotFoundException
│       │   └── ...
│       ├── SQLException
│       └── ...
└── ...
```

### Проверяемые (checked) vs непроверяемые (unchecked) исключения
#### Проверяемые исключения (checked exceptions)

- Наследуются от Exception (но не от RuntimeException)
- Должны быть обработаны или объявлены в сигнатуре метода (throws)
- Примеры: IOException, SQLException, ClassNotFoundException

```java
// Должны либо обработать
try {
    FileReader file = new FileReader("file.txt");
} catch (FileNotFoundException e) {
    e.printStackTrace();
}

// Либо объявить в throws
public void readFile() throws FileNotFoundException {
    FileReader file = new FileReader("file.txt");
}
```

#### Непроверяемые исключения (unchecked exceptions)

- Наследуются от RuntimeException или Error
- Не требуют явной обработки или объявления
- Примеры: NullPointerException, ArrayIndexOutOfBoundsException, ArithmeticException

```java
// Можно не обрабатывать
public void example() {
    String str = null;
    System.out.println(str.length()); // NullPointerException
}
```

### Когда использовать какие исключения

**Проверяемые исключения** следует использовать для:

- Ожидаемых ошибок, которые программа может корректно обработать
- Ситуаций, когда вызывающий код должен быть осведомлен о возможной ошибке

**Непроверяемые исключения** подходят для:

- Ошибок программирования (например, NPE)
- Ситуаций, которые обычно невозможно обработать корректно
- Нарушений контрактов методов (например, неверные аргументы)

#### Лучшие практики работы с исключениями

- Не игнорируйте исключения в блоках catch
- Используйте наиболее конкретный тип исключения
- Документируйте исключения, которые может выбрасывать ваш метод
- Не используйте исключения для управления потоком выполнения
- При создании собственных исключений наследуйтесь от подходящего базового класса

<hr>

### Как работает блок finally, может ли не вызываться

Блок finally - это часть конструкции try-catch-finally, которая гарантированно выполняется после try и catch блоков, независимо от того, было ли выброшено исключение.

```java
try {
    // Код, который может вызвать исключение
} catch (ExceptionType e) {
    // Обработка исключения
} finally {
    // Этот код выполнится в любом случае
    // Обычно здесь размещают код освобождения ресурсов
}
```

### Когда блок finally может НЕ вызваться

Хотя `finally` считается "гарантированно" выполняемым блоком, есть несколько исключительных ситуаций, когда он не выполнится:

1. Принудительное завершение JVM:

     - Вызов System.exit()
     - Аварийное завершение JVM (крах)
       ```java
         try {
             System.exit(0); // finally не выполнится
         } finally {
             System.out.println("Это не будет напечатано");
         }
       ```
2. Фатальные ошибки (Error):

     - Некоторые критические ошибки JVM (OutOfMemoryError, StackOverflowError)
       ```java
         try {
             throw new StackOverflowError();
         } finally {
             System.out.println("Может не выполниться при фатальных ошибках");
         }
       ```
3. Бесконечный цикл или deadlock:

     - Если поток заблокирован навсегда в try-блоке
       ```java
         try {
             while (true) {} // Бесконечный цикл
         } finally {
             System.out.println("Не выполнится, пока работает цикл");
         }
       ```
4. Принудительное завершение потока:

    - Вызов Thread.stop() (устаревший и опасный метод)

### Особенности работы finally

1. Возврат значений:
     - Если в try и finally есть return, выполнится return из finally
2. Изменение возвращаемого значения:
     - Можно изменить значение, которое будет возвращено
     - ```java 
         public int example() {
           int x = 0;
           try {
               return x; // запоминается значение 0 для возврата
           } finally {
               x = 1; // но возвращено будет 0, так как значение уже сохранено
           }
       }
       ```

<hr>

### Try-with-resources в Java: как закрываются ресурсы

#### Основной принцип работы
`Try-with-resources` - это специальная форма оператора try, представленная в Java 7, которая автоматически закрывает ресурсы, реализующие интерфейс `AutoCloseable`.

#### Как происходит закрытие ресурсов
Порядок закрытия:
  - Ресурсы закрываются в порядке, обратном их созданию
  - Если при закрытии одного ресурса возникает исключение, оно не мешает закрытию остальных

Механизм работы:
  - Компилятор добавляет блок finally, в котором вызывается close()
  - Если в блоке try и при закрытии возникли исключения, исключение из try добавляется в подавленные исключения
  
#### Особенности закрытия ресурсов
Обязательные условия:
  - Ресурс должен реализовывать интерфейс AutoCloseable (введен в Java 7) или Closeable (существовал ранее)

Исключения при закрытии:
  - Если исключение возникает и в блоке try, и при закрытии, исключение из try будет основным, а исключение при закрытии добавится к нему как подавленное

Доступ к ресурсам:
  - В Java 9+ можно использовать переменные вне блока try:
  - ```java
      InputStream in = new FileInputStream("file.txt");
    try (in) { // работает в Java 9+
        // работа с ресурсом
    }
    ```

### Пример с подавленными исключениями
```java
try (ProblematicResource res = new ProblematicResource()) {
    throw new RuntimeException("Ошибка в try");
} // При закрытии тоже возникает исключение
```

В этом случае:
- Основным будет RuntimeException("Ошибка в try")
- Исключение при закрытии можно получить через getSuppressed()

<hr>

### Multi-catch в Java: ловля нескольких исключений в одном блоке catch
Да, в Java (начиная с версии 7) можно перехватывать несколько исключений в одном блоке `catch`. Эта функция называется `multi-catch`.

**Синтаксис multi-catch**
```java
try {
    // Код, который может вызвать разные исключения
} catch (IOException | SQLException | ParseException e) {
    // Обработка всех перечисленных исключений
    System.out.println("Произошла ошибка ввода-вывода или работы с БД: " + e.getMessage());
}
```

### Особенности multi-catch
Разделение типов исключений:
- Типы исключений разделяются вертикальной чертой `(|)`
- Можно указывать сколько угодно исключений

Ограничения:
- Нельзя ловить исключения, если одно является подклассом другого
- `catch (FileNotFoundException | IOException e) {} // Ошибка компиляции!`
- В multi-catch нельзя использовать взаимозависимые исключения

Общая переменная исключения:
- Все перехваченные исключения используют одну переменную (e в примере)
- Переменная является неявно final

Проверка типа:

- Можно проверять конкретный тип исключения внутри блока:
- ```java
  catch (IOException | SQLException e) {
      if (e instanceof IOException) {
          // обработка IOException
      } else {
          // обработка SQLException
      }
  }
  ```

#### Преимущества multi-catch
- Уменьшение дублирования кода:
  - Если обработка для разных исключений одинаковая, не нужно писать несколько блоков catch
- Улучшение читаемости:
  - Код становится более компактным и понятным
- Сохранение стека вызовов:
  - В отличие от перехвата общего предка (например, Exception), multi-catch сохраняет информацию о конкретных типах исключений

`Multi-catch` - это удобная функция, которая помогает писать более чистый и лаконичный код при обработке исключений.

<hr>

### Как создать собственный (кастомный) Exception

Создание пользовательских исключений позволяет точнее отражать специфические ошибки вашего приложения и улучшает обработку ошибок.

Базовые способы создания
1. Простое пользовательское исключение (наследование от Exception)
```java
public class MyException extends Exception {
    public MyException() {
        super();
    }

    public MyException(String message) {
        super(message);
    }

    public MyException(String message, Throwable cause) {
        super(message, cause);
    }

    public MyException(Throwable cause) {
        super(cause);
    }
}
```
2. Непроверяемое исключение (наследование от RuntimeException)
```java
public class MyUncheckedException extends RuntimeException {
    public MyUncheckedException() {
        super();
    }

    public MyUncheckedException(String message) {
        super(message);
    }
    
    // Другие полезные конструкторы
}
```

### Лучшие практики создания собственных исключений
- Выбор базового класса:
  - Наследуйтесь от Exception для проверяемых исключений
  - Наследуйтесь от RuntimeException для непроверяемых
- Добавление полезных конструкторов:
  - Всегда включайте конструкторы с сообщением и причиной
  - Это соответствует стандартной практике Java
- Добавление дополнительной информации:
  ```java
  public class PaymentException extends Exception {
      private final BigDecimal amount;
      
      public PaymentException(String message, BigDecimal amount) {
          super(message);
          this.amount = amount;
      }
      
      public BigDecimal getAmount() {
          return amount;
      }
  }
  ```
- Сериализация:
  - Добавьте serialVersionUID для исключений, которые могут сериализоваться
    ```java
    private static final long serialVersionUID = 1L;
    ```

**Пример использования**
```java
public class AgeValidationException extends IllegalArgumentException {
    private final int invalidAge;
    
    public AgeValidationException(String message, int invalidAge) {
        super(message);
        this.invalidAge = invalidAge;
    }
    
    public int getInvalidAge() {
        return invalidAge;
    }
}

// Использование
public void setAge(int age) {
    if (age < 0 || age > 150) {
        throw new AgeValidationException("Недопустимый возраст", age);
    }
    this.age = age;
}
```

#### Когда создавать собственные исключения
- Когда вам нужно передать дополнительную информацию об ошибке
- Когда стандартные исключения недостаточно точно описывают ошибку
- Когда вы хотите специфическую обработку для определенных типов ошибок
- Когда вы разрабатываете API и хотите предоставить четкую схему обработки ошибок

<hr>
