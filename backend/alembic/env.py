import sys
import os
from logging.config import fileConfig
from sqlalchemy import engine_from_config, pool, create_engine
from alembic import context
from dotenv import load_dotenv

# Dodaj folder nadrzędny (backend/) do sys.path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

# Wczytaj .env
load_dotenv()

# Import Base i modele
from app.core.db import Base
import app.models  # ← tutaj ważne, żeby Alembic zobaczyło wszystkie modele

target_metadata = Base.metadata

config = context.config
fileConfig(config.config_file_name)

def get_database_url():
    driver = os.getenv("DB_DRIVER", "postgresql+psycopg2")
    user = os.getenv("DB_USER", "fuelup_user")
    password = os.getenv("DB_PASSWORD", "fuelup")
    host = os.getenv("DB_HOST", "localhost")
    port = os.getenv("DB_PORT", "5432")
    db = os.getenv("DB_NAME", "fuelup_db")
    return f"{driver}://{user}:{password}@{host}:{port}/{db}"

config.set_main_option("sqlalchemy.url", get_database_url())

def run_migrations_offline():
    url = config.get_main_option("sqlalchemy.url")
    context.configure(url=url, target_metadata=target_metadata, literal_binds=True)
    with context.begin_transaction():
        context.run_migrations()

def run_migrations_online():
    connectable = create_engine(config.get_main_option("sqlalchemy.url"), poolclass=pool.NullPool)
    with connectable.connect() as connection:
        context.configure(connection=connection, target_metadata=target_metadata)
        with context.begin_transaction():
            context.run_migrations()

if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
