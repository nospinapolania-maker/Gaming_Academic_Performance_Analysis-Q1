-- ============================================================
-- GAMING ACADEMIC PERFORMANCE - SQL Analytics Queries
-- Descripcion: KPIs, segmentos y vistas para dashboard academico
-- Dataset limpio: 8,000 estudiantes, 19 columnas
-- Motor sugerido: MySQL 8+
--
-- Nota de nombres:
-- En Power Query / Excel la columna aparece como `attendance (%)`.
-- En SQL se usa `attendance` para evitar espacios y parentesis.
-- ============================================================

-- ------------------------------------------------------------
-- SECCION 1: SETUP - Crear tabla e importar datos
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS gaming_academic_performance (
    student_id          INT PRIMARY KEY,
    age                 INT,
    gender              VARCHAR(20),
    gaming_hours        DECIMAL(5,2),
    study_hours         DECIMAL(5,2),
    sleep_hours         DECIMAL(5,2),
    attendance          DECIMAL(5,2),
    gaming_genre        VARCHAR(50),
    social_activity     DECIMAL(5,2),
    device_usage        DECIMAL(5,2),
    reaction_time_ms    DECIMAL(6,2),
    addiction_score     DECIMAL(6,2),
    stress_level        VARCHAR(20),
    grades              DECIMAL(6,2),
    gaming_band         VARCHAR(20),
    study_band          VARCHAR(20),
    sleep_band          VARCHAR(20),
    performance_band    VARCHAR(20),
    risk_flag           VARCHAR(50)
);

-- Crear tabla con este script de setup: SQL/gaming_academic_queries.sql
-- El dataset limpio esta en: data/Desempeño_académico_limpio.xlsx
-- Para importarlo en MySQL, exportar la hoja limpia como CSV:
-- data/gaming_academic_performance_clean.csv
-- Luego importar el CSV con MySQL Workbench > Table Data Import Wizard
-- Ruta dentro de Workbench:
-- Schemas > [tu_base] > Tables > clic derecho > Table Data Import Wizard
--
-- Si el CSV exportado conserva el encabezado `attendance (%)`, mapearlo
-- manualmente hacia la columna SQL `attendance` durante la importacion.

-- Indices opcionales si el analisis se vuelve mas pesado:
-- CREATE INDEX idx_performance_band ON gaming_academic_performance (performance_band);
-- CREATE INDEX idx_risk_flag ON gaming_academic_performance (risk_flag);
-- CREATE INDEX idx_gaming_band ON gaming_academic_performance (gaming_band);
-- CREATE INDEX idx_study_band ON gaming_academic_performance (study_band);

-- ------------------------------------------------------------
-- SECCION 2: KPIS EJECUTIVOS (Pagina 1 del Dashboard)
-- ------------------------------------------------------------

-- Q1: KPIs generales del dataset
-- Los conteos de riesgo y excelencia se calculan desde `grades`
-- para dejar explicita la regla de negocio: riesgo < 60 y excelencia >= 90.
SELECT
    COUNT(*) AS total_students,
    ROUND(AVG(grades), 2) AS avg_grade,
    ROUND(AVG(gaming_hours), 2) AS avg_gaming_hours,
    ROUND(AVG(study_hours), 2) AS avg_study_hours,
    ROUND(AVG(sleep_hours), 2) AS avg_sleep_hours,
    ROUND(AVG(attendance), 2) AS avg_attendance,
    SUM(CASE WHEN grades < 60 THEN 1 ELSE 0 END) AS at_risk_students,
    ROUND(100.0 * SUM(CASE WHEN grades < 60 THEN 1 ELSE 0 END) / COUNT(*), 2) AS at_risk_pct,
    SUM(CASE WHEN grades >= 90 THEN 1 ELSE 0 END) AS excellent_students,
    ROUND(100.0 * SUM(CASE WHEN grades >= 90 THEN 1 ELSE 0 END) / COUNT(*), 2) AS excellent_pct
FROM gaming_academic_performance;

