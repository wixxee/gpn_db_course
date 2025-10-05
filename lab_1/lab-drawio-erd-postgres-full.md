# Лабораторная работа: Проектирование реляционной базы данных

## Тема: Построение ER-диаграммы в Draw.io, создание реляционной схемы и нормализация в PostgreSQL

### Цель работы

Освоить полный цикл проектирования реляционной базы данных:
- Создание ER-диаграммы в онлайн-редакторе Draw.io
- Преобразование концептуальной модели в реляционную схему
- Применение принципов нормализации для оптимизации структуры данных
- Физическая реализация схемы в СУБД PostgreSQL

---

## Теоретические основы

### 1. ER-модель (Entity-Relationship Model)

**ER-диаграмма** — графическая модель, описывающая сущности предметной области и связи между ними.

**Основные компоненты:**

#### 1.1. Сущности (Entities)
- **Сильные сущности** — независимые объекты со своими первичными ключами
- **Слабые сущности** — зависят от других сущностей для идентификации
- **Обозначение:** прямоугольник

#### 1.2. Атрибуты (Attributes)
- **Простые атрибуты** — неделимые значения
- **Составные атрибуты** — состоят из нескольких компонентов
- **Многозначные атрибуты** — могут иметь несколько значений
- **Производные атрибуты** — вычисляются из других атрибутов
- **Ключевые атрибуты** — уникально идентифицируют сущность
- **Обозначение:** овал (подчеркнутые для ключевых)

#### 1.3. Связи (Relationships)
- **Один к одному (1:1)** — каждому экземпляру первой сущности соответствует максимум один экземпляр второй
- **Один ко многим (1:N)** — одному экземпляру первой сущности соответствует много экземпляров второй
- **Многие ко многим (M:N)** — много экземпляров первой сущности связано с множеством экземпляров второй
- **Обозначение:** ромб

### 2. Нотации ER-диаграмм

#### 2.1. Нотация Чена (Chen Notation)
- Классическая нотация
- Сущности: прямоугольники
- Атрибуты: овалы
- Связи: ромбы
- Четкое разделение всех элементов

#### 2.2. Нотация Crow's Foot (Мартина)
- Современная компактная нотация
- Сущности: прямоугольники с атрибутами внутри
- Связи: линии со специальными символами
- Кардинальность: "воронья лапка", черточки, кружки
- **Рекомендуется для Draw.io**

### 3. Принципы нормализации

#### 3.1. Первая нормальная форма (1НФ)
- Все атрибуты должны быть атомарными
- Исключение повторяющихся групп
- Каждая строка должна быть уникальной

#### 3.2. Вторая нормальная форма (2НФ)
- Таблица находится в 1НФ
- Каждый неключевой атрибут полностью зависит от первичного ключа
- Устранение частичных функциональных зависимостей

#### 3.3. Третья нормальная форма (3НФ)
- Таблица находится в 2НФ
- Отсутствие транзитивных зависимостей
- Каждый неключевой атрибут непосредственно зависит от первичного ключа

---

## Практическое задание

### Предметная область: Система управления библиотекой

**Описание:** Создать базу данных для автоматизации работы университетской библиотеки.

**Бизнес-правила:**
1. В библиотеке есть читатели (студенты и преподаватели)
2. Книги организованы по категориям
3. Читатели могут брать книги во временное пользование
4. Ведется учет выдачи и возврата книг
5. За просроченные книги начисляются штрафы
6. Авторы могут написать несколько книг
7. Книги могут иметь нескольких авторов

---

## ЭТАП 1: Создание ER-диаграммы в Draw.io

### 1.1. Подготовка к работе

