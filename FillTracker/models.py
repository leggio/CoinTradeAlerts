from app import db


class users(db.Model):
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    username = db.Column(db.String(20))
    password = db.Column(db.String(20))
    email = db.Column(db.String(40))
    api_key = db.Column(db.String(200))
    secret_key = db.Column(db.String(200))
    passphrase = db.Column(db.String(200))
    contact = db.Column(db.String(200))
    fills = db.Column(db.Integer)

    def __repr__(self):
        return 'Username: {}'.format(self.username)