-- Q2: Distribucion por rendimiento academico
-- pct_students calcula el peso de cada banda sobre el total de estudiantes.
-- SUM(COUNT(*)) OVER () obtiene el total general despues del GROUP BY,
-- sin eliminar el detalle por performance_band.
SELECT
    performance_band,
    COUNT(*) AS students,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_students,
    ROUND(AVG(grades), 2) AS avg_grade,
    ROUND(AVG(gaming_hours), 2) AS avg_gaming_hours,
    ROUND(AVG(study_hours), 2) AS avg_study_hours
FROM gaming_academic_performance
GROUP BY performance_band
ORDER BY FIELD(performance_band, 'Excellent', 'Solid', 'Regular', 'At Risk');

-- Q3: Distribucion por genero y nivel de estres
--Para cada combinación de género y estrés, ¿cuántos estudiantes hay y cuáles son sus promedios de nota, gaming, estudio y sueño?
SELECT
    gender,
    stress_level,
    COUNT(*) AS students,
    ROUND(AVG(grades), 2) AS avg_grade,
    ROUND(AVG(gaming_hours), 2) AS avg_gaming_hours,
    ROUND(AVG(study_hours), 2) AS avg_study_hours,
    ROUND(AVG(sleep_hours), 2) AS avg_sleep_hours
FROM gaming_academic_performance
GROUP BY gender, stress_level
ORDER BY gender, FIELD(stress_level, 'Low', 'Medium', 'High');


-- Q4: Validacion ejecutiva de calidad del dataset limpio
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT student_id) AS unique_students,
    SUM(CASE WHEN grades > 100 THEN 1 ELSE 0 END) AS grades_over_100,
    SUM(CASE WHEN grades < 0 THEN 1 ELSE 0 END) AS grades_below_0,
    SUM(CASE WHEN addiction_score < 0 THEN 1 ELSE 0 END) AS negative_addiction_score,
    SUM(CASE WHEN gaming_hours < 0 OR gaming_hours > 8 THEN 1 ELSE 0 END) AS gaming_out_of_range,
    SUM(CASE WHEN study_hours < 1 OR study_hours > 10 THEN 1 ELSE 0 END) AS study_out_of_range
FROM gaming_academic_performance;

-- ------------------------------------------------------------
-- SECCION 3: GAMING VS RENDIMIENTO (Pagina 2)
-- ------------------------------------------------------------

-- Q5: Calificacion promedio por banda de gaming
-- Pregunta: Como cambia el rendimiento academico segun la intensidad de gaming?
-- Esta consulta agrupa a los estudiantes segun su intensidad de gaming.
-- Para cada banda calcula: cantidad de estudiantes, promedio de notas,
-- promedio de horas de estudio, promedio de addiction_score,
-- promedio de uso de dispositivos y porcentaje de estudiantes en riesgo.
-- El porcentaje en riesgo se calcula dentro de cada banda:
-- estudiantes con grades < 60 / total de estudiantes de la banda * 100
SELECT
    gaming_band,
    COUNT(*) AS students,
    ROUND(AVG(grades), 2) AS avg_grade,
    ROUND(AVG(study_hours), 2) AS avg_study_hours,
    ROUND(AVG(addiction_score), 2) AS avg_addiction_score,
    ROUND(AVG(device_usage), 2) AS avg_device_usage,
    ROUND(100.0 * SUM(CASE WHEN grades < 60 THEN 1 ELSE 0 END) / COUNT(*), 2) AS at_risk_pct
FROM gaming_academic_performance
GROUP BY gaming_band
ORDER BY FIELD(gaming_band, '0-2h', '2-4h', '4-6h', '6-8h');

-- Q6: Calificacion promedio por banda de estudio
-- Pregunta: Como cambia el rendimiento academico segun las horas de estudio?
-- Para cada banda de estudio, cuántos estudiantes hay, cuál es su nota promedio,
-- cuánto juegan en promedio, cuál es su asistencia promedio
-- y qué porcentaje son excelentes.
SELECT
    study_band,
    COUNT(*) AS students,
    ROUND(AVG(grades), 2) AS avg_grade,
    ROUND(AVG(gaming_hours), 2) AS avg_gaming_hours,
    ROUND(AVG(attendance), 2) AS avg_attendance,
    ROUND(100.0 * SUM(CASE WHEN grades >= 90 THEN 1 ELSE 0 END) / COUNT(*), 2) AS excellent_pct
FROM gaming_academic_performance
GROUP BY study_band
ORDER BY FIELD(study_band, '1-3h', '3-6h', '6-8h', '8-10h');

