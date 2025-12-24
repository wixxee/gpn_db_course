-- 1. Заполнение таблицы field (Месторождение) - 1000+ записей
INSERT INTO inclinometry.field (field_id, field_name, status)
SELECT 
    seq as field_id,
    'Field_' || seq as field_name,
    CASE 
        WHEN (seq % 5) = 0 THEN 'active'
        WHEN (seq % 5) = 1 THEN 'development'
        WHEN (seq % 5) = 2 THEN 'exploration'
        WHEN (seq % 5) = 3 THEN 'conservation'
        ELSE 'closed'
    END as status
FROM generate_series(1, 1001) seq;

-- 2. Заполнение таблицы trajectory_correction_method - 1000+ записей
INSERT INTO inclinometry.trajectory_correction_method (method_id, method_name, mathematical_model, calculation_algorithm, error, application_area)
SELECT 
    i,
    'Метод_' || i,
    CASE (i % 6)
        WHEN 0 THEN 'Минимальная кривизна'
        WHEN 1 THEN 'Средний угол'
        WHEN 2 THEN 'Радиальная'
        WHEN 3 THEN 'Тангенциальная'
        WHEN 4 THEN 'Вертикальная'
        ELSE 'Комбинированная'
    END,
    'Алгоритм_' || (i % 50),
    (0.01 + (i % 90) * 0.001)::decimal(5,3),
    CASE (i % 4)
        WHEN 0 THEN 'Горизонтальные скважины'
        WHEN 1 THEN 'Вертикальные скважины'
        WHEN 2 THEN 'Многозабойные скважины'
        ELSE 'Все типы'
    END
FROM generate_series(1, 1100) as i;

-- 3. Заполнение таблицы equipment - 1000+ записей
INSERT INTO inclinometry.equipment (equipment_code, model_name, manufacturer, measurement_accuracy, calibration_date)
SELECT 
    'EQ' || LPAD(i::text, 6, '0'),
    'Модель_' || (i % 100),
    CASE (i % 8)
        WHEN 0 THEN 'Schlumberger'
        WHEN 1 THEN 'Halliburton'
        WHEN 2 THEN 'Baker Hughes'
        WHEN 3 THEN 'Weatherford'
        WHEN 4 THEN 'NOV'
        WHEN 5 THEN 'Татнефть'
        WHEN 6 THEN 'Газпром'
        ELSE 'Роснефть'
    END,
    (0.005 + (i % 50) * 0.001)::decimal(4,3),
    DATE '2020-01-01' + (i % 1460) * INTERVAL '1 day'
FROM generate_series(1, 1300) as i;

-- 4. Заполнение таблицы coordination_system - 1000+ записей
INSERT INTO inclinometry.coordination_system (system_code, system_name, description)
SELECT 
    'SYS' || LPAD(i::text, 5, '0'),
    'Система_' || i,
    'Описание системы координат номер ' || i || ' для геодезических измерений'
FROM generate_series(1, 1050) as i;

-- 5. Заполнение таблицы trajectory_point_type - 1000+ записей
INSERT INTO inclinometry.trajectory_point_type (type_code, type_name, description)
SELECT 
    'TYPE' || LPAD(i::text, 5, '0'),
    CASE (i % 10)
        WHEN 0 THEN 'Измеренная'
        WHEN 1 THEN 'Расчетная'
        WHEN 2 THEN 'Целевая'
        WHEN 3 THEN 'Искривления'
        WHEN 4 THEN 'Контрольная'
        WHEN 5 THEN 'Опорная'
        WHEN 6 THEN 'Промежуточная'
        WHEN 7 THEN 'Конечная'
        WHEN 8 THEN 'Стартовая'
        ELSE 'Корректирующая'
    END,
    'Описание типа точки траектории ' || i
FROM generate_series(1, 1200) as i;

