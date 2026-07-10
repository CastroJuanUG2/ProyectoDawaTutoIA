from flask import Flask, g
from flask_cors import CORS

from app.config import Config
from app.routes.health_routes import health_bp
from app.routes.auth_routes import auth_bp
from app.routes.academic_routes import academic_bp
from app.routes.tutoring_routes import tutoring_bp
from app.routes.notification_routes import notification_bp
from app.routes.ia_routes import ia_bp
from app.utils.trace import generate_trace_id
from app.utils.responses import error_response


def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)

    CORS(app)

    @app.before_request
    def set_trace_id():
        g.trace_id = generate_trace_id()

    app.register_blueprint(health_bp, url_prefix=Config.API_PREFIX)
    app.register_blueprint(auth_bp, url_prefix=Config.API_PREFIX)
    app.register_blueprint(academic_bp, url_prefix=Config.API_PREFIX)
    app.register_blueprint(tutoring_bp, url_prefix=Config.API_PREFIX)
    app.register_blueprint(notification_bp, url_prefix=Config.API_PREFIX)
    app.register_blueprint(ia_bp, url_prefix=Config.API_PREFIX)

    @app.errorhandler(404)
    def not_found(_error):
        return error_response("ROUTE_NOT_FOUND", status_code=404)

    @app.errorhandler(500)
    def internal_error(_error):
        return error_response("INTERNAL_SERVER_ERROR", status_code=500)

    return app