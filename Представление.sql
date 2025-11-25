-- Создание отдельной схемы для витрин данных
CREATE SCHEMA IF NOT EXISTS unified_analysis;

-- Создание представления в новой схеме
CREATE VIEW unified_analysis.well_equipment_repair_analysis AS
SELECT 
    -- Основные идентификаторы
    w.well_id AS oper_well_id,
    wef_w.well_id AS failure_well_id,
    w.well_name,
    f.field_name,
    ps.shop_name,
    
    -- Данные о скважине
    w.well_type,
    w.well_status,
    fs.stage_name AS field_stage,
    
    -- Статистика по оборудованию
    (SELECT COUNT(*) 
     FROM well_equipment_failures.Equipment e 
     WHERE e.well_id = wef_w.well_id) AS equipment_count,
    
    -- Статистика по отказам
    (SELECT COUNT(*) 
     FROM well_equipment_failures.EquipmentFailures ef
     JOIN well_equipment_failures.Equipment e ON ef.equipment_id = e.equipment_id
     WHERE e.well_id = wef_w.well_id
     AND ef.failure_date >= CURRENT_DATE - INTERVAL '1 year') AS failures_last_year,
    
    -- Статистика по ремонтам
    (SELECT COUNT(*) 
     FROM oper.well_repair wr 
     WHERE wr.well_id = w.well_id) AS total_repairs,
    
    -- Активные ремонты
    (SELECT COUNT(*) 
     FROM oper.well_repair wr 
     JOIN dict.repair_status rs ON wr.repair_status_id = rs.repair_status_id
     WHERE wr.well_id = w.well_id 
     AND rs.repair_status_name IN ('В работе', 'Планируется')) AS active_repairs,
    
    -- Финансовые показатели
    (SELECT COALESCE(SUM(r.cost), 0)
     FROM well_equipment_failures.EquipmentFailures ef
     JOIN well_equipment_failures.Equipment e ON ef.equipment_id = e.equipment_id
     JOIN well_equipment_failures.Repairs r ON ef.failure_id = r.failure_id
     WHERE e.well_id = wef_w.well_id
     AND r.start_date >= CURRENT_DATE - INTERVAL '1 year') AS repair_costs_last_year,
    
    -- Показатели риска
    (SELECT AVG(well_equipment_failures.calculate_failure_risk(e.equipment_id))
     FROM well_equipment_failures.Equipment e
     WHERE e.well_id = wef_w.well_id) AS avg_risk_factor,
    
    -- Критическое оборудование
    (SELECT COUNT(*) 
     FROM well_equipment_failures.Equipment e 
     WHERE e.well_id = wef_w.well_id 
     AND e.condition_status IN ('poor', 'critical')) AS critical_equipment_count,
    
    -- Временные метрики
    (SELECT MAX(wr.actual_start_date) 
     FROM oper.well_repair wr 
     WHERE wr.well_id = w.well_id) AS last_repair_date,
    
    -- Бизнес-логика и категоризация
    CASE 
        WHEN w.well_status = 'активна' AND 
             (SELECT COUNT(*) FROM oper.well_repair wr WHERE wr.well_id = w.well_id) = 0 
        THEN 'Стабильная'
        WHEN w.well_status = 'в ремонте' THEN 'Требует внимания'
        WHEN (SELECT COUNT(*) FROM well_equipment_failures.EquipmentFailures ef
              JOIN well_equipment_failures.Equipment e ON ef.equipment_id = e.equipment_id
              WHERE e.well_id = wef_w.well_id AND ef.failure_date >= CURRENT_DATE - INTERVAL '30 days') > 2 
        THEN 'Проблемная'
        ELSE 'Нормальная'
    END AS well_health_status,
    
    -- Приоритет ремонтов
    CASE 
        WHEN (SELECT COUNT(*) FROM well_equipment_failures.Equipment e 
              WHERE e.well_id = wef_w.well_id AND e.condition_status IN ('poor', 'critical')) > 0 
        THEN 'Высокий'
        WHEN (SELECT AVG(well_equipment_failures.calculate_failure_risk(e.equipment_id))
              FROM well_equipment_failures.Equipment e WHERE e.well_id = wef_w.well_id) > 0.7 
        THEN 'Средний'
        ELSE 'Низкий'
    END AS repair_priority,
    
    -- Категория по стоимости ремонтов
    CASE 
        WHEN (SELECT COALESCE(SUM(r.cost), 0)
              FROM well_equipment_failures.EquipmentFailures ef
              JOIN well_equipment_failures.Equipment e ON ef.equipment_id = e.equipment_id
              JOIN well_equipment_failures.Repairs r ON ef.failure_id = r.failure_id
              WHERE e.well_id = wef_w.well_id) > 50000 
        THEN 'Высокие затраты'
        WHEN (SELECT COALESCE(SUM(r.cost), 0)
              FROM well_equipment_failures.EquipmentFailures ef
              JOIN well_equipment_failures.Equipment e ON ef.equipment_id = e.equipment_id
              JOIN well_equipment_failures.Repairs r ON ef.failure_id = r.failure_id
              WHERE e.well_id = wef_w.well_id) > 10000 
        THEN 'Средние затраты'
        ELSE 'Низкие затраты'
    END AS cost_category,
    
    -- Статус готовности данных
    CASE 
        WHEN wef_w.well_id IS NOT NULL AND 
             (SELECT COUNT(*) FROM well_equipment_failures.Equipment e WHERE e.well_id = wef_w.well_id) > 0 
        THEN 'Полные данные'
        WHEN wef_w.well_id IS NULL 
        THEN 'Только операционные данные'
        ELSE 'Частичные данные'
    END AS data_completeness_status,
    
    -- Эффективность оборудования
    CASE 
        WHEN (SELECT COUNT(*) FROM well_equipment_failures.EquipmentFailures ef
              JOIN well_equipment_failures.Equipment e ON ef.equipment_id = e.equipment_id
              WHERE e.well_id = wef_w.well_id) = 0 
        THEN 'Высокая'
        WHEN (SELECT COUNT(*) FROM well_equipment_failures.EquipmentFailures ef
              JOIN well_equipment_failures.Equipment e ON ef.equipment_id = e.equipment_id
              WHERE e.well_id = wef_w.well_id) / 
             NULLIF((SELECT COUNT(*) FROM well_equipment_failures.Equipment e WHERE e.well_id = wef_w.well_id), 0) < 0.1 
        THEN 'Средняя'
        ELSE 'Низкая'
    END AS equipment_efficiency,
    
    -- Время создания записи
    CURRENT_TIMESTAMP AS analysis_timestamp