1. Откройте браузер и перейдите на сайт [https://app.diagrams.net](https://app.diagrams.net) (Draw.io)
2. Выберите способ сохранения:
   - Device (на устройство)
   - Google Drive
   - OneDrive
   - GitHub
3. Создайте новую диаграмму: "Create New Diagram"
4. Выберите шаблон "Entity Relation" или "Crow's Foot Notation"

### 1.2. Определение сущностей

**Основные сущности:**
- **Читатель** (Reader)
- **Книга** (Book)  
- **Автор** (Author)
- **Категория** (Category)
- **Выдача** (Loan)
- **Штраф** (Fine)

### 1.3. Определение атрибутов

**Читатель:**
- reader_id (PK) — первичный ключ
- last_name — фамилия
- first_name — имя
- middle_name — отчество
- reader_type — тип (студент/преподаватель)
- phone — телефон
- email — электронная почта
- registration_date — дата регистрации

**Книга:**
- book_id (PK) — первичный ключ
- title — название
- isbn — международный номер
- publication_year — год издания
- pages — количество страниц
- copies_total — общее количество экземпляров
- copies_available — доступные экземпляры
- category_id (FK) — внешний ключ категории

**Автор:**
- author_id (PK) — первичный ключ
- last_name — фамилия
- first_name — имя
- middle_name — отчество
- birth_year — год рождения
- country — страна

**Категория:**
- category_id (PK) — первичный ключ
- name — название категории
- description — описание

**Выдача:**
- loan_id (PK) — первичный ключ
- reader_id (FK) — читатель
- book_id (FK) — книга
- loan_date — дата выдачи
- due_date — дата возврата
- return_date — фактическая дата возврата
- status — статус (выдана/возвращена)

**Штраф:**
- fine_id (PK) — первичный ключ
- loan_id (FK) — выдача
- amount — сумма штрафа
- fine_date — дата штрафа
- paid — оплачен ли

### 1.4. Пошаговое создание диаграммы в Draw.io

#### Шаг 1: Добавление сущностей
1. На панели слева найдите раздел "Entity Relation"
2. Перетащите прямоугольник "Entity" на рабочую область
3. Двойным кликом отредактируйте название: "Читатель"
4. Добавьте атрибуты внутри прямоугольника:
   ```
   reader_id (PK)
   last_name
   first_name
   middle_name
   reader_type
   phone
   email
   registration_date
   ```
5. Повторите для всех остальных сущностей

#### Шаг 2: Форматирование сущностей
1. Выделите сущность
2. В панели свойств справа настройте:
   - Цвет заливки
   - Цвет границы
   - Шрифт
3. Для ключевых атрибутов используйте **жирный шрифт** или подчеркивание

#### Шаг 3: Создание связей
1. Найдите на панели элемент "Relationship" или "Connector"
2. Проведите линию от одной сущности к другой
3. Установите тип связи в свойствах линии
4. Добавьте подписи к связям

**Связи в нашей модели:**
- Читатель ← Выдача (1:N)
- Книга ← Выдача (1:N)
- Категория ← Книга (1:N)
- Выдача ← Штраф (1:1)
- Автор ↔ Книга (M:N) — через промежуточную таблицу

#### Шаг 4: Настройка кардинальности
Для нотации Crow's Foot используйте символы на концах линий:
- **Один (1):** вертикальная черточка ||
- **Ноль или один (0..1):** кружок с черточкой o|
- **Много (N):** "воронья лапка" }<
- **Ноль или много (0..N):** кружок с лапкой o}<

#### Шаг 5: Добавление промежуточной сущности для M:N
Для связи "Автор ↔ Книга" создайте сущность "Авторство":
- **Авторство** (Book_Author)
  - author_id (PK, FK)
  - book_id (PK, FK)

### 1.5. Финальная настройка диаграммы
1. Используйте автоматическое выравнивание: Arrange → Auto Layout
2. Добавьте заголовок диаграммы
3. Проверьте читаемость всех элементов
4. Сохраните файл: File → Save As → выберите формат .drawio

### 1.6. Экспорт диаграммы
1. File → Export as → PNG (для отчета)
2. Настройте разрешение: 300 DPI для высокого качества
3. Сохраните также в формате PDF для печати

---

## ЭТАП 2: Преобразование ER-диаграммы в реляционную схему