-- 6. Заполнение таблицы well (Скважина) - 1000+ записей
INSERT INTO inclinometry.well (well_id, field_id, well_number, drilling_date, depth, well_status, well_type)
SELECT 
    seq as well_id,
    ((seq - 1) % 1001) + 1 as field_id,  -- Исправлено: field_id от 1 до 1001
    'W' || LPAD(seq::text, 4, '0') as well_number,
    DATE '2020-01-01' + ((seq % 1000) * INTERVAL '1 day') as drilling_date,
    ROUND(1000 + (seq % 9000)::numeric, 2) as depth,
    CASE (seq % 6)
        WHEN 0 THEN 'drilling'
        WHEN 1 THEN 'producing'
        WHEN 2 THEN 'injection'
        WHEN 3 THEN 'observation'
        WHEN 4 THEN 'abandoned'
        ELSE 'suspended'
    END as well_status,
    CASE (seq % 4)
        WHEN 0 THEN 'vertical'
        WHEN 1 THEN 'horizontal'
        WHEN 2 THEN 'directional'
        ELSE 'multilateral'
    END as well_type
FROM generate_series(1, 1500) seq;  -- Увеличено до 1500 записей

-- 7. Заполнение таблицы wellhead_coordinates - 1500 записей
INSERT INTO inclinometry.wellhead_coordinates (well_id, latitude, longitude, absolute_elevation, azimuth_type, coordinate_system)
SELECT 
    i,  -- well_id от 1 до 1500
    (45 + (i % 1000) * 0.01)::decimal(10,6),
    (60 + (i % 1000) * 0.015)::decimal(10,6),
    (20 + (i % 200) * 0.5)::decimal(8,2),
    CASE (i % 3)
        WHEN 0 THEN 'Магнитный'
        WHEN 1 THEN 'Истинный'
        ELSE 'Гридический'
    END,
    CASE (i % 4)
        WHEN 0 THEN 'WGS84'
        WHEN 1 THEN 'СК-42'
        WHEN 2 THEN 'СК-95'
        ELSE 'МСК'
    END
FROM generate_series(1, 1500) as i;

-- 8. Заполнение таблицы geological_section - 2000 записей
INSERT INTO inclinometry.geological_section (layer_id, well_id, top_depth, bottom_depth, rock_name, lithology)
SELECT 
    i,
    ((i - 1) % 1500) + 1 as well_id,  -- Исправлено: well_id от 1 до 1500
    ((i % 100) * 50)::decimal(8,2),
    (((i % 100) * 50) + 50 + (i % 30))::decimal(8,2),
    CASE (i % 12)
        WHEN 0 THEN 'Глина'
        WHEN 1 THEN 'Песчаник'
        WHEN 2 THEN 'Алевролит'
        WHEN 3 THEN 'Известняк'
        WHEN 4 THEN 'Доломит'
        WHEN 5 THEN 'Аргиллит'
        WHEN 6 THEN 'Конгломерат'
        WHEN 7 THEN 'Базальт'
        WHEN 8 THEN 'Гранит'
        WHEN 9 THEN 'Сланцы'
        WHEN 10 THEN 'Каменная соль'
        ELSE 'Ангидрит'
    END,
    CASE (i % 6)
        WHEN 0 THEN 'Глинистая'
        WHEN 1 THEN 'Песчаная'
        WHEN 2 THEN 'Карбонатная'
        WHEN 3 THEN 'Обломочная'
        WHEN 4 THEN 'Метаморфическая'
        ELSE 'Вулканогенная'
    END
FROM generate_series(1, 2000) as i;

-- 9. Заполнение таблицы well_geometry - 1800 записей
INSERT INTO inclinometry.well_geometry (geometry_id, well_id, coordination_system_code, geometry_type, coordinate_system, calculation_method, coordination_status, coordination_date, verified, verification_date, notes)
SELECT 
    i,
    ((i - 1) % 1500) + 1 as well_id,  -- Исправлено: well_id от 1 до 1500
    'SYS' || LPAD((((i - 1) % 1050) + 1)::text, 5, '0'),
    CASE (i % 4)
        WHEN 0 THEN '3D траектория'
        WHEN 1 THEN '2D профиль'
        WHEN 2 THEN 'Вертикальная'
        ELSE 'Сложная 3D'
    END,
    CASE (i % 4)
        WHEN 0 THEN 'WGS84'
        WHEN 1 THEN 'СК-42'
        WHEN 2 THEN 'СК-95'
        ELSE 'МСК'
    END,
    CASE (i % 5)
        WHEN 0 THEN 'Мин. кривизны'
        WHEN 1 THEN 'Сред. угла'
        WHEN 2 THEN 'Радиальный'
        WHEN 3 THEN 'Тангенциальный'
        ELSE 'Комбинированный'
    END,
    CASE (i % 4)
        WHEN 0 THEN 'Утверждена'
        WHEN 1 THEN 'Черновая'
        WHEN 2 THEN 'Архив'
        ELSE 'Корректировка'
    END,
    DATE '2015-01-01' + (i % 2920) * INTERVAL '1 day',
    (i % 3) != 0,
    CASE WHEN (i % 3) != 0 THEN DATE '2015-01-01' + (i % 2920 + 30) * INTERVAL '1 day' ELSE NULL END,
    'Примечания к геометрии скважины ID ' || i
