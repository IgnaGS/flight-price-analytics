# 🛫 Guía de Implementación: dbt + BigQuery + Kestra

**Objetivo:** Configurar la capa de transformación (dbt) para el proyecto de predicción de precios de vuelos, parametrizar los entornos (KV Store) y orquestar su ejecución mediante Kestra utilizando una Service Account.

## Paso 1: Configuración del Proyecto y Perfil de dbt
Se deben configurar los archivos base de dbt para que utilicen variables de entorno mediante Jinja (`{{ env_var() }}`), permitiendo flexibilidad entre desarrollo local y producción.

**Instrucciones para el código:**
1. **`profiles.yml`:** Configurar el target hacia BigQuery utilizando autenticación mediante Service Account. Parametrizar:
   - `method`: `service-account`
   - `project`: `{{ env_var('GCP_PROJECT_ID') }}`
   - `dataset`: `{{ env_var('DBT_DATASET', 'dbt_dev') }}`
   - `location`: `{{ env_var('GCP_LOCATION', 'US') }}`
   - `keyfile`: `{{ env_var('GCP_KEY_PATH') }}`
2. **`dbt_project.yml`:** Definir la estructura del proyecto (`flight_analytics`). Configurar la materialización por defecto:
   - `models/staging`: materializados como `view`.
   - `models/marts`: materializados como `table`.

## Paso 2: Definición de Fuentes (Sources)
Crear el archivo YAML que indica a dbt dónde se encuentran los datos crudos (cargados previamente en la Fase 2 por Kestra).

**Instrucciones para el código:**
1. Crear **`models/staging/src_flights.yml`**.
2. Definir la fuente `raw_flight_data` apuntando a las variables de entorno:
   - `database`: `{{ env_var('GCP_PROJECT_ID') }}`
   - `schema`: `{{ env_var('RAW_DATASET', 'raw_dataset') }}`
   - `identifier`: `{{ env_var('RAW_TABLE_NAME', 'raw_flights_data') }}` (Alias de la tabla en código: `raw_flights`).

## Paso 3: Transformación y Modelado SQL
Crear los modelos que limpiarán los datos y los prepararán para Looker Studio.

**Instrucciones para el código:**
1. **Staging (`models/staging/stg_flight_data.sql`):**
   - Leer de `{{ source('raw_flight_data', 'raw_flights') }}`.
   - Castear todas las columnas y asegurar el formato `snake_case`.
   - **Lógica clave:** Crear la columna `flight_date` sumando los días de la columna `days_left` a la fecha actual (`current_date()`).
2. **Marts (`models/marts/fct_flight_prices.sql`):**
   - Leer de `{{ ref('stg_flight_data') }}`.
   - Realizar agregaciones: `avg_price`, `min_price`, `max_price`, `total_flights` agrupando por dimensiones.
   - **Optimización BigQuery:** Particionar por `flight_date` y aplicar clustering por `["source_city", "destination_city", "airline"]`.

## Paso 4: Ejecución en Entorno Local (Desarrollo)
El entorno local requiere inyectar las variables antes de ejecutar los comandos y apuntar a tu archivo JSON local.

**Instrucciones para el desarrollador:**
1. **Autenticación GCP:** Asegúrate de tener tu archivo `.json` de la Service Account en tu máquina local (¡asegúrate de que esté en el `.gitignore` o fuera de la carpeta del proyecto!).
2. Crear un archivo `.env` en la raíz del proyecto dbt.
3. Definir las variables (coincidentes con tu KV Store) y la ruta al JSON:
   ```env
   GCP_PROJECT_ID=mi-proyecto-123
   DBT_DATASET=dbt_dev
   GCP_LOCATION=US
   RAW_DATASET=dataset_crudo
   RAW_TABLE_NAME=tabla_parquet
   GCP_KEY_PATH=/ruta/absoluta/a/tu/service_account.json