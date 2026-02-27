from app.routes import auth

app.include_router(auth.router)
from app.models import user, account
from app.database import engine
from app.models import user, account

Base.metadata.create_all(bind=engine)
