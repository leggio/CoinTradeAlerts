from app import *
from email.mime.multipart import MIMEMultipart
import hmac, hashlib, time, requests, base64
from email.mime.text import MIMEText
import models
from flask import request, jsonify
from datetime import datetime
import smtplib



@app.route('/')
def index():
    return 'Fill Tracker'


@app.route('/authenticate', methods=['POST'])
def authenticate():

    if request.method == 'POST':
        content = request.get_json()
        print content

    api_key = content['api_key']
    secret_key = content['secret_key']
    passphrase = content['passphrase']
    username = content['username']

    api_url = 'https://api.gdax.com/fills'

    timestamp = str(time.time())
    request_type = api_url.split('.com/')[1]
    message = '{}GET/{}'.format(timestamp, request_type)
    hmac_key = base64.b64decode(secret_key)
    signature = hmac.new(hmac_key, message, hashlib.sha256)
    signature_b64 = signature.digest().encode('base64').rstrip('\n')

    headers = {
        'CB-ACCESS-SIGN': signature_b64,
        'CB-ACCESS-TIMESTAMP': timestamp,
        'CB-ACCESS-KEY': api_key,
        'CB-ACCESS-PASSPHRASE': passphrase,
        'Content-Type': 'application/json'
    }

    response = requests.get(api_url, headers=headers)
    print response.status_code
    print response.content
    print username
    if response.status_code != 200:
        return jsonify({'status': 1})
    
    data = response.json()
    fills = len(data)
    models.users.query.filter_by(username=username).update(dict(api_key=api_key,
                                                             secret_key=secret_key,
                                                             passphrase=passphrase,
                                                             fills=fills))
    db.session.commit()
    return jsonify({'status': 0})


@app.route('/register', methods=['POST', 'GET'])
def regiser():
    if request.method == 'POST':
        content = request.get_json()
        username = content['username']
        password = base64.b64encode(content['password'])
        email = content['email']

    if db.session.query(models.users).filter_by(username=username).scalar() is not None:
        status = 1
        message = 'Username already exists'
        response = {'status': status, 'message': message, 'username': username}
        return jsonify(response)
    else:
        status = 0
        message = 'Success'

    if db.session.query(models.users).filter_by(email=email).scalar() is not None:
        status = 1
        message = 'Email address already exists'
        response = {'status': status, 'message': message, 'username': username}
        return jsonify(response)
    else:
        status = 0
        message = 'Success'

    register_user = models.users(username=username, password=password, email=email)
    db.session.add(register_user)
    db.session.commit()

    message = {'status': status, 'message': message, 'username': username}
    return jsonify(message)


@app.route('/login', methods=['POST'])
def login():
    if request.method == 'POST':
        content = request.get_json()
        username = content['username']
        password = content['password']

    if db.session.query(models.users).filter_by(username=username).scalar() is None:
        message = {'status': 1, 'username': 'null'}
        return jsonify(message)

    user = models.users.query.filter_by(username=username).first()
    stored_password = user.password

    db.session.commit()

    if password == base64.b64decode(stored_password):
        message = {'status': 0, 'username': username}
        return jsonify(message)
    else:
        message = {'status': 1, 'username': username}
        return jsonify(message)

@app.route('/fill-tracker')
def fill_tracker():
    all_users = models.users.query.all()
    print all_users
    api_url = 'https://api.gdax.com/fills'
    for user in all_users:
        username = user.username
        api_key = user.api_key
        secret_key = user.secret_key
        passphrase = user.passphrase
        contact = user.contact
        fills = user.fills
        print username
        
        if api_key is None or 'none':
            continue

        print fills
        
        timestamp = str(time.time())
        request_type = api_url.split('.com/')[1]
        message = '{}GET/{}'.format(timestamp, request_type)
        hmac_key = base64.b64decode(secret_key)
        signature = hmac.new(hmac_key, message, hashlib.sha256)
        signature_b64 = signature.digest().encode('base64').rstrip('\n')

        headers = {
            'CB-ACCESS-SIGN': signature_b64,
            'CB-ACCESS-TIMESTAMP': timestamp,
            'CB-ACCESS-KEY': api_key,
            'CB-ACCESS-PASSPHRASE': passphrase,
            'Content-Type': 'application/json'
        }

        response = requests.get(api_url, headers=headers)
        data = response.json()

        current_fills = len(data)
        delta = current_fills - fills
        print delta

        if delta == 0:
            continue

        models.users.query.filter_by(username=username).update(dict(fills=current_fills))
        db.session.commit()

        new_fills = []
        if delta == 1:
            new_fills.append(data[0])
        else:
            for i in range(0, delta):
                new_fills.append(data[i])

        alert = []
        for i in new_fills:
            alert.append('{}: {} {} at {} Total:{}'.format(str(i['side']), str(i['size']), str(i['product_id'].split('-')[0]), str(i['price']), str(float(i['size']) * float(i['price']))))

        to_address = contact
        from_address = 'alerts@cointradealerts.com'

        mail = MIMEMultipart()
        mail['Subject'] = 'Coin Trade Alerts'
        mail['From'] = from_address
        mail['To'] = to_address
        mail.attach(MIMEText('\n'.join(alert)))

        s = smtplib.SMTP('smtp.gmail.com', 587)
        s.ehlo()
        s.starttls()
        s.login('', '')
        s.sendmail(from_address, to_address, mail.as_string())
        s.quit()

    return 'foo'


@app.route('/contact', methods=['POST'])
def contact():
    if request.method == 'POST':
        content = request.get_json()
        contact = content['contact']
        username = content['username']

    models.users.query.filter_by(username=username).update(dict(contact=contact))

    return jsonify({'status': 0})


@app.route('/disable', methods=['POST'])
def disable():
    if request.method == 'POST':
        content = request.get_json()
        username = content['username']

    models.users.query.filter_by(username=username).update(dict(api_key='none',
                                                         secret_key='none',
                                                         passphrase='none',
                                                         contact='none',
                                                         fills=0))
    db.session.commit()

    return jsonify({'status': 0})


