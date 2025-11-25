CREATE OR REPLACE FUNCTION inclinometry.calculate_horizontal_displacement(
    p_north_deviation DECIMAL(8,2),
    p_east_deviation DECIMAL(8,2)
)
RETURNS DECIMAL(10,2)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Расчет горизонтального смещения по теореме Пифагора
    RETURN ROUND(SQRT(POWER(p_north_deviation, 2) + POWER(p_east_deviation, 2))::DECIMAL(10,2), 2);
END;
$$;

-- Расчет горизонтального смещения для всех точек траектории
SELECT 
    point_id,
    north_deviation,
    east_deviation,
    inclinometry.calculate_horizontal_displacement(north_deviation, east_deviation) as horizontal_displacement
FROM inclinometry.trajectory_point
WHERE data_quality IN ('A', 'B');