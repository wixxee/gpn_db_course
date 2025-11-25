-- Создание схемы для объединенных данных
CREATE SCHEMA IF NOT EXISTS unified_analysis;

-- Создание представления в новой схеме
CREATE VIEW unified_analysis.well_drilling_analysis AS
SELECT 
    -- Основные идентификаторы
    dp.id AS drilling_process_id,
    w.well_id,
    w.well_number,
    f.field_name,
    
    -- Данные бурения
    w.well_type,
    w.well_status,
    dp.start_date,
    dp.end_date,
    dp.final_depth AS drilled_depth,
    
    -- Данные инклинометрии
    inc.measurement_id,
    inc.measurement_depth,
    inc.zenith_angle,
    inc.azimuth,
    inc.data_quality,
    
    -- Бизнес-логика и анализ
    CASE 
        WHEN dp.end_date IS NULL THEN 'В процессе бурения'
        WHEN dp.final_depth >= 3000 THEN 'Глубокая скважина'
        ELSE 'Стандартная скважина'
    END AS well_category,
    
    CASE 
        WHEN inc.data_quality IN ('A', 'B') THEN 'Высокое качество'
        WHEN inc.data_quality = 'C' THEN 'Среднее качество'
        ELSE 'Требует проверки'
    END AS quality_assessment,
    
    CASE 
        WHEN inc.zenith_angle > 45 THEN 'Горизонтальная'
        WHEN inc.zenith_angle BETWEEN 15 AND 45 THEN 'Направленная' 
        ELSE 'Вертикальная'
    END AS trajectory_type,
    
    -- Разница между пробуренной глубиной и измеренной
    (dp.final_depth - inc.measurement_depth) AS depth_difference,

    -- Статус завершения
    CASE 
        WHEN dp.end_date IS NOT NULL AND inc.measurement_id IS NOT NULL 
            THEN 'Полностью завершено'
        WHEN dp.end_date IS NOT NULL AND inc.measurement_id IS NULL 
            THEN 'Бурение завершено, нет данных инклинометрии'
        ELSE 'В процессе'
    END AS completion_status

FROM drilling_wells.drilling_process dp
INNER JOIN drilling_wells.well w ON dp.well_id = w.well_id
INNER JOIN drilling_wells.field f ON w.field_id = f.field_id
LEFT JOIN inclinometry.inclinometry inc ON dp.research_id = inc.measurement_id::VARCHAR(20);

-- Создание индексов для улучшения производительности (опционально)
COMMENT ON SCHEMA unified_analysis IS 'Схема для объединенного анализа данных бурения и инклинометрии';
COMMENT ON VIEW unified_analysis.well_drilling_analysis IS 'Представление для анализа совместных данных бурения и инклинометрии';

-- Проверка создания
SELECT * FROM unified_analysis.well_drilling_analysis LIMIT 5;