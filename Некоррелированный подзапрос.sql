-- Найти скважины глубже средней глубины всех скважин
SELECT well_id, well_number, depth
FROM inclinometry.well
WHERE depth > (
    SELECT AVG(depth) 
    FROM inclinometry.well  -- Этот подзапрос выполнится ОДИН РАЗ
);