### 2.1. Правила преобразования

#### Правило 1: Сущности → Таблицы
Каждая сущность становится отдельной таблицей

#### Правило 2: Атрибуты → Столбцы
Атрибуты сущностей становятся столбцами таблиц

#### Правило 3: Связи 1:N
Внешний ключ размещается в таблице со стороны "много"

#### Правило 4: Связи M:N
Создается отдельная таблица-связь с внешними ключами обеих таблиц

#### Правило 5: Связи 1:1
Внешний ключ может быть в любой из таблиц (выбор зависит от логики)

### 2.2. Результирующие таблицы

```
READERS (reader_id, last_name, first_name, middle_name, reader_type, phone, email, registration_date)

CATEGORIES (category_id, name, description)

BOOKS (book_id, title, isbn, publication_year, pages, copies_total, copies_available, category_id*)

AUTHORS (author_id, last_name, first_name, middle_name, birth_year, country)

BOOK_AUTHORS (book_id*, author_id*) — составной первичный ключ

LOANS (loan_id, reader_id*, book_id*, loan_date, due_date, return_date, status)

FINES (fine_id, loan_id*, amount, fine_date, paid)
```

где * обозначает внешние ключи

---

## ЭТАП 3: Реализация в PostgreSQL

### 3.1. Создание схемы базы данных

```sql
-- Создание схемы для библиотеки
CREATE SCHEMA IF NOT EXISTS library;
SET search_path TO library, public;

-- Создание таблицы КАТЕГОРИИ
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

-- Создание таблицы ЧИТАТЕЛИ
CREATE TABLE readers (
    reader_id SERIAL PRIMARY KEY,
    last_name VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    middle_name VARCHAR(50),
    reader_type VARCHAR(20) NOT NULL CHECK (reader_type IN ('студент', 'преподаватель')),
    phone VARCHAR(20),
    email VARCHAR(100) UNIQUE,
    registration_date DATE DEFAULT CURRENT_DATE
);

-- Создание таблицы АВТОРЫ
CREATE TABLE authors (
    author_id SERIAL PRIMARY KEY,
    last_name VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    middle_name VARCHAR(50),
    birth_year INTEGER CHECK (birth_year BETWEEN 1000 AND EXTRACT(YEAR FROM CURRENT_DATE)),
    country VARCHAR(50)
);

-- Создание таблицы КНИГИ
CREATE TABLE books (
    book_id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    isbn VARCHAR(20) UNIQUE,
    publication_year INTEGER CHECK (publication_year BETWEEN 1000 AND EXTRACT(YEAR FROM CURRENT_DATE)),
    pages INTEGER CHECK (pages > 0),
    copies_total INTEGER NOT NULL CHECK (copies_total > 0),
    copies_available INTEGER NOT NULL CHECK (copies_available >= 0),
    category_id INTEGER NOT NULL,
    FOREIGN KEY (category_id) REFERENCES categories(category_id),
    CONSTRAINT check_available_copies CHECK (copies_available <= copies_total)
);

-- Создание таблицы АВТОРСТВО (связь многие-ко-многим)
CREATE TABLE book_authors (
    book_id INTEGER NOT NULL,
    author_id INTEGER NOT NULL,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES authors(author_id) ON DELETE CASCADE
);

-- Создание таблицы ВЫДАЧИ
CREATE TABLE loans (
    loan_id SERIAL PRIMARY KEY,
    reader_id INTEGER NOT NULL,
    book_id INTEGER NOT NULL,
    loan_date DATE NOT NULL DEFAULT CURRENT_DATE,
    due_date DATE NOT NULL,
    return_date DATE,
    status VARCHAR(20) DEFAULT 'выдана' CHECK (status IN ('выдана', 'возвращена', 'просрочена')),
    FOREIGN KEY (reader_id) REFERENCES readers(reader_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id),
    CONSTRAINT check_due_date CHECK (due_date > loan_date),
    CONSTRAINT check_return_date CHECK (return_date IS NULL OR return_date >= loan_date)
);

-- Создание таблицы ШТРАФЫ
CREATE TABLE fines (
    fine_id SERIAL PRIMARY KEY,
    loan_id INTEGER NOT NULL UNIQUE,
    amount DECIMAL(10,2) NOT NULL CHECK (amount > 0),
    fine_date DATE NOT NULL DEFAULT CURRENT_DATE,
    paid BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id) ON DELETE CASCADE
);

-- Создание индексов для оптимизации запросов
CREATE INDEX idx_books_category ON books(category_id);
CREATE INDEX idx_books_title ON books(title);
CREATE INDEX idx_loans_reader ON loans(reader_id);
CREATE INDEX idx_loans_book ON loans(book_id);
CREATE INDEX idx_loans_dates ON loans(loan_date, due_date);
CREATE INDEX idx_readers_type ON readers(reader_type);
CREATE INDEX idx_readers_name ON readers(last_name, first_name);
```

