# Diccionario de Datos - Gaming Academic Performance

Este documento describe los archivos, columnas y reglas de transformacion del proyecto. La tabla principal representa estudiantes y sus habitos de gaming, estudio, descanso, asistencia y rendimiento academico.

## Dataset Overview

| Elemento | Detalle |
|----------|---------|
| Tema | Gaming y desempeno academico |
| Granularidad | 1 fila = 1 estudiante |
| Dataset fuente | `gaming_academic_performance.csv` |
| Dataset limpio | `Desempeño_académico_limpio.xlsx` |
| Filas | 8,000 |
| Columnas originales | 14 |
| Columnas finales | 19 |
| Herramienta de limpieza | Power Query |
| Uso principal | Analisis exploratorio, SQL analytics y dashboard en Power BI |

Nota de nombre: la columna original `attendance` del CSV fue renombrada en Power Query como `attendance (%)` para que el archivo limpio deje claro que representa un porcentaje.

## Equivalencia de Nombre

| Contexto | Nombre de columna |
|----------|-------------------|
| CSV original | `attendance` |
| Power Query / Excel limpio | `attendance (%)` |
| SQL sugerido | `attendance` |

En SQL se recomienda usar `attendance` para evitar espacios y parentesis en los nombres de campos.

## Variables Clave para Analisis

| Icono | Metrica / Variable | Columna | Uso analitico |
|-------|--------------------|---------|---------------|
| 🎓 | Rendimiento academico | `grades` | Medir el desempeno general del estudiante. |
| 🎮 | Intensidad de gaming | `gaming_hours` | Comparar horas de juego frente al rendimiento. |
| 📚 | Habito de estudio | `study_hours` | Evaluar relacion entre estudio y calificaciones. |
| 😴 | Descanso | `sleep_hours` | Analizar balance entre sueno, estudio y gaming. |
| 🏫 | Asistencia | `attendance (%)` | Medir compromiso academico del estudiante. |
| 📱 | Uso de dispositivos | `device_usage` | Observar exposicion digital diaria. |
| 🧠 | Tiempo de reaccion | `reaction_time_ms` | Revisar indicadores cognitivos operativos. |
| ⚠️ | Riesgo academico | `risk_flag` | Identificar estudiantes que requieren seguimiento. |
| ⭐ | Alto desempeno | `performance_band` | Separar estudiantes excelentes, solidos y en riesgo. |

## Archivos de Datos

| Archivo | Tipo | Descripcion |
|---------|------|-------------|
| `gaming_academic_performance.csv` | Fuente | Archivo original sin transformar. Se conserva para trazabilidad. |
| `Desempeño_académico_limpio.xlsx` | Limpio | Archivo final transformado en Power Query. Es el recomendado para analisis. |

## Tabla Principal

| Campo en archivo limpio | Tipo sugerido | Origen | Nullable | Descripcion | Ejemplo |
|-------|---------------------|--------|----------|-------------|---------|
| `student_id` | INT | Original | No | Identificador unico del estudiante. | 1 |
| `age` | INT | Original | No | Edad del estudiante. | 22 |
| `gender` | VARCHAR(20) | Original | No | Genero reportado por el estudiante. | Male |
| `gaming_hours` | DECIMAL(5,2) | Original | No | Horas diarias dedicadas a videojuegos. | 7.23 |
| `study_hours` | DECIMAL(5,2) | Original | No | Horas diarias dedicadas al estudio. | 8.78 |
| `sleep_hours` | DECIMAL(5,2) | Original | No | Horas diarias de sueno. | 6.96 |
| `attendance (%)` | DECIMAL(5,2) | Original renombrada | No | Porcentaje de asistencia academica. En el CSV original se llama `attendance`. | 91.44 |
| `gaming_genre` | VARCHAR(50) | Original | No | Genero principal de videojuegos. | FPS |
| `social_activity` | DECIMAL(5,2) | Original | No | Indice de actividad social del estudiante. | 3.25 |
| `device_usage` | DECIMAL(5,2) | Original | No | Uso diario de dispositivos. | 9.36 |
| `reaction_time_ms` | DECIMAL(6,2) | Original | No | Tiempo de reaccion en milisegundos. | 235.84 |
| `addiction_score` | DECIMAL(6,2) | Original corregida | No | Puntaje de dependencia al gaming, corregido para evitar valores negativos. | 14.69 |
| `stress_level` | VARCHAR(20) | Original | No | Nivel de estres reportado. | Low |
| `grades` | DECIMAL(6,2) | Original corregida | No | Calificacion academica, corregida al rango 0-100. | 86.46 |
| `gaming_band` | VARCHAR(20) | Derivada | No | Segmento de horas de gaming. | 6-8h |
| `study_band` | VARCHAR(20) | Derivada | No | Segmento de horas de estudio. | 8-10h |
| `sleep_band` | VARCHAR(20) | Derivada | No | Segmento de horas de sueno. | 5-7h |
| `performance_band` | VARCHAR(20) | Derivada | No | Segmento de rendimiento academico. | Solid |
| `risk_flag` | VARCHAR(50) | Derivada | No | Etiqueta accionable para seguimiento academico. | Monitor |

