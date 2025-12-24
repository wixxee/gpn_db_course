-- 1. ИНДЕКСЫ ДЛЯ ТАБЛИЦЫ TRAJECTORY_POINT (точки траектории) --
-- Наиболее часто запрашиваемая таблица с 3000+ записей

-- Индекс для быстрого поиска всех точек по конкретной геометрии скважины
-- Используется в запросах: "показать всю траекторию скважины X"
CREATE INDEX idx_trajectory_point_geometry_id ON inclinometry.trajectory_point(geometry_id);
COMMENT ON INDEX idx_trajectory_point_geometry_id IS 'Поиск точек траектории по ID геометрии скважины. Ускоряет отображение полной траектории.';

-- Индекс для фильтрации и сортировки по измеренной глубине
-- Используется в запросах: "точки на глубине от 1000 до 2000 метров"
CREATE INDEX idx_trajectory_point_measured_depth ON inclinometry.trajectory_point(measured_depth);
COMMENT ON INDEX idx_trajectory_point_measured_depth IS 'Фильтрация точек по глубине. Критичен для анализа конкретных интервалов.';

-- Индекс для фильтрации по качеству данных измерений
-- Используется в запросах: "показать только точки с качеством A и B"
CREATE INDEX idx_trajectory_point_data_quality ON inclinometry.trajectory_point(data_quality);
COMMENT ON INDEX idx_trajectory_point_data_quality IS 'Фильтрация по качеству данных (A-высшее, E-низшее). Важен для контроля качества.';

-- Составной частичный индекс для самых частых операционных запросов
-- Используется в запросах: "качественные точки скважины X на глубине Y"
CREATE INDEX idx_trajectory_point_composite ON inclinometry.trajectory_point(geometry_id, measured_depth) 
WHERE data_quality IN ('A', 'B');
COMMENT ON INDEX idx_trajectory_point_composite IS 'Оптимизация частых запросов: геометрия + глубина + высокое качество. Частичный индекс экономят место.';

-- 2. ИНДЕКСЫ ДЛЯ ТАБЛИЦЫ INCLINOMETRY (измерения) --
-- Таблица основных измерений с 2500+ записей

-- Индекс для поиска всех измерений по конкретной скважине
-- Используется в запросах: "история измерений скважины W001"
CREATE INDEX idx_inclinometry_well_id ON inclinometry.inclinometry(well_id);
COMMENT ON INDEX idx_inclinometry_well_id IS 'Поиск измерений по ID скважины. Основа для скважинных отчетов.';

-- Индекс для временного анализа измерений
-- Используется в запросах: "измерения за последний месяц"
CREATE INDEX idx_inclinometry_measurement_date ON inclinometry.inclinometry(measurement_date);
COMMENT ON INDEX idx_inclinometry_measurement_date IS 'Временной анализ: фильтрация по дате измерений. Для трендов и отчетности.';

-- Индекс для анализа по глубине измерений
-- Используется в запросах: "измерения на критических глубинах"
CREATE INDEX idx_inclinometry_measurement_depth ON inclinometry.inclinometry(measurement_depth);
COMMENT ON INDEX idx_inclinometry_measurement_depth IS 'Поиск измерений по глубине. Важен для анализа конкретных горизонтов.';

-- Составной индекс для анализа методов измерений и их качества
-- Используется в запросах: "гироскопические измерения высокого качества"
CREATE INDEX idx_inclinometry_type_quality ON inclinometry.inclinometry(inclinometry_type, data_quality);
COMMENT ON INDEX idx_inclinometry_type_quality IS 'Анализ методов измерений и их надежности. Для сравнения технологий.';

-- 3. ИНДЕКСЫ ДЛЯ ТАБЛИЦЫ GEOLOGICAL_SECTION (геология) --
-- Геологические данные с 2000+ записей

-- Индекс для поиска геологических данных по скважине
-- Используется в запросах: "геологический разрез скважины W005"
CREATE INDEX idx_geological_section_well_id ON inclinometry.geological_section(well_id);
COMMENT ON INDEX idx_geological_section_well_id IS 'Поиск геологических слоев по скважине. Для построения геологических моделей.';

-- Составной индекс для поиска по интервалам глубин
-- Используется в запросах: "слои в интервале 1500-2000 метров"
CREATE INDEX idx_geological_section_depth_range ON inclinometry.geological_section(top_depth, bottom_depth);
COMMENT ON INDEX idx_geological_section_depth_range IS 'Поиск по интервалам глубин. Критичен для корреляции горизонтов.';

-- Индекс для анализа по типам пород
-- Используется в запросах: "все скважины с песчаником"
CREATE INDEX idx_geological_section_rock_name ON inclinometry.geological_section(rock_name);
COMMENT ON INDEX idx_geological_section_rock_name IS 'Поиск по типам горных пород. Для литологического анализа.';