### 3.2. Заполнение тестовыми данными

```sql
-- Вставка категорий
INSERT INTO categories (name, description) VALUES 
('Художественная литература', 'Романы, повести, рассказы'),
('Научная литература', 'Научные труды и исследования'),
('Техническая литература', 'Технические справочники и пособия'),
('Учебная литература', 'Учебники и учебные пособия'),
('Справочная литература', 'Энциклопедии, словари, справочники');

-- Вставка читателей
INSERT INTO readers (last_name, first_name, middle_name, reader_type, phone, email) VALUES 
('Иванов', 'Петр', 'Сергеевич', 'студент', '+7-915-123-45-67', 'ivanov@student.edu'),
('Петрова', 'Анна', 'Викторовна', 'преподаватель', '+7-915-234-56-78', 'petrova@university.edu'),
('Сидоров', 'Михаил', 'Александрович', 'студент', '+7-915-345-67-89', 'sidorov@student.edu'),
('Козлова', 'Елена', 'Дмитриевна', 'преподаватель', '+7-915-456-78-90', 'kozlova@university.edu');

-- Вставка авторов
INSERT INTO authors (last_name, first_name, middle_name, birth_year, country) VALUES 
('Пушкин', 'Александр', 'Сергеевич', 1799, 'Россия'),
('Толстой', 'Лев', 'Николаевич', 1828, 'Россия'),
('Достоевский', 'Федор', 'Михайлович', 1821, 'Россия'),
('Гете', 'Иоганн', 'Вольфганг', 1749, 'Германия'),
('Шекспир', 'Уильям', NULL, 1564, 'Англия');

-- Вставка книг
INSERT INTO books (title, isbn, publication_year, pages, copies_total, copies_available, category_id) VALUES 
('Евгений Онегин', '978-5-389-06623-7', 2018, 224, 5, 3, 1),
('Война и мир', '978-5-17-085394-3', 2019, 1360, 3, 2, 1),
('Преступление и наказание', '978-5-04-089339-8', 2020, 672, 4, 4, 1),
('Фауст', '978-5-699-12345-6', 2017, 512, 2, 1, 1),
('Гамлет', '978-5-389-54321-9', 2021, 320, 3, 3, 1);

-- Связывание книг с авторами
INSERT INTO book_authors (book_id, author_id) VALUES 
(1, 1), -- Евгений Онегин - Пушкин
(2, 2), -- Война и мир - Толстой
(3, 3), -- Преступление и наказание - Достоевский
(4, 4), -- Фауст - Гете
(5, 5); -- Гамлет - Шекспир

-- Вставка выдач
INSERT INTO loans (reader_id, book_id, loan_date, due_date, return_date, status) VALUES 
(1, 1, '2024-09-01', '2024-09-15', '2024-09-14', 'возвращена'),
(2, 2, '2024-09-05', '2024-09-19', NULL, 'выдана'),
(3, 3, '2024-08-20', '2024-09-03', NULL, 'просрочена'),
(1, 4, '2024-09-10', '2024-09-24', NULL, 'выдана');

-- Вставка штрафов
INSERT INTO fines (loan_id, amount, fine_date, paid) VALUES 
(3, 150.00, '2024-09-04', FALSE); -- штраф за просроченную книгу
```

