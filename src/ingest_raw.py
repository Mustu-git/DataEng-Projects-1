import pandas as pd
import psycopg2
from sqlalchemy import create_engine
import requests
import os

# --- Config ---
DB_URL = "postgresql://taxi_user:taxi_pass@localhost:5433/taxi_db"
DATA_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "../data")
PARQUET_FILE = os.path.join(DATA_DIR, "yellow_tripdata_2023-01.parquet")
URL = "https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2023-01.parquet"

# --- Step 1: Download ---
if not os.path.exists(PARQUET_FILE):
    print("Downloading January 2023 taxi data...")
    r = requests.get(URL, stream=True)
    with open(PARQUET_FILE, "wb") as f:
        for chunk in r.iter_content(chunk_size=8192):
            f.write(chunk)
    print("Download complete.")
else:
    print("File already exists, skipping download.")

# --- Step 2: Read Parquet ---
print("Reading Parquet file...")
df = pd.read_parquet(PARQUET_FILE)
print(f"Rows: {len(df):,}  Columns: {list(df.columns)}")

# --- Step 3: Load into Postgres ---
print("Loading into raw.taxi_trips...")
engine = create_engine(DB_URL)
df.to_sql(
    name="taxi_trips",
    schema="raw",
    con=engine,
    if_exists="replace",
    index=False,
    chunksize=10000,
    method="multi"
)
print(f"Done! {len(df):,} rows loaded into raw.taxi_trips")
