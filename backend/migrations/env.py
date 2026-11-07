from logging.config import fileConfig

from alembic import context
from sqlalchemy import engine_from_config, pool

from app.models.models import Base   # adjust to your actual import path

config = context.config

config.set_main_option(
    "sqlalchemy.url",
    "postgresql+psycopg://abroad:abroad_pw@127.0.0.1:5433/abroad",
)
print("USING URL:", config.get_main_option("sqlalchemy.url"))

if config.config_file_name is not None:
    fileConfig(config.config_file_name)

target_metadata = Base.metadata


def include_object(obj, name, type_, reflected, compare_to):
    # Never touch Directus tables
    if type_ == "table" and (
        name.startswith("directus_") or obj.info.get("managed_by") == "directus"
    ):
        return False
    return True


def run_migrations_offline() -> None:
    url = config.get_main_option("sqlalchemy.url")
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
        include_object=include_object,
    )
    with context.begin_transaction():
        context.run_migrations()


def run_migrations_online() -> None:
    connectable = engine_from_config(
        config.get_section(config.config_ini_section, {}),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )
    with connectable.connect() as connection:
        context.configure(
            connection=connection,
            target_metadata=target_metadata,
            include_object=include_object,
        )
        with context.begin_transaction():
            context.run_migrations()


if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()