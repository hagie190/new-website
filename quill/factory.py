# -*- coding: utf-8 -*-
import os
from flask import Flask, g
from werkzeug.utils import find_modules, import_string

from quill.blueprints.quill import init_db

def create_app(config=None):
    app = Flask('quill')

    app.config.update(config or {})
    app.config.from_envvar('QUILL_SETTINGS', silent=False)

    register_blueprints(app)
    register_cli(app)
    register_teardowns(app)

    return app

def register_blueprints(app):
    for name in find_modules('quill.blueprints'):
        mod = import_string(name)
        if hasattr(mod, 'bp'):
            app.register_blueprint(mod.bp)
    return None

def register_cli(app):
    @app.cli.command('initdb')
    def initdb_command():
        init_db()
        print('Initialized the database.')

def register_teardowns(app):
    @app.teardown_appcontext
    def close_db(error):
        if hasattr(g, 'sqlite_db'):
            g.sqlite_db.close()
