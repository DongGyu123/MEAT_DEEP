from fastapi import FastAPI, File, UploadFile
import os
import shutil
from fastapi.responses import FileResponse
from ultralytics import YOLO
# FastAPI 인스턴스를 만듭니다.
app = FastAPI()
model = YOLO('./gogi/runs/detect/train10/weights/best.pt')

@app.get("/")  # 루트 엔드포인트를 정의합니다.
async def read_root():
    return {"message": "Hello, World!"}


@app.get("/items/{item_id}")  # 기타 엔드포인트를 추가할 수 있습니다.
async def read_item(item_id: int, q: str = None):
    return {"item_id": item_id, "q": q}


@app.post("/upload/")
async def create_upload_file(file: UploadFile = File(...)):
    """
        이미지 파일 전송 받아서 로컬에 저장 
    """
    folder = 'uploads'
    os.makedirs(folder, exist_ok=True)
    file_location = f"{folder}/{file.filename}"

    with open(file_location, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
    result=model.predict(source='./uploads/gogi.jpg', save=True)
    image_path = "C:/Users/daniel/Desktop/MEAT/backend/gogi/runs/detect/predict/a.jpg"    
    return FileResponse(image_path)
