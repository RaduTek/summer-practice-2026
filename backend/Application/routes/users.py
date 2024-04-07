from Application import app
import configparser
import pymongo

# from backend.Application.routes.auth import token_required

secret = configparser.ConfigParser()
secret.read('Application/scripts/config.ini')
client = pymongo.MongoClient(secret['db']['MONGO_URL'])
mydb = client.energysaving


@app.route('/users', methods=['GET'])
# @token_required
def get_user(current_user):
    pass