from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import firebase_admin
from firebase_admin import credentials, messaging

cred = credentials.Certificate("backend/serviceAccountKey.json")
if not firebase_admin._apps:
    firebase_admin.initialize_app(cred)

app = FastAPI()

class NotifRequest(BaseModel):
    token: str
    title: str
    body: str
    data: dict[str, str] | None = None

@app.post("/send-notification")
def send_notification(req: NotifRequest):
    try:
        msg = messaging.Message(
            token=req.token,
            notification=messaging.Notification(title=req.title, body=req.body),
            data=req.data or {},
        )
        message_id = messaging.send(msg)
        return {"status": "ok", "message_id": message_id}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))