# ticket_api.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from your_classifier_module import classify_ticket_rag

app = FastAPI()

# Allow CORS for your Flutter app
origins = [
    "http://localhost",        # for web testing
    "http://127.0.0.1",
    "http://10.0.2.2",        # Android emulator
    "http://192.168.1.9",     # your PC IP for real devices
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # allow all origins for testing
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
class TicketRequest(BaseModel):
    text: str

@app.post("/classify_ticket")
def classify_ticket(ticket: TicketRequest):
    result = classify_ticket_rag(ticket.text)
    return result

# Optional: run directly
if __name__ == "__main__":
    import uvicorn
    uvicorn.run("ticket_api:app", host="0.0.0.0", port=8000, reload=True)