---

## ЭТАП 4: Анализ нормализации

### 4.1. Проверка соответствия нормальным формам

#### Первая нормальная форма (1НФ)
✅ **Выполнена:** Все атрибуты содержат атомарные значения
- Нет многозначных атрибутов
- Нет повторяющихся групп
- Каждая строка уникальна

#### Вторая нормальная форма (2НФ)
✅ **Выполнена:** Каждый неключевой атрибут полностью зависит от первичного ключа
- В таблице `book_authors` составной ключ (book_id, author_id)
- Частичных зависимостей нет

#### Третья нормальная форма (3НФ)
✅ **Выполнена:** Отсутствуют транзитивные зависимости
- Информация о категории вынесена в отдельную таблицу `categories`
- Информация об авторах вынесена в отдельную таблицу `authors`
- Каждый неключевой атрибут зависит только от первичного ключа

### 4.2. Пример денормализации (для сравнения)

**Ненормализованная таблица:**
```sql
-- ПЛОХОЙ пример - нарушение всех НФ
CREATE TABLE bad_library_design (
    reader_name VARCHAR(150),
    reader_phone VARCHAR(20),
    book_titles TEXT, -- многозначный атрибут!
    authors TEXT, -- многозначный атрибут!
    categories TEXT, -- многозначный атрибут!
    loan_dates TEXT -- многозначный атрибут!
);
```

**Проблемы:**
- Нарушение 1НФ: многозначные атрибуты
- Избыточность данных
- Аномалии вставки, обновления, удаления
- Сложность запросов

---

## ЭТАП 5: Создание полезных представлений и запросов

### 5.1. Представления для отчетности

```sql
-- Представление: Книги с авторами и категориями
CREATE VIEW v_books_full AS
SELECT 
    b.book_id,
    b.title,
    b.isbn,
    b.publication_year,
    b.pages,
    b.copies_total,
    b.copies_available,
    c.name AS category_name,
    STRING_AGG(a.last_name || ' ' || a.first_name, ', ') AS authors
FROM books b
JOIN categories c ON b.category_id = c.category_id
LEFT JOIN book_authors ba ON b.book_id = ba.book_id
LEFT JOIN authors a ON ba.author_id = a.author_id
GROUP BY b.book_id, b.title, b.isbn, b.publication_year, b.pages, 
         b.copies_total, b.copies_available, c.name;

-- Представление: Активные выдачи
CREATE VIEW v_active_loans AS
SELECT 
    l.loan_id,
    r.last_name || ' ' || r.first_name AS reader_name,
    r.reader_type,
    b.title AS book_title,
    l.loan_date,
    l.due_date,
    CASE 
        WHEN l.due_date < CURRENT_DATE THEN 'Просрочена'
        ELSE 'В срок'
    END AS loan_status,
    CURRENT_DATE - l.due_date AS days_overdue
FROM loans l
JOIN readers r ON l.reader_id = r.reader_id
JOIN books b ON l.book_id = b.book_id
WHERE l.status = 'выдана';

-- Представление: Статистика по читателям
CREATE VIEW v_reader_statistics AS
SELECT 
    r.reader_id,
    r.last_name || ' ' || r.first_name AS reader_name,
    r.reader_type,
    COUNT(l.loan_id) AS total_loans,
    COUNT(CASE WHEN l.status = 'выдана' THEN 1 END) AS active_loans,
    COALESCE(SUM(f.amount), 0) AS total_fines,
    COALESCE(SUM(CASE WHEN f.paid = FALSE THEN f.amount ELSE 0 END), 0) AS unpaid_fines
FROM readers r
LEFT JOIN loans l ON r.reader_id = l.reader_id
LEFT JOIN fines f ON l.loan_id = f.loan_id
GROUP BY r.reader_id, r.last_name, r.first_name, r.reader_type;
```

