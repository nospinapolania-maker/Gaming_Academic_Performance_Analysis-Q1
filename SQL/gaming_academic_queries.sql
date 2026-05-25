- ============================================================
-- GAMING ACADEMIC PERFORMANCE - SQL Analytics Queries
-- Descripcion: KPIs y analisis de comportamiento estudiantil
-- Dataset: gaming_academic_performance_clean (8,000 registros, 19 columnas)
-- Motor sugerido: MySQL 8+
-- Nota: en Power Query / Excel la columna aparece como `attendance (%)`.
-- En SQL se usa `attendance` para evitar espacios y parentesis en los nombres.
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

-- ------------------------------------------------------------
-- SECCION 2: KPIS EJECUTIVOS (Pagina 1 del Dashboard)
-- ------------------------------------------------------------

-- Q1: KPIs generales del dataset
SELECT
    COUNT(*) AS total_students,
    ROUND(AVG(grades), 2) AS avg_grade,
    ROUND(AVG(gaming_hours), 2) AS avg_gaming_hours,
    ROUND(AVG(study_hours), 2) AS avg_study_hours,
    ROUND(AVG(sleep_hours), 2) AS avg_sleep_hours,
    ROUND(AVG(attendance), 2) AS avg_attendance,
    SUM(CASE WHEN grades < 60 THEN 1 ELSE 0 END) AS at_risk_students,
    SUM(CASE WHEN grades >= 90 THEN 1 ELSE 0 END) AS excellent_students
FROM gaming_academic_performance;

-- Q2: Distribucion por performance academica
SELECT
    performance_band,
    COUNT(*) AS students,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_students,
    ROUND(AVG(grades), 2) AS avg_grade
FROM gaming_academic_performance
GROUP BY performance_band
ORDER BY avg_grade DESC;

-- Q3: Distribucion por genero y estres
SELECT
    gender,
    stress_level,
    COUNT(*) AS students,
    ROUND(AVG(grades), 2) AS avg_grade,
    ROUND(AVG(gaming_hours), 2) AS avg_gaming_hours,
    ROUND(AVG(study_hours), 2) AS avg_study_hours
FROM gaming_academic_performance
GROUP BY gender, stress_level
ORDER BY gender, avg_grade DESC;

-- Q4: Indicadores de calidad del dataset limpio
SELECT
    SUM(CASE WHEN grades > 100 THEN 1 ELSE 0 END) AS grades_over_100_after_cleaning,
    SUM(CASE WHEN grades < 0 THEN 1 ELSE 0 END) AS grades_below_0,
    SUM(CASE WHEN addiction_score < 0 THEN 1 ELSE 0 END) AS negative_addiction_score_after_cleaning,
    SUM(CASE WHEN gaming_hours > 8 THEN 1 ELSE 0 END) AS gaming_over_8h,
    SUM(CASE WHEN study_hours > 10 THEN 1 ELSE 0 END) AS study_over_10h
FROM gaming_academic_performance;

-- ------------------------------------------------------------
-- SECCION 3: GAMING VS RENDIMIENTO (Pagina 2)
-- ------------------------------------------------------------

-- Q5: Calificacion promedio por banda de gaming
SELECT
    gaming_band,
    COUNT(*) AS students,
    ROUND(AVG(grades), 2) AS avg_grade,
    ROUND(AVG(study_hours), 2) AS avg_study_hours,
    ROUND(AVG(addiction_score), 2) AS avg_addiction_score,
    ROUND(AVG(device_usage), 2) AS avg_device_usage
FROM gaming_academic_performance
GROUP BY gaming_band
ORDER BY MIN(gaming_hours);

-- Q6: Calificacion promedio por banda de estudio
SELECT
    study_band,
    COUNT(*) AS students,
    ROUND(AVG(grades), 2) AS avg_grade,
    ROUND(AVG(gaming_hours), 2) AS avg_gaming_hours,
    ROUND(AVG(attendance), 2) AS avg_attendance
FROM gaming_academic_performance
GROUP BY study_band
ORDER BY MIN(study_hours);

-- Q7: Ranking por genero de videojuego
SELECT
    gaming_genre,
    COUNT(*) AS students,
    ROUND(AVG(grades), 2) AS avg_grade,
    ROUND(AVG(gaming_hours), 2) AS avg_gaming_hours,
    ROUND(AVG(study_hours), 2) AS avg_study_hours,
    ROUND(AVG(addiction_score), 2) AS avg_addiction_score
FROM gaming_academic_performance
GROUP BY gaming_genre
ORDER BY avg_grade DESC;

-- Q8: Top 20 estudiantes con alto gaming y alto rendimiento
SELECT
    student_id,
    age,
    gender,
    gaming_genre,
    gaming_hours,
    study_hours,
    attendance,
    grades,
    DENSE_RANK() OVER (ORDER BY grades DESC) AS grade_rank
FROM gaming_academic_performance
WHERE gaming_hours >= 6
  AND grades >= 85
ORDER BY grades DESC, study_hours DESC
LIMIT 20;

-- ------------------------------------------------------------
-- SECCION 4: INTELIGENCIA DE COMPORTAMIENTO (Pagina 3)
-- ------------------------------------------------------------

-- Q9: Correlaciones contra calificaciones
-- MySQL no incluye CORR() como funcion nativa; se calcula con la formula de correlacion.
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
ORDER BY avg_grade DESC;