## Valores Categoricos

| Campo | Valores |
|-------|---------|
| `gender` | `Male`, `Female`, `Other` |
| `gaming_genre` | `FPS`, `RPG`, `Casual` |
| `stress_level` | `Low`, `Medium`, `High` |

Distribucion en el archivo fuente:

| Campo | Valor | Registros |
|-------|-------|----------:|
| `gender` | Male | 3,904 |
| `gender` | Female | 3,803 |
| `gender` | Other | 293 |
| `gaming_genre` | FPS | 3,187 |
| `gaming_genre` | RPG | 2,408 |
| `gaming_genre` | Casual | 2,405 |
| `stress_level` | Low | 2,743 |
| `stress_level` | Medium | 4,247 |
| `stress_level` | High | 1,010 |

## Columnas Derivadas

Las siguientes columnas fueron creadas durante la limpieza y transformacion en Power Query.

### `gaming_band`

| Segmento | Regla |
|----------|-------|
| `0-2h` | `gaming_hours <= 2` |
| `2-4h` | `gaming_hours > 2` y `gaming_hours <= 4` |
| `4-6h` | `gaming_hours > 4` y `gaming_hours <= 6` |
| `6-8h` | `gaming_hours > 6` |

### `study_band`

| Segmento | Regla |
|----------|-------|
| `1-3h` | `study_hours <= 3` |
| `3-6h` | `study_hours > 3` y `study_hours <= 6` |
| `6-8h` | `study_hours > 6` y `study_hours <= 8` |
| `8-10h` | `study_hours > 8` |

### `sleep_band`

| Segmento | Regla |
|----------|-------|
| `<5h` | `sleep_hours < 5` |
| `5-7h` | `sleep_hours >= 5` y `sleep_hours < 7` |
| `7-8h` | `sleep_hours >= 7` y `sleep_hours < 8` |
| `8h+` | `sleep_hours >= 8` |

### `performance_band`

| Segmento | Regla |
|----------|-------|
| `At Risk` | `grades < 60` |
| `Regular` | `grades >= 60` y `grades < 75` |
| `Solid` | `grades >= 75` y `grades < 90` |
| `Excellent` | `grades >= 90` |

### `risk_flag`

| Segmento | Regla |
|----------|-------|
| `High Risk: High Gaming` | `grades < 60` y `gaming_hours >= 6` |
| `High Risk: Low Study` | `grades < 60` y `study_hours < 3` |
| `Academic Risk` | `grades < 60` |
| `Monitor` | Resto de estudiantes |

## Reglas de Limpieza

| Regla | Accion |
|-------|--------|
| Tipos de datos | Se asignaron tipos numericos y de texto en Power Query. |
| Columnas categoricas | Se limpiaron espacios y se normalizo el formato de texto. |
| `attendance` | Se renombro como `attendance (%)` en el archivo limpio de Power Query. |
| Siglas | Se conservaron siglas como `FPS` y `RPG`. |
| `grades` | Se acoto al rango valido de 0 a 100. |
| `addiction_score` | Se corrigieron valores negativos llevandolos a 0. |
| Segmentacion | Se agregaron 5 columnas derivadas para facilitar el analisis en SQL y Power BI. |

## Notas de Calidad

- El archivo fuente no presenta valores vacios en sus 14 columnas originales.
- La limpieza conserva las **8,000 filas** del dataset.
- El archivo final contiene **19 columnas**: 14 originales y 5 derivadas.
- El dataset limpio recomendado para analisis es `Desempeño_académico_limpio.xlsx`.
- Las columnas derivadas sirven para construir KPIs, segmentos, rankings y vistas de dashboard.