### 5.2. Полезные запросы

```sql
-- 1. Поиск книг по автору
SELECT v.title, v.publication_year, v.copies_available
FROM v_books_full v
WHERE v.authors ILIKE '%Толстой%';

-- 2. Читатели с просроченными книгами
SELECT reader_name, book_title, days_overdue
FROM v_active_loans
WHERE loan_status = 'Просрочена'
ORDER BY days_overdue DESC;

-- 3. Самые популярные книги
SELECT b.title, COUNT(l.loan_id) AS loan_count
FROM books b
LEFT JOIN loans l ON b.book_id = l.book_id
GROUP BY b.book_id, b.title
ORDER BY loan_count DESC
LIMIT 10;

-- 4. Читатели с наибольшими штрафами
SELECT reader_name, total_fines, unpaid_fines
FROM v_reader_statistics
WHERE total_fines > 0
ORDER BY unpaid_fines DESC;
```

---

## ЭТАП 6: Создание функций и триггеров

### 6.1. Функции для автоматизации

```sql
-- Функция для автоматического расчета даты возврата
CREATE OR REPLACE FUNCTION calculate_due_date(reader_type VARCHAR(20))
RETURNS INTERVAL AS $$
BEGIN
    CASE reader_type
        WHEN 'студент' THEN RETURN INTERVAL '14 days';
        WHEN 'преподаватель' THEN RETURN INTERVAL '30 days';
        ELSE RETURN INTERVAL '7 days';
    END CASE;
END;
$$ LANGUAGE plpgsql;

-- Функция для проверки доступности книги
CREATE OR REPLACE FUNCTION check_book_availability(book_id_param INTEGER)
RETURNS BOOLEAN AS $$
DECLARE
    available_count INTEGER;
BEGIN
    SELECT copies_available INTO available_count
    FROM books 
    WHERE book_id = book_id_param;
    
    RETURN COALESCE(available_count, 0) > 0;
END;
$$ LANGUAGE plpgsql;
```

### 6.2. Триггеры для поддержания целостности

```sql
-- Триггер для автоматического обновления количества доступных книг
CREATE OR REPLACE FUNCTION update_book_availability()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        -- Уменьшаем количество доступных книг при выдаче
        UPDATE books 
        SET copies_available = copies_available - 1
        WHERE book_id = NEW.book_id;
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        -- Увеличиваем количество при возврате
        IF OLD.status != 'возвращена' AND NEW.status = 'возвращена' THEN
            UPDATE books 
            SET copies_available = copies_available + 1
            WHERE book_id = NEW.book_id;
        END IF;
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_update_book_availability
    AFTER INSERT OR UPDATE ON loans
    FOR EACH ROW
    EXECUTE FUNCTION update_book_availability();

-- Триггер для автоматического расчета срока возврата
CREATE OR REPLACE FUNCTION set_due_date()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.due_date IS NULL THEN
        SELECT 
            NEW.loan_date + calculate_due_date(r.reader_type)
        INTO NEW.due_date
        FROM readers r 
        WHERE r.reader_id = NEW.reader_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_set_due_date
    BEFORE INSERT ON loans
    FOR EACH ROW
    EXECUTE FUNCTION set_due_date();
```

---

## Контрольные вопросы

1. **По ER-диаграммам:**
   - Какие преимущества нотации Crow's Foot перед классической нотацией Чена?
   - Как правильно отобразить связь "многие ко многим" в ER-диаграмме?
   - Что такое слабая сущность и когда она используется?

2. **По преобразованию в реляционную модель:**
   - Какие правила применяются при преобразовании связей разных типов?
   - Где размещаются внешние ключи в связях 1:N?
   - Как решается проблема связи M:N в реляционной модели?

3. **По нормализации:**
   - Приведите примеры нарушений каждой из трех нормальных форм
   - В чем разница между частичной и транзитивной зависимостью?
   - Когда денормализация может быть оправдана?