-- Q7: Matriz gaming vs estudio
-- Pregunta: Que combinaciones de gaming y estudio se asocian con mejor o peor rendimiento?
-- Esta consulta cruza las bandas de gaming con las bandas de estudio.
-- Para cada combinacion calcula: cantidad de estudiantes, nota promedio
-- y porcentaje de estudiantes en riesgo academico.
-- Sirve para identificar que combinaciones de habitos se asocian
-- con mejor o peor rendimiento.
SELECT
    gaming_band,
    study_band,
    COUNT(*) AS students,
    ROUND(AVG(grades), 2) AS avg_grade,
    ROUND(100.0 * SUM(CASE WHEN grades < 60 THEN 1 ELSE 0 END) / COUNT(*), 2) AS at_risk_pct
FROM gaming_academic_performance
GROUP BY gaming_band, study_band
ORDER BY
    FIELD(gaming_band, '0-2h', '2-4h', '4-6h', '6-8h'),
    FIELD(study_band, '1-3h', '3-6h', '6-8h', '8-10h');

-- Q8: Ranking por genero de videojuego
-- Pregunta: Que generos de videojuego se asocian con mejor rendimiento academico,
-- menor porcentaje de riesgo y mayor porcentaje de estudiantes excelentes?
-- Esta consulta agrupa a los estudiantes segun su genero principal de juego.
-- Para cada genero calcula cantidad de estudiantes, nota promedio,
-- habitos promedio de gaming y estudio, addiction_score promedio,
-- porcentaje de estudiantes en riesgo y porcentaje de estudiantes excelentes.
-- El ranking se ordena de mayor a menor nota promedio para comparar rendimiento academico.
SELECT
    gaming_genre,
    COUNT(*) AS students,
    ROUND(AVG(grades), 2) AS avg_grade,
    ROUND(AVG(gaming_hours), 2) AS avg_gaming_hours,
    ROUND(AVG(study_hours), 2) AS avg_study_hours,
    ROUND(AVG(addiction_score), 2) AS avg_addiction_score,
    ROUND(100.0 * SUM(CASE WHEN grades < 60 THEN 1 ELSE 0 END) / COUNT(*), 2) AS at_risk_pct,
    ROUND(100.0 * SUM(CASE WHEN grades >= 90 THEN 1 ELSE 0 END) / COUNT(*), 2) AS excellent_pct
FROM gaming_academic_performance
GROUP BY gaming_genre
ORDER BY avg_grade DESC;

-- ------------------------------------------------------------
-- SECCION 4: INTELIGENCIA DE COMPORTAMIENTO (Pagina 3)
-- ------------------------------------------------------------

-- Q9: Correlaciones contra calificaciones
-- MySQL no incluye CORR() como funcion nativa; se calcula con la formula:
-- covarianza(x,y) / (desviacion_estandar(x) * desviacion_estandar(y))
-- La parte superior de la formula mide si dos variables se mueven juntas.
-- La division por las desviaciones estandar normaliza el resultado entre -1 y 1.
SELECT
    ROUND((AVG(grades * gaming_hours) - AVG(grades) * AVG(gaming_hours)) /
          NULLIF(STDDEV_POP(grades) * STDDEV_POP(gaming_hours), 0), 3) AS corr_grades_gaming,
    ROUND((AVG(grades * study_hours) - AVG(grades) * AVG(study_hours)) /
          NULLIF(STDDEV_POP(grades) * STDDEV_POP(study_hours), 0), 3) AS corr_grades_study,
    ROUND((AVG(grades * sleep_hours) - AVG(grades) * AVG(sleep_hours)) /
          NULLIF(STDDEV_POP(grades) * STDDEV_POP(sleep_hours), 0), 3) AS corr_grades_sleep,
    ROUND((AVG(grades * attendance) - AVG(grades) * AVG(attendance)) /
          NULLIF(STDDEV_POP(grades) * STDDEV_POP(attendance), 0), 3) AS corr_grades_attendance,
    ROUND((AVG(grades * device_usage) - AVG(grades) * AVG(device_usage)) /
          NULLIF(STDDEV_POP(grades) * STDDEV_POP(device_usage), 0), 3) AS corr_grades_device_usage,
    ROUND((AVG(grades * addiction_score) - AVG(grades) * AVG(addiction_score)) /
          NULLIF(STDDEV_POP(grades) * STDDEV_POP(addiction_score), 0), 3) AS corr_grades_addiction
