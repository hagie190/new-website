# -*- coding: utf-8 -*-

import os
from sqlite3 import dbapi2 as sqlite3
from flask import Blueprint, request, session, g, redirect, url_for, abort, \
     render_template, flash, current_app

bp = Blueprint('quill', __name__)

def connect_db():
    rv = sqlite3.connect(os.path.join(current_app.instance_path, current_app.config['DATABASE']))
    rv.row_factory = sqlite3.Row
    return rv

def init_db():
    db = get_db()
    with current_app.open_resource('schema.sql', mode='r') as f:
        db.cursor().executescript(f.read())
    db.commit()

def get_db():
    if not hasattr(g, 'sqlite_db'):
        g.sqlite_db = connect_db()
    return g.sqlite_db

@bp.route('/')
def dashboard():
    return render_template('dashboard.html', display_name='Foo Bar')

@bp.route('/login')
def login():
    return render_template('login.html', facebook_client_id=current_app.config['FACEBOOK_CLIENT_ID'])

@bp.route('/logout')
def logout():
    return ''