4. **По PostgreSQL:**
   - Какие типы ограничений целостности поддерживает PostgreSQL?
   - Для чего используются триггеры в базах данных?
   - Как создать составной первичный ключ?

---

## Требования к отчету

### Структура отчета:

1. **Титульный лист**
   - Название работы
   - ФИО студента, группа
   - Дата выполнения

2. **Анализ предметной области**
   - Описание выбранной предметной области
   - Бизнес-правила и ограничения
   - Список основных сущностей

3. **ER-диаграмма**
   - Скриншот диаграммы из Draw.io в высоком разрешении
   - Описание всех сущностей и их атрибутов
   - Объяснение связей и их кардинальности
   - Приложение: файл .drawio

4. **Реляционная схема**
   - Описание процесса преобразования ER-модели
   - Список всех таблиц с описанием структуры
   - SQL-скрипт создания таблиц

5. **Нормализация**
   - Анализ соответствия каждой нормальной форме
   - Примеры возможных нарушений НФ
   - Обоснование принятых решений

6. **Физическая реализация**
   - Полный SQL-скрипт для PostgreSQL
   - Примеры тестовых данных
   - Скриншоты выполнения скриптов

7. **Дополнительные возможности**
   - Представления для отчетности
   - Полезные запросы
   - Функции и триггеры (опционально)

8. **Заключение**
   - Выводы о проделанной работе
   - Анализ эффективности полученной схемы
   - Предложения по улучшению

### Технические требования:

- **Формат:** PDF или Word
- **Объем:** 15-20 страниц
- **Шрифт:** Times New Roman, 12pt
- **Интервал:** 1.5
- **Поля:** 2 см со всех сторон

### Приложения:
- Файл ER-диаграммы (.drawio)
- SQL-скрипт (.sql)
- Скриншоты работы с PostgreSQL

---

## Дополнительные задания (для продвинутых студентов)

### 1. Расширение функциональности
- Добавить систему бронирования книг
- Реализовать категории читателей с разными правами
- Создать систему оценки и отзывов о книгах

### 2. Оптимизация производительности
- Проанализировать планы выполнения запросов
- Создать дополнительные индексы
- Провести нагрузочное тестирование

### 3. Интеграция с другими системами
- Создать API для внешних приложений
- Реализовать импорт данных из внешних источников
- Разработать систему уведомлений

---

## Критерии оценки

| Критерий | Отлично (5) | Хорошо (4) | Удовлетворительно (3) |
|----------|-------------|------------|----------------------|
| **ER-диаграмма** | Полная, корректная диаграмма с правильной нотацией | Незначительные неточности в нотации | Есть ошибки в связях или атрибутах |
| **Реляционная схема** | Правильное преобразование, все связи корректны | Минимальные ошибки в ключах | Существенные ошибки в структуре |
| **Нормализация** | Детальный анализ всех НФ с примерами | Хорошее понимание принципов | Поверхностное описание |
| **SQL-реализация** | Полный рабочий скрипт с ограничениями | Работающий код с незначительными недостатками | Базовая функциональность |
| **Документация** | Отличное оформление, полное описание | Хорошее оформление, достаточное описание | Удовлетворительное оформление |

---

## Полезные ресурсы

### Онлайн-инструменты:
- [Draw.io](https://app.diagrams.net/) — создание ER-диаграмм
- [Lucidchart](https://www.lucidchart.com/) — профессиональные диаграммы
- [dbdiagram.io](https://dbdiagram.io/) — специализированный инструмент для БД

### Документация:
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [pgAdmin 4](https://www.pgadmin.org/)

### Обучающие материалы:
- Дейт К. Дж. "Введение в системы баз данных"
- Коннолли Т., Бегг К. "Базы данных: проектирование, реализация и сопровождение"
- Кузнецов С.Д. "Основы современных баз данных"

---

*Успехов в освоении проектирования баз данных! Данная лабораторная работа даст вам фундаментальные навыки, необходимые для создания эффективных информационных систем.*