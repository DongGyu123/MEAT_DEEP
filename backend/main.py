from fastapi import FastAPI, File, UploadFile
import os
import shutil
import os
import shutil
from backend import yolo2cnn


YOLO_MODEL_PATH = '../models/yolo.pt'
CNN_MODEL_PATH = '../models/cnn.pth'
UPLOAD_PATH = '../backend/uploads'
BACKEND_PATH = '../backend'

# FastAPI 인스턴스를 만듭니다.
app = FastAPI()


@app.get("/")  # 루트 엔드포인트를 정의합니다.
async def read_root():
    return {"message": "Hello"}


@app.get("/items/{item_id}")  # 기타 엔드포인트를 추가할 수 있습니다.
async def read_item(item_id: int, q: str = None):
    return {"item_id": item_id, "q": q}


@app.post("/upload/")
async def create_upload_file(file: UploadFile = File(...)):
    """
        이미지 파일 전송 받아서 로컬에 저장 
    """

    # 프엔 실행할 때 주석 해제
    folder = UPLOAD_PATH
    os.makedirs(folder, exist_ok=True)
    file_location = f"{folder}/file.jpg"
    print('received1')

    with open(file_location, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
    print('received2')
    json_string = yolo2cnn.yolo2cnn(
        YOLO_MODEL_PATH, CNN_MODEL_PATH, BACKEND_PATH, file_location)
    print(json_string, type(json_string))
    return json_string
