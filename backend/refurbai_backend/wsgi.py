"""
WSGI config for refurbai_backend project.

It exposes the WSGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/6.0/howto/deployment/wsgi/
"""

import os
import sys
import traceback

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'refurbai_backend.settings')

_application = None
_error_msg = None

try:
    from django.core.wsgi import get_wsgi_application
    _application = get_wsgi_application()
except Exception as e:
    _error_msg = f"Startup Error:\n{traceback.format_exc()}"

def application(environ, start_response):
    if _error_msg:
        status = '500 Internal Server Error'
        headers = [('Content-type', 'text/plain; charset=utf-8')]
        start_response(status, headers)
        return [_error_msg.encode('utf-8')]
    return _application(environ, start_response)
