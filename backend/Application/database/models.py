from bson.objectid import ObjectId
from mongoengine import *
from .db import db


class User(Document):
    username = StringField(required=True, unique=True)
    password = StringField(required=True)