FROM gaming_academic_performance;

-- Q10: Perfil por nivel de estres
-- Pregunta: Como cambian las notas y los habitos segun el nivel de estres?
-- Esta consulta agrupa a los estudiantes por stress_level y calcula
-- cantidad de estudiantes, nota promedio, gaming promedio, estudio promedio,
-- sueno promedio y addiction_score promedio para cada nivel.
SELECT
    stress_level,
    COUNT(*) AS students,
    ROUND(AVG(grades), 2) AS avg_grade,
    ROUND(AVG(gaming_hours), 2) AS avg_gaming_hours,
    ROUND(AVG(study_hours), 2) AS avg_study_hours,
    ROUND(AVG(sleep_hours), 2) AS avg_sleep_hours,
    ROUND(AVG(addiction_score), 2) AS avg_addiction_score
FROM gaming_academic_performance
GROUP BY stress_level
ORDER BY FIELD(stress_level, 'Low', 'Medium', 'High');

-- Q11: Sueno y rendimiento academico
-- Pregunta: Como cambia el rendimiento academico segun las horas de sueno?
-- Esta consulta agrupa a los estudiantes por banda de sueno y calcula
-- cantidad de estudiantes, nota promedio, gaming promedio, estudio promedio
-- y asistencia promedio para comparar rutinas de descanso.
SELECT
    sleep_band,
    COUNT(*) AS students,
    ROUND(AVG(grades), 2) AS avg_grade,
    ROUND(AVG(gaming_hours), 2) AS avg_gaming_hours,
    ROUND(AVG(study_hours), 2) AS avg_study_hours,
    ROUND(AVG(attendance), 2) AS avg_attendance
FROM gaming_academic_performance
GROUP BY sleep_band
ORDER BY FIELD(sleep_band, '<5h', '5-7h', '7-8h', '8h+');

-- Q12: Cuartiles de tiempo de reaccion
-- Pregunta: Como cambia el rendimiento academico segun grupos de tiempo de reaccion?
-- Primero se crea una tabla temporal llamada reaction_quartiles.
-- En esa tabla se agrega reaction_quartile, una columna que divide a los estudiantes
-- en 4 grupos ordenados por reaction_time_ms.
WITH reaction_quartiles AS (
    SELECT
        student_id,
        reaction_time_ms,
        grades,
        gaming_hours,
        study_hours,
        -- NTILE(4) reparte las filas en 4 grupos.
        -- El ORDER BY es necesario porque define el criterio de orden:
        -- cuartil 1 = menor tiempo de reaccion, cuartil 4 = mayor tiempo.
        NTILE(4) OVER (ORDER BY reaction_time_ms) AS reaction_quartile
    FROM gaming_academic_performance
)
SELECT
    reaction_quartile,
    COUNT(*) AS students,
    -- Estos valores muestran el rango real de reaction_time_ms en cada cuartil.
    ROUND(MIN(reaction_time_ms), 2) AS min_reaction_ms,
    ROUND(MAX(reaction_time_ms), 2) AS max_reaction_ms,
    -- Estos promedios permiten comparar rendimiento y habitos entre cuartiles.
    ROUND(AVG(grades), 2) AS avg_grade,
    ROUND(AVG(gaming_hours), 2) AS avg_gaming_hours,
    ROUND(AVG(study_hours), 2) AS avg_study_hours
FROM reaction_quartiles
-- Se agrupa por la columna creada en la tabla temporal.
GROUP BY reaction_quartile
ORDER BY reaction_quartile;

-- ------------------------------------------------------------
-- SECCION 5: RIESGO Y SEGMENTACION (Pagina 4)
-- ------------------------------------------------------------

-- Q13: Segmentos accionables de estudiantes
-- Pregunta: Cuantos estudiantes hay en cada segmento de riesgo
-- y cual es el perfil promedio de cada segmento?
SELECT
    risk_flag AS student_segment,
    COUNT(*) AS students,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_students,
    ROUND(AVG(grades), 2) AS avg_grade,
    ROUND(AVG(gaming_hours), 2) AS avg_gaming_hours,
    ROUND(AVG(study_hours), 2) AS avg_study_hours,
    ROUND(AVG(attendance), 2) AS avg_attendance