FROM oper.well w
-- Связь с цехом и месторождением
INNER JOIN dict.production_shop ps ON w.shop_id = ps.shop_id
INNER JOIN dict.field f ON ps.field_id = f.field_id
INNER JOIN dict.field_stage fs ON f.field_stage_id = fs.field_stage_id
-- Связь со скважинами из схемы отказов
LEFT JOIN well_equipment_failures.Wells wef_w ON w.well_name = wef_w.well_number;

-- Комментарии к объектам
COMMENT ON SCHEMA unified_analysis IS 'Схема для объединенного анализа данных отказов оборудования и ремонтов скважин';
COMMENT ON VIEW unified_analysis.well_equipment_repair_analysis IS 'Представление для комплексного анализа технического состояния скважин, объединяющее данные об отказах оборудования и ремонтных работах';

-- Дополнительное представление для агрегированной статистики
CREATE VIEW unified_analysis.field_level_statistics AS
SELECT 
    field_name,
    COUNT(*) AS total_wells,
    COUNT(CASE WHEN well_health_status = 'Стабильная' THEN 1 END) AS stable_wells,
    COUNT(CASE WHEN well_health_status = 'Проблемная' THEN 1 END) AS problematic_wells,
    COUNT(CASE WHEN repair_priority = 'Высокий' THEN 1 END) AS high_priority_wells,
    SUM(equipment_count) AS total_equipment,
    SUM(critical_equipment_count) AS total_critical_equipment,
    AVG(avg_risk_factor) AS average_risk_factor,
    SUM(repair_costs_last_year) AS total_repair_costs,
    SUM(failures_last_year) AS total_failures
FROM unified_analysis.well_equipment_repair_analysis
GROUP BY field_name;

COMMENT ON VIEW unified_analysis.field_level_statistics IS 'Агрегированная статистика по месторождениям для стратегического анализа';

-- Проверка создания представлений
SELECT 'unified_analysis.well_equipment_repair_analysis' AS view_name, 
       COUNT(*) AS record_count 
FROM unified_analysis.well_equipment_repair_analysis

UNION ALL

SELECT 'unified_analysis.field_level_statistics' AS view_name, 
       COUNT(*) AS record_count 
FROM unified_analysis.field_level_statistics;

-- Пример запроса для проверки данных
SELECT 
    field_name,
    well_name,
    well_health_status,
    repair_priority,
    equipment_count,
    critical_equipment_count,
    repair_costs_last_year
FROM unified_analysis.well_equipment_repair_analysis
WHERE repair_priority = 'Высокий'
ORDER BY repair_costs_last_year DESC
LIMIT 10;