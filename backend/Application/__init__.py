
from flask import Flask
from .database.db import initialize_db
from flask_cors import CORS
import configparser

secret = configparser.ConfigParser()
secret.read('Application/scripts/config.ini') 


app = Flask("__name__", static_folder='Application/static')
app.config['MONGODB_SETTINGS'] = {
    'host': secret['db']['MONGO_URL']
}
initialize_db(app)
CORS(app)

from .routes.users import app
from .routes.auth import app



  