-- Q11: Sueno y rendimiento
SELECT
    sleep_band,
    COUNT(*) AS students,
    ROUND(AVG(grades), 2) AS avg_grade,
    ROUND(AVG(gaming_hours), 2) AS avg_gaming_hours,
    ROUND(AVG(study_hours), 2) AS avg_study_hours
FROM gaming_academic_performance
GROUP BY sleep_band
ORDER BY MIN(sleep_hours);

-- Q12: Cuartiles de tiempo de reaccion
WITH reaction_quartiles AS (
    SELECT
        student_id,
        reaction_time_ms,
        grades,
        gaming_hours,
        NTILE(4) OVER (ORDER BY reaction_time_ms) AS reaction_quartile
    FROM gaming_academic_performance
)
SELECT
    reaction_quartile,
    COUNT(*) AS students,
    ROUND(MIN(reaction_time_ms), 2) AS min_reaction_ms,
    ROUND(MAX(reaction_time_ms), 2) AS max_reaction_ms,
    ROUND(AVG(grades), 2) AS avg_grade,
    ROUND(AVG(gaming_hours), 2) AS avg_gaming_hours
FROM reaction_quartiles
GROUP BY reaction_quartile
ORDER BY reaction_quartile;

-- ------------------------------------------------------------
-- SECCION 5: RIESGO Y SEGMENTACION (Pagina 4)
-- ------------------------------------------------------------

-- Q13: Segmentos accionables de estudiantes
SELECT
    risk_flag AS student_segment,
    COUNT(*) AS students,
    ROUND(AVG(grades), 2) AS avg_grade,
    ROUND(AVG(gaming_hours), 2) AS avg_gaming_hours,
    ROUND(AVG(study_hours), 2) AS avg_study_hours,
    ROUND(AVG(attendance), 2) AS avg_attendance
FROM gaming_academic_performance
GROUP BY risk_flag
ORDER BY students DESC;

-- Q14: Riesgo por asistencia y estudio
SELECT
    CASE WHEN attendance < 75 THEN 'Asistencia baja' ELSE 'Asistencia adecuada' END AS attendance_flag,
    CASE WHEN study_hours < 3 THEN 'Estudio bajo' ELSE 'Estudio suficiente' END AS study_flag,
    COUNT(*) AS students,
    ROUND(AVG(grades), 2) AS avg_grade,
    SUM(CASE WHEN grades < 60 THEN 1 ELSE 0 END) AS at_risk_students
FROM gaming_academic_performance
GROUP BY attendance_flag, study_flag
ORDER BY avg_grade ASC;

-- Q15: Uso de dispositivos vs rendimiento
SELECT
    CASE
        WHEN device_usage < 5 THEN '<5'
        WHEN device_usage < 8 THEN '5-8'
        WHEN device_usage < 11 THEN '8-11'
        ELSE '11+'
    END AS device_usage_band,
    COUNT(*) AS students,
    ROUND(AVG(grades), 2) AS avg_grade,
    ROUND(AVG(gaming_hours), 2) AS avg_gaming_hours,
    ROUND(AVG(addiction_score), 2) AS avg_addiction_score
FROM gaming_academic_performance
GROUP BY device_usage_band
ORDER BY MIN(device_usage);

-- Q16: Validacion final de rangos
SELECT
    student_id,
    age,
    gender,
    gaming_hours,
    study_hours,
    addiction_score,
    grades,
    CASE
        WHEN grades > 100 THEN 'Grade > 100'
        WHEN addiction_score < 0 THEN 'Negative addiction score'
        WHEN grades < 0 THEN 'Grade < 0'
        ELSE 'OK'
    END AS quality_flag
FROM gaming_academic_performance
WHERE grades > 100
   OR addiction_score < 0
   OR grades < 0
ORDER BY quality_flag, student_id;

-- ------------------------------------------------------------
-- SECCION 6: VISTAS ETL PARA POWER BI / DASHBOARD
-- ------------------------------------------------------------

-- Vista 1: KPIs academicos agregados
CREATE OR REPLACE VIEW vw_kpis_academicos AS
SELECT
    gender,
    stress_level,
    gaming_genre,
    COUNT(*) AS students,
    ROUND(AVG(grades), 2) AS avg_grade,
    ROUND(AVG(gaming_hours), 2) AS avg_gaming_hours,
    ROUND(AVG(study_hours), 2) AS avg_study_hours,
    ROUND(AVG(sleep_hours), 2) AS avg_sleep_hours,
    ROUND(AVG(attendance), 2) AS avg_attendance,
    SUM(CASE WHEN grades < 60 THEN 1 ELSE 0 END) AS at_risk_students
FROM gaming_academic_performance
GROUP BY gender, stress_level, gaming_genre;

-- Vista 2: Segmentos por estudiante
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
    device_usage,
    addiction_score,
    grades,
    gaming_band,
    study_band,
    sleep_band,
    performance_band,
    risk_flag
FROM gaming_academic_performance;

-- Vista 3: Tabla agregada para visuals de comportamiento
CREATE OR REPLACE VIEW vw_behavior_dashboard AS
SELECT
    gaming_genre,
    stress_level,
    gaming_band,
    COUNT(*) AS students,
    ROUND(AVG(grades), 2) AS avg_grade,
    ROUND(AVG(study_hours), 2) AS avg_study_hours,
    ROUND(AVG(sleep_hours), 2) AS avg_sleep_hours,
    ROUND(AVG(device_usage), 2) AS avg_device_usage,
    ROUND(AVG(addiction_score), 2) AS avg_addiction_score
FROM gaming_academic_performance
GROUP BY gaming_genre, stress_level, gaming_band;
