import pymysql
from flask import Flask
from flask_sqlalchemy import SQLAlchemy


# setup MySQLDb using pymysql as a helper
pymysql.install_as_MySQLdb()

# initial creation of Flask app
app = Flask(__name__)
# database connection string
app.config['SQLALCHEMY_DATABASE_URI'] = ''
db = SQLAlchemy(app)

SQLALCHEMY_TRACK_MODIFICATIONS = False

# import database models and Flask views (url endpoints)
from models import *
from views import *

# create database tables (if they don't exist) and run Flask app
if __name__ == '__main__':
    db.create_all()
    app.run(debug=True, host='0.0.0.0', threaded=True, port=80)

