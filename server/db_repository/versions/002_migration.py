from sqlalchemy import *
from migrate import *


from migrate.changeset import schema
pre_meta = MetaData()
post_meta = MetaData()
user_answers = Table('user_answers', post_meta,
    Column('created_on', DateTime, default=ColumnDefault(<sqlalchemy.sql.functions.now at 0x111449f10; now>)),
    Column('updated_on', DateTime, onupdate=ColumnDefault(<sqlalchemy.sql.functions.now at 0x11145b210; now>), default=ColumnDefault(<sqlalchemy.sql.functions.now at 0x11145b110; now>)),
    Column('id', Integer, primary_key=True, nullable=False),
    Column('sec_for_answer', Integer, default=ColumnDefault(30)),
    Column('answer_id', Integer),
    Column('round_id', Integer),
    Column('user_id', Integer),
)

users = Table('users', post_meta,
    Column('created_on', DateTime, default=ColumnDefault(<sqlalchemy.sql.functions.now at 0x111449f10; now>)),
    Column('updated_on', DateTime, onupdate=ColumnDefault(<sqlalchemy.sql.functions.now at 0x11145b210; now>), default=ColumnDefault(<sqlalchemy.sql.functions.now at 0x11145b110; now>)),
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
    Column('total_matches_won', Integer, default=ColumnDefault(0)),
    Column('total_matches_lost', Integer, default=ColumnDefault(0)),
    Column('role', SmallInteger, default=ColumnDefault(0)),
)


def upgrade(migrate_engine):
    # Upgrade operations go here. Don't create your own engine; bind
    # migrate_engine to your metadata
    pre_meta.bind = migrate_engine
    post_meta.bind = migrate_engine
    post_meta.tables['user_answers'].columns['sec_for_answer'].create()
    post_meta.tables['users'].columns['total_matches_lost'].create()
    post_meta.tables['users'].columns['total_matches_won'].create()


def downgrade(migrate_engine):
    # Operations to reverse the above upgrade go here.
    pre_meta.bind = migrate_engine
    post_meta.bind = migrate_engine
    post_meta.tables['user_answers'].columns['sec_for_answer'].drop()
    post_meta.tables['users'].columns['total_matches_lost'].drop()
    post_meta.tables['users'].columns['total_matches_won'].drop()