FROM gaming_academic_performance
GROUP BY risk_flag
ORDER BY students DESC;

-- Q14: Riesgo por asistencia y estudio
-- Pregunta: Como cambia el riesgo academico al combinar el nivel de asistencia
-- y las horas de estudio de los estudiantes?
SELECT
    CASE
        WHEN attendance < 75 THEN 'Asistencia baja'
        ELSE 'Asistencia adecuada'
    END AS attendance_flag,
    CASE
        WHEN study_hours < 3 THEN 'Estudio bajo'
        ELSE 'Estudio suficiente'
    END AS study_flag,
    COUNT(*) AS students,
    ROUND(AVG(grades), 2) AS avg_grade,
    SUM(CASE WHEN grades < 60 THEN 1 ELSE 0 END) AS at_risk_students,
    ROUND(100.0 * SUM(CASE WHEN grades < 60 THEN 1 ELSE 0 END) / COUNT(*), 2) AS at_risk_pct
FROM gaming_academic_performance
GROUP BY attendance_flag, study_flag
ORDER BY avg_grade ASC;

-- ------------------------------------------------------------
-- SECCION 6: VISTAS PARA POWER BI / DASHBOARD
-- ------------------------------------------------------------

-- Vista 1: KPIs ejecutivos para tarjetas principales
CREATE OR REPLACE VIEW vw_kpis_academicos AS
SELECT
    COUNT(*) AS total_students,
    ROUND(AVG(grades), 2) AS avg_grade,
    ROUND(AVG(gaming_hours), 2) AS avg_gaming_hours,
    ROUND(AVG(study_hours), 2) AS avg_study_hours,
    ROUND(AVG(sleep_hours), 2) AS avg_sleep_hours,
    ROUND(AVG(attendance), 2) AS avg_attendance,
    SUM(CASE WHEN grades < 60 THEN 1 ELSE 0 END) AS at_risk_students,
    ROUND(100.0 * SUM(CASE WHEN grades < 60 THEN 1 ELSE 0 END) / COUNT(*), 2) AS at_risk_pct,
    SUM(CASE WHEN grades >= 90 THEN 1 ELSE 0 END) AS excellent_students,
    ROUND(100.0 * SUM(CASE WHEN grades >= 90 THEN 1 ELSE 0 END) / COUNT(*), 2) AS excellent_pct
FROM gaming_academic_performance;

-- Vista 2: Tabla de detalle por estudiante para filtros, scatter plots y drill-through
CREATE OR REPLACE VIEW vw_student_segments AS
SELECT
    student_id,
    age,
    gender,
    gaming_genre,
    stress_level,
    gaming_hours,
    study_hours,
    sleep_hours,
    attendance,
    social_activity,
    device_usage,
    reaction_time_ms,
    addiction_score,
    grades,
    gaming_band,
    study_band,
    sleep_band,
    performance_band,
    risk_flag,
    CASE WHEN grades < 60 THEN 1 ELSE 0 END AS is_at_risk,
    CASE WHEN grades >= 90 THEN 1 ELSE 0 END AS is_excellent
FROM gaming_academic_performance;

-- Vista 3: Tabla agregada para visuales de comportamiento
CREATE OR REPLACE VIEW vw_behavior_dashboard AS
SELECT
    gender,
    gaming_genre,
    stress_level,
    gaming_band,
    COUNT(*) AS students,
    ROUND(AVG(grades), 2) AS avg_grade,
    ROUND(AVG(study_hours), 2) AS avg_study_hours,
    ROUND(AVG(sleep_hours), 2) AS avg_sleep_hours,
    ROUND(AVG(attendance), 2) AS avg_attendance,
    ROUND(AVG(device_usage), 2) AS avg_device_usage,
    ROUND(AVG(addiction_score), 2) AS avg_addiction_score,
    ROUND(100.0 * SUM(CASE WHEN grades < 60 THEN 1 ELSE 0 END) / COUNT(*), 2) AS at_risk_pct
FROM gaming_academic_performance
GROUP BY gender, gaming_genre, stress_level, gaming_band;