FROM generate_series(1, 1800) as i;

-- 10. Заполнение таблицы inclinometry - 2500 записей
INSERT INTO inclinometry.inclinometry (measurement_id, well_id, equipment_code, correction_method_id, inclinometry_type, measurement_date, measurement_depth, zenith_angle, azimuth, data_quality, contractor_company_name)
SELECT 
    i,
    ((i - 1) % 1500) + 1 as well_id,  -- Исправлено: well_id от 1 до 1500
    'EQ' || LPAD((((i - 1) % 1300) + 1)::text, 6, '0'),
    ((i - 1) % 1100) + 1,
    CASE (i % 5)
        WHEN 0 THEN 'Гироскопическая'
        WHEN 1 THEN 'Магнитная'
        WHEN 2 THEN 'Комбинированная'
        WHEN 3 THEN 'Инерциальная'
        ELSE 'Спутниковая'
    END,
    DATE '2018-01-01' + (i % 2190) * INTERVAL '1 day',
    ((i % 100) * 50 + (i % 10) * 5)::decimal(8,2),
    CASE 
        WHEN (i % 10) = 0 THEN 0.00
        ELSE (i % 90)::decimal(5,2)
    END,
    (i % 360)::decimal(6,2),
    CASE (i % 5)
        WHEN 0 THEN 'A'
        WHEN 1 THEN 'B'
        WHEN 2 THEN 'C'
        WHEN 3 THEN 'D'
        ELSE 'E'
    END,
    CASE (i % 8)
        WHEN 0 THEN 'Schlumberger'
        WHEN 1 THEN 'Halliburton'
        WHEN 2 THEN 'Baker Hughes'
        WHEN 3 THEN 'Weatherford'
        WHEN 4 THEN 'Татнефть'
        WHEN 5 THEN 'Газпром'
        WHEN 6 THEN 'Роснефть'
        ELSE 'Лукойл'
    END
FROM generate_series(1, 2500) as i;

-- 11. Заполнение таблицы trajectory_point - 3000 записей
INSERT INTO inclinometry.trajectory_point (point_id, geometry_id, point_type_code, measurement_id, measured_depth, vertical_depth, north_deviation, east_deviation, zenith_angle, azimuth, data_quality)
SELECT 
    i,
    ((i - 1) % 1800) + 1 as geometry_id,  -- Исправлено: geometry_id от 1 до 1800
    'TYPE' || LPAD((((i - 1) % 1200) + 1)::text, 5, '0'),
    ((i - 1) % 2500) + 1 as measurement_id,  -- Исправлено: measurement_id от 1 до 2500
    ((i % 100) * 50 + (i % 10) * 5)::decimal(8,2),
    ((i % 100) * 45 + (i % 10) * 4.5)::decimal(8,2),
    ((i % 200) - 100 + (i % 10) * 0.5)::decimal(8,2),
    ((i % 150) - 75 + (i % 10) * 0.3)::decimal(8,2),
    CASE 
        WHEN (i % 20) = 0 THEN 0.00
        ELSE (i % 90)::decimal(5,2)
    END,
    (i % 360)::decimal(6,2),
    CASE (i % 5)
        WHEN 0 THEN 'A'
        WHEN 1 THEN 'B'
        WHEN 2 THEN 'C'
        WHEN 3 THEN 'D'
        ELSE 'E'
    END
FROM generate_series(1, 3000) as i;