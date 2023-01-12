import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, registry, clear_mappers

map_registry = registry()


@pytest.fixture
def sqlite_session_factory():
    engine = create_engine("sqlite:///:memory:")
    map_registry.metadata.create_all(engine)
    yield sessionmaker(bind=engine)


@pytest.fixture
def mappers():
    # map_registry.map_imperatively(ModelTableName, orm_table_name)

    yield
    clear_mappers()




