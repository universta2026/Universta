# Re-exports Base so other files can write: from app.db.base import Base
from app.models.models import Base

__all__ = ["Base"]
