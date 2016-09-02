from sqlalchemy import *
from migrate import *


from migrate.changeset import schema
pre_meta = MetaData()
post_meta = MetaData()
users = Table('users', pre_meta,
    Column('created_on', DATETIME),
    Column('updated_on', DATETIME),
    Column('id', INTEGER, primary_key=True, nullable=False),
    Column('username', VARCHAR(length=50), nullable=False),
    Column('password', VARCHAR(length=50), nullable=False),
    Column('email', VARCHAR(length=50)),
    Column('mmr', INTEGER, nullable=False),
    Column('kda', FLOAT),
    Column('gpm', INTEGER),
    Column('wallpapers_image_name', VARCHAR(length=50), nullable=False),
    Column('avatar_image_name', VARCHAR(length=50), nullable=False),
    Column('total_correct_answers', INTEGER),
    Column('total_incorrect_answers', INTEGER),
    Column('role', SMALLINT),
)

users = Table('users', post_meta,
    Column('created_on', DateTime, default=ColumnDefault(<sqlalchemy.sql.functions.now at 0x1026cead0; now>)),
    Column('updated_on', DateTime, onupdate=ColumnDefault(<sqlalchemy.sql.functions.now at 0x1026ced90; now>), default=ColumnDefault(<sqlalchemy.sql.functions.now at 0x1026cec90; now>)),
    Column('id', Integer, primary_key=True, nullable=False),
    Column('username', Unicode(length=50), nullable=False),
    Column('password_hash', String(length=128)),
    Column('email', String(length=50)),
    Column('mmr', Integer, nullable=False, default=ColumnDefault(4000)),
    Column('kda', Float, default=ColumnDefault(1.0)),
    Column('gpm', Integer, default=ColumnDefault(300)),
    Column('wallpapers_image_name', String(length=50), nullable=False, default=ColumnDefault('wallpaper_default.jpg')),
    Column('avatar_image_name', String(length=50), nullable=False, default=ColumnDefault('avatar_default.png')),
    Column('total_correct_answers', Integer, default=ColumnDefault(0)),
    Column('total_incorrect_answers', Integer, default=ColumnDefault(0)),
    Column('role', SmallInteger, default=ColumnDefault(0)),
)


def upgrade(migrate_engine):
    # Upgrade operations go here. Don't create your own engine; bind
    # migrate_engine to your metadata
    pre_meta.bind = migrate_engine
    post_meta.bind = migrate_engine
    pre_meta.tables['users'].columns['password'].drop()
    post_meta.tables['users'].columns['password_hash'].create()


def downgrade(migrate_engine):
    # Operations to reverse the above upgrade go here.
    pre_meta.bind = migrate_engine
    post_meta.bind = migrate_engine
    pre_meta.tables['users'].columns['password'].create()
    post_meta.tables['users'].columns['password_hash'].drop()
