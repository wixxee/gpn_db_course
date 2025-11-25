-- 1. Таблицы без внешних ключей
CREATE TABLE inclinometry.field (
    field_id INT PRIMARY KEY,
    field_name VARCHAR(100),
    status VARCHAR(50)
);

CREATE TABLE inclinometry.trajectory_correction_method (
    method_id SERIAL PRIMARY KEY,
    method_name VARCHAR(100) NOT NULL,
    mathematical_model VARCHAR(50),
    calculation_algorithm TEXT,
    error DECIMAL(5,3),
    application_area VARCHAR(200)
);

CREATE TABLE inclinometry.equipment (
    equipment_code VARCHAR(20) PRIMARY KEY,
    model_name VARCHAR(100) NOT NULL,
    manufacturer VARCHAR(50),
    measurement_accuracy DECIMAL(4,3),
    calibration_date DATE
);

CREATE TABLE inclinometry.coordination_system (
    system_code VARCHAR(10) PRIMARY KEY,
    system_name VARCHAR(50) NOT NULL,
    description VARCHAR(200)
);

CREATE TABLE inclinometry.trajectory_point_type (
    type_code VARCHAR(10) PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL,
    description VARCHAR(200)
);

-- 2. Таблицы, зависящие от field
CREATE TABLE inclinometry.well (
    well_id INT PRIMARY KEY,
    field_id INT,
    well_number VARCHAR(10),
    drilling_date DATE,
    depth DECIMAL(10,2),
    well_status VARCHAR(20),
    well_type VARCHAR(30),
    FOREIGN KEY (field_id) REFERENCES inclinometry.field(field_id)
);

-- 3. Таблицы, зависящие от well
CREATE TABLE inclinometry.wellhead_coordinates (
    well_id INTEGER PRIMARY KEY REFERENCES inclinometry.well(well_id),
    latitude DECIMAL(10,6),
    longitude DECIMAL(10,6),
    absolute_elevation DECIMAL(8,2),
    azimuth_type VARCHAR(20),
    coordinate_system VARCHAR(30)
);

CREATE TABLE inclinometry.geological_section (
    layer_id SERIAL PRIMARY KEY,
    well_id INTEGER NOT NULL REFERENCES inclinometry.well(well_id),
    top_depth DECIMAL(8,2),
    bottom_depth DECIMAL(8,2),
    rock_name VARCHAR(50),
    lithology VARCHAR(30)
);

CREATE TABLE inclinometry.well_geometry (
    geometry_id SERIAL PRIMARY KEY,
    well_id INTEGER NOT NULL REFERENCES inclinometry.well(well_id),
    coordination_system_code VARCHAR(10) REFERENCES inclinometry.coordination_system(system_code),
    geometry_type VARCHAR(20),
    coordinate_system VARCHAR(30),
    calculation_method VARCHAR(100),
    coordination_status VARCHAR(20),
    coordination_date DATE,
    verified BOOLEAN,
    verification_date DATE,
    notes TEXT
);

-- 4. Таблицы с множественными зависимостями
CREATE TABLE inclinometry.inclinometry (
    measurement_id SERIAL PRIMARY KEY,
    well_id INTEGER NOT NULL REFERENCES inclinometry.well(well_id),
    equipment_code VARCHAR(20) REFERENCES inclinometry.equipment(equipment_code),
    correction_method_id INTEGER REFERENCES inclinometry.trajectory_correction_method(method_id),
    inclinometry_type VARCHAR(30),
    measurement_date DATE,
    measurement_depth DECIMAL(8,2),
    zenith_angle DECIMAL(5,2),
    azimuth DECIMAL(6,2),
    data_quality VARCHAR(10),
    contractor_company_name VARCHAR(100)
);

-- 5. Таблица с максимальным количеством зависимостей
CREATE TABLE inclinometry.trajectory_point (
    point_id SERIAL PRIMARY KEY,
    geometry_id INTEGER NOT NULL REFERENCES inclinometry.well_geometry(geometry_id),
    point_type_code VARCHAR(10) REFERENCES inclinometry.trajectory_point_type(type_code),
    measurement_id INTEGER REFERENCES inclinometry.inclinometry(measurement_id),
    measured_depth DECIMAL(8,2),
    vertical_depth DECIMAL(8,2),
    north_deviation DECIMAL(8,2),
    east_deviation DECIMAL(8,2),
    zenith_angle DECIMAL(5,2),
    azimuth DECIMAL(6,2),
    data_quality VARCHAR(10)
);