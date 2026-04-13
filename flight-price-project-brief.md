# 🛫 Project Brief: End-to-End Flight Price Analytics Pipeline

## 1. Contexto y Rol
* **Objetivo:** Desarrollar un pipeline de datos "end-to-end" tipo batch para el proyecto final del Data Engineering Zoomcamp.
* **Rol del Asistente:** Analytic Engineer asistiendo en la implementación técnica y arquitectura.
* **Dataset:** [Flight Price Prediction (Kaggle)](https://www.kaggle.com/datasets/shubhambathwal/flight-price-prediction). Archivo principal: `Clean_Dataset.csv`.
* **Problema a resolver:** Identificar patrones de precios y determinar el momento óptimo de compra analizando la evolución del precio según la antelación (`days_left`), aerolínea y franja horaria.

## 2. Tech Stack (Requerimientos)
* **Infraestructura (IaC):** Terraform (GCP Provider).
* **Cloud Storage:** Google Cloud Storage (GCS) como Data Lake (Formato Parquet).
* **Data Warehouse:** BigQuery (Tablas particionadas y con clustering).
* **Orquestación:** Kestra (Flujos declarativos en YAML).
* **Transformación:** dbt (Data Build Tool) con BigQuery.
* **Visualización:** Looker Studio.

## 3. Arquitectura de Datos
1. **Ingesta (Kestra):** Lectura de `Clean_Dataset.csv`, simulación de batch y carga a GCS.
2. **Carga (Staging):** Movimiento de GCS a BigQuery (External tables o Load Jobs).
3. **Transformación (dbt):**
   - **Staging:** Limpieza de tipos, renombrado de columnas (snake_case).
   - **Marts:** Agregaciones de precios promedio/mínimo por ruta, aerolínea y ventana temporal.
4. **Optimización en BigQuery:**
   - **Particionamiento:** Por fecha de vuelo.
   - **Clustering:** Por `source_city`, `destination_city` y `airline`.

## 4. Diseño del Dashboard (Looker Studio)
- **Gráfico Categórico:** Distribución de precios por aerolínea y clase (Economy/Business).
- **Gráfico Temporal:** Evolución del precio promedio vs. `days_left` (días faltantes para el vuelo).

## 5. Instrucciones para la Implementación (Guía para el Agente)
Por favor, procede con las siguientes fases de forma secuencial:

### Fase 1: Infraestructura (Terraform)
Generar `main.tf` y `variables.tf` para:
- Bucket de GCS (Storage Class: Standard).
- Dataset de BigQuery.

### Fase 2: Orquestación (Kestra)
Crear el flujo YAML que:
- Tome el archivo CSV local.
- Lo convierta a Parquet.
- Lo suba a GCS.
- Ejecute el Load Job hacia BigQuery.

### Fase 3: Modelado (dbt)
Crear los modelos SQL para:
- `stg_flight_data`: Limpieza inicial.
- `fct_flight_prices`: Tabla final para el dashboard.

### Fase 4: Documentación
Generar un `README.md` que explique cómo reproducir el pipeline desde cero.
