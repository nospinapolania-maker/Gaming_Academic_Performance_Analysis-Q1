<div align="center">

<img src="assets/header_banner.svg" alt="Gaming Academic Performance Dashboard" width="100%"/>

# Gaming Academic Performance · Student Behavior Intelligence

**Analisis de habitos de gaming, estudio, descanso y rendimiento academico**  
*Construido con PostgreSQL · Python · Power BI-ready · SQL Analytics*

<br/>

[![SQL](https://img.shields.io/badge/SQL-MySQL-4169E1?style=for-the-badge&logo=myql&logoColor=white)](https://https://www.mysql.com/_)
[![Python](https://img.shields.io/badge/Python-Analysis%20Pipeline-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)
[![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard%20Blueprint-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)](https://powerbi.microsoft.com/)
[![Dataset](https://img.shields.io/badge/Dataset-8,000%20rows%20·%2023%20clean%20cols-132040?style=for-the-badge)](data/gaming_academic_performance_clean.csv)

<br/>

> "No todas las horas de pantalla pesan igual: el valor analitico esta en entender cuando el gaming compite con el estudio, el sueno y la asistencia."

</div>

---

## Contexto del Proyecto

Una institucion academica quiere entender como los habitos digitales de sus estudiantes se relacionan con el rendimiento. El dataset combina horas de gaming, horas de estudio, sueno, asistencia, uso de dispositivos, tiempo de reaccion, nivel de estres y calificaciones.

El objetivo del proyecto es transformar un archivo CSV en una pieza de analisis tipo portafolio: datos documentados, consultas SQL reutilizables, pipeline Python y una narrativa de negocio lista para convertirse en dashboard.

---

## Dashboard — 4 Paginas

| Pagina | Nombre | Pregunta que responde |
|--------|--------|-----------------------|
| **P1** | Executive Overview | ¿Como se distribuye el rendimiento academico general? |
| **P2** | Gaming vs Study Trade-off | A partir de que intensidad de gaming baja la calificacion promedio? |
| **P3** | Student Behavior Intelligence | Que patrones aparecen entre sueno, asistencia, dispositivos y estres? |
| **P4** | Risk & Opportunity Segments | Que estudiantes requieren intervencion academica o seguimiento? |

<br/>

<div align="center">
<img src="assets/dashboard_preview.svg" alt="Dashboard Preview" width="90%"/>
<br/><sub><i>Blueprint visual para Power BI · Paleta academica navy #102A43 · teal #2EC4B6 · amber #FFB703</i></sub>
</div>

---

## Arquitectura

```text
FUENTE DE DATOS
   data/gaming_academic_performance.csv
   8,000 estudiantes · 14 variables academicas y de comportamiento
           |
           v
LIMPIEZA / TRANSFORMACION
   Python/clean_dataset.py
   - normalizacion de texto
   - control de outliers documentado
   - columnas derivadas para BI
   - output: data/gaming_academic_performance_clean.csv
           |
           v
PROCESAMIENTO ANALITICO
   Python/analyze_dataset.py
   - validacion de esquema
   - resumen estadistico
   - segmentos de riesgo
   - export de resumenes opcionales
           |
           v
ALMACENAMIENTO ANALITICO
   MySQL · tabla gaming_academic_performance
   - 16 queries analiticos
   - 3 vistas para dashboard
           |
           v
VISUALIZACION
   Power BI / Excel
   - 4 paginas sugeridas
   - KPIs, segmentos, ranking y correlaciones
```

---

## Metricas Implementadas

| Metrica | Definicion | Uso en dashboard |
|---------|------------|------------------|
| **Grade Average** | Promedio de calificaciones limpias | KPI principal de rendimiento |
| **At-Risk Students** | Estudiantes con `grades < 60` | Seguimiento academico |
| **Excellent Students** | Estudiantes con `grades >= 90` | Identificacion de mejores practicas |
| **Gaming Hours** | Horas diarias de gaming | Intensidad de juego |
| **Study Hours** | Horas diarias de estudio | Disciplina academica |
| **Sleep Hours** | Horas diarias de sueno | Balance de rutina |
| **Attendance** | Porcentaje de asistencia | Compromiso academico |
| **Addiction Score** | Indice de dependencia al gaming | Riesgo conductual |
| **Device Usage** | Uso diario de dispositivos | Exposicion digital |
| **Reaction Time** | Tiempo de reaccion en milisegundos | Indicador cognitivo operativo |

---

## SQL Analytics — 16 Queries + 3 Views

```sql
-- Ejemplo: calificacion promedio por banda de gaming
SELECT
    CASE
        WHEN gaming_hours <= 2 THEN '0-2h'
        WHEN gaming_hours <= 4 THEN '2-4h'
        WHEN gaming_hours <= 6 THEN '4-6h'
        ELSE '6-8h'
    END AS gaming_band,
    COUNT(*) AS students,
    ROUND(AVG(grades), 2) AS avg_grade,
    ROUND(AVG(study_hours), 2) AS avg_study_hours,
    ROUND(AVG(addiction_score), 2) AS avg_addiction_score
FROM gaming_academic_performance
GROUP BY gaming_band
ORDER BY MIN(gaming_hours);
```

| Seccion SQL | Queries | Tecnicas utilizadas |
|-------------|---------|---------------------|
| KPIs Ejecutivos | Q1-Q4 | `AVG`, `COUNT`, `CASE WHEN`, percentiles |
| Rendimiento Academico | Q5-Q8 | segmentacion, ranking, performance bands |
| Inteligencia de Comportamiento | Q9-Q12 | correlaciones, `NTILE`, agregaciones |
| Riesgo y Calidad de Datos | Q13-Q16 | flags, outliers, vistas para BI |
| ETL Views | 3 vistas | `CREATE OR REPLACE VIEW`, dashboard-ready tables |

---

## Python Pipeline

El script `Python/analyze_dataset.py` permite validar y resumir el dataset desde la terminal.

```bash
pip install pandas numpy
python Python/analyze_dataset.py
```

Salidas esperadas:

- Validacion de columnas requeridas.
- Conteo de nulos por columna.
- Resumen de correlaciones contra `grades`.
- Tablas agregadas por bandas de gaming, estudio, estres y genero de juego.
- Archivos CSV opcionales en `outputs/`.

---

## Estructura del Repositorio

```text
Gaming_Academic_Performance_Analysis-Q1/
|
├── data/
│   ├── gaming_academic_performance.csv      # Dataset fuente (8,000 filas · 14 cols)
│   ├── gaming_academic_performance_clean.csv # Dataset limpio (8,000 filas · 23 cols)
│   └── data_dictionary.md                   # Diccionario de variables
|
├── SQL/
│   └── gaming_academic_queries.sql          # 16 queries analiticos + 3 vistas
|
├── Python/
│   └── analyze_dataset.py                   # Pipeline de validacion y analisis
|
├── assets/
│   ├── header_banner.svg                    # Banner del repositorio
│   └── dashboard_preview.svg                # Mock visual del dashboard
|
├── .github/workflows/
│   └── python-package.yml                   # CI basico para validar el pipeline
|
├── INSIGHTS.md
├── CLEANING.md
├── CHANGELOG.md
├── requirements.txt
├── .gitignore
└── README.md
```

---

## Como Reproducir

### 1. Generar dataset limpio

```bash
pip install -r requirements.txt
python Python/clean_dataset.py
```

### 2. Ejecutar el analisis Python

```bash
python Python/analyze_dataset.py
```

### 3. Crear tabla en MySQL

```sql
-- Ejecutar la seccion 1 de SQL/gaming_academic_queries.sql
-- Luego importar:
\copy gaming_academic_performance
FROM 'data/gaming_academic_performance_clean.csv'
CSV HEADER;
```

### 4. Conectar a Power BI

```text
Get Data -> MySQL
Server: localhost
Database: [tu_db]
Importar:
  - gaming_academic_performance
  - vw_kpis_academicos
  - vw_student_segments
  - vw_behavior_dashboard
```

---

## Insights Clave del Analisis

- El dataset fuente contiene **8,000 estudiantes**, **14 columnas** y no presenta valores nulos.
- El pipeline de limpieza genera un archivo limpio de **23 columnas** sin eliminar filas.
- Las **horas de estudio** son la variable con relacion positiva mas fuerte frente a calificaciones (`corr = 0.733`).
- Las **horas de gaming** muestran una relacion negativa relevante con calificaciones (`corr = -0.552`).
- Estudiantes con **0-2h de gaming** tienen calificacion promedio de **82.02**, frente a **49.38** en el grupo de **6-8h**.
- Estudiantes con **8-10h de estudio** alcanzan promedio de **88.66**, frente a **44.91** en el grupo de **1-3h**.
- Hay **3,131 estudiantes en riesgo academico** (`grades < 60`) y **1,375 estudiantes excelentes** (`grades >= 90`).
- Limpieza documentada: **134 calificaciones superiores a 100** se acotan a 100 y **107 addiction scores negativos** se acotan a 0, manteniendo columnas originales para auditoria.

---

## Autor

**[Tu nombre]**  
Data Analyst Jr. en formacion

**Stack principal:** SQL/MySQL · Python/pandas · Power BI · Excel Advanced

---

<div align="center">

*Proyecto construido como repositorio de portafolio academico a partir de un unico dataset CSV.*

</div>
