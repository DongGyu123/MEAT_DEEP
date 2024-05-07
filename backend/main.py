from fastapi import FastAPI

# FastAPI 인스턴스를 만듭니다.
app = FastAPI()

# 루트 엔드포인트를 정의합니다.
@app.get("/")
async def read_root():
    return {"message": "Hello, World!"}

# 기타 엔드포인트를 추가할 수 있습니다.
@app.get("/items/{item_id}")
async def read_item(item_id: int, q: str = None):
    return {"item_id": item_id, "q": q}