from app.routes import auth

app.include_router(auth.router)
from app.models import user, account