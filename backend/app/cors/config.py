from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    # Default = the Postgres container from docker-compose (host port 5433).
    # Override it by setting DATABASE_URL in the .env file.
    database_url: str = "postgresql+psycopg://abroad:abroad_pw@127.0.0.1:5433/abroad"

    # Websites allowed to call this API from a browser.
    cors_origins: list[str] = ["http://localhost:3000"]

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")


settings = Settings()
