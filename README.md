# Flight Price Analytics

## Pipeline overview

Este repositorio implementa un pipeline batch para analizar precios de vuelos desde un dataset local hacia BigQuery, con transformación en dbt y orquestación en Kestra.

### Componentes principales

- `kestra/`: orquesta la ingesta de CSV, conversión a Parquet y carga a BigQuery.
- `dbt/`: contiene el proyecto dbt que limpia, transforma y materializa los modelos.
- `secrets/`: credenciales y secretos para GCP.

## Estructura dbt

- `dbt/profiles.yml`: perfil para BigQuery usando `service-account`.
- `dbt/dbt_project.yml`: configuración del proyecto y materializaciones.
- `dbt/models/staging/`: vista de staging para limpiar y normalizar los datos.
- `dbt/models/marts/`: tabla final particionada y clusterizada.

## Flujo de Kestra

- `kestra/flows/01_flight_price_pipeline.yaml`: procesa el CSV local, convierte a Parquet, sube a GCS y carga la tabla raw en BigQuery.
- `kestra/flows/02_dbt_daily_run.yaml`: ejecuta dbt de forma separada, programada todos los días a las 09:00.

## Cómo ejecutar

1. Completa las variables en `kestra/.env` y `secrets/.json_encoded`.
2. Asegúrate de que `secrets/gcloud-credentials.json` esté disponible.
3. Inicia Kestra:
   ```bash
   cd kestra
   docker compose up -d
   ```
4. Carga los flujos de Kestra (el contenedor `kestra_flows_loader` ya lo hace automáticamente).
5. Ejecuta el flujo de ingesta manualmente desde la UI de Kestra o mediante la API.
6. El flujo `02_dbt_daily_run` se ejecutará automáticamente cada día a las 09:00 en la zona horaria `America/Santiago`.

## Prueba manual de dbt

Puedes probar dbt localmente desde el directorio raíz:

```bash
cd dbt
python3 -m venv .venv
source .venv/bin/activate
pip install dbt-bigquery==1.6.0
export DBT_PROFILES_DIR=$(pwd)
export GCP_PROJECT_ID=...
export DBT_DATASET=...
export GCP_LOCATION=...
export RAW_DATASET=...
export RAW_TABLE_NAME=raw_flight_data
export GCP_KEY_PATH=/ruta/a/tu/service_account.json

dbt debug
dbt run --models stg_flight_data fct_flight_prices
dbt test --models stg_flight_data fct_flight_prices
```