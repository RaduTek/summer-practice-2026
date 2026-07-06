from mongoengine import connect # type: ignore


def initialize_db(app):
    mongo_settings = app.config.get('MONGODB_SETTINGS', {})
    host = mongo_settings.get('host')
    if not host:
        raise ValueError('MONGODB_SETTINGS.host is required')

    connect(host=host)

