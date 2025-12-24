-- Найти скважины, у которых есть точки траектории с качеством данных 'A'
SELECT w.well_id, w.well_number, w.depth
FROM inclinometry.well w
WHERE EXISTS (
    SELECT 1 
    FROM inclinometry.trajectory_point tp
    JOIN inclinometry.well_geometry wg ON tp.geometry_id = wg.geometry_id
    WHERE wg.well_id = w.well_id 
    AND tp.data_quality = 'A'
);