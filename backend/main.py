import os
import uuid
from pathlib import Path
from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from dotenv import load_dotenv
import google.generativeai as genai
import asyncpg

load_dotenv()

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
DATABASE_URL = os.getenv("DATABASE_URL")

system_prompt_path = Path(__file__).parent / "system_prompt.txt"
SYSTEM_PROMPT = system_prompt_path.read_text(encoding="utf-8")

genai.configure(api_key=GEMINI_API_KEY)

db_pool = None


@asynccontextmanager
async def lifespan(app: FastAPI):
    global db_pool
    db_pool = await asyncpg.create_pool(DATABASE_URL)
    async with db_pool.acquire() as conn:
        await conn.execute("""
            CREATE TABLE IF NOT EXISTS conversations (
                id SERIAL PRIMARY KEY,
                session_id UUID NOT NULL,
                role VARCHAR(10) NOT NULL,
                content TEXT NOT NULL,
                created_at TIMESTAMP DEFAULT NOW()
            );
            CREATE INDEX IF NOT EXISTS idx_conv_session ON conversations(session_id, created_at);
        """)
    yield
    await db_pool.close()


app = FastAPI(title="İmam AI", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


class ChatRequest(BaseModel):
    session_id: str | None = None
    message: str


class ChatResponse(BaseModel):
    reply: str
    session_id: str


@app.post("/api/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    session_id = request.session_id or str(uuid.uuid4())

    async with db_pool.acquire() as conn:
        rows = await conn.fetch(
            "SELECT role, content FROM conversations "
            "WHERE session_id = $1 ORDER BY created_at",
            uuid.UUID(session_id),
        )

    history = [
        {"role": row["role"], "parts": [{"text": row["content"]}]}
        for row in rows
    ]

    gemini_model = genai.GenerativeModel(
        model_name="gemini-2.0-flash",
        system_instruction=SYSTEM_PROMPT,
    )
    chat_session = gemini_model.start_chat(history=history)

    try:
        response = chat_session.send_message(request.message)
        reply = response.text
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

    async with db_pool.acquire() as conn:
        await conn.executemany(
            "INSERT INTO conversations (session_id, role, content) VALUES ($1, $2, $3)",
            [
                (uuid.UUID(session_id), "user", request.message),
                (uuid.UUID(session_id), "model", reply),
            ],
        )

    return ChatResponse(reply=reply, session_id=session_id)


@app.get("/api/history/{session_id}")
async def get_history(session_id: str):
    async with db_pool.acquire() as conn:
        rows = await conn.fetch(
            "SELECT role, content, created_at FROM conversations "
            "WHERE session_id = $1 ORDER BY created_at",
            uuid.UUID(session_id),
        )
    return [
        {
            "role": r["role"],
            "content": r["content"],
            "created_at": str(r["created_at"]),
        }
        for r in rows
    ]


@app.get("/health")
async def health():
    return {"status": "ok"}
