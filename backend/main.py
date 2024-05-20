from fastapi import FastAPI, File, UploadFile, Response
from fastapi.responses import FileResponse
import os
import shutil
import json
import os
import shutil
from ultralytics import YOLO
import torch
from torchvision import models, transforms
from PIL import Image
import yolo2cnn
image_path='C:/Users/daniel/Desktop/MEAT/backend/KakaoTalk_20240520_201026903.jpg' #임시
YOLO_MODEL_PATH = 'C:/Users/daniel/Desktop/MEAT/backend/gogi/models/yolo.pt'
CNN_MODEL_PATH = 'C:/Users/daniel/Desktop/MEAT/backend/gogi/models/cnn.pth'
TEMP_PATH = 'C:/Users/daniel/Desktop/MEAT/backend/gogi/temp'

# FastAPI 인스턴스를 만듭니다.
app = FastAPI()

@app.get("/")  # 루트 엔드포인트를 정의합니다.
async def read_root():
    return {"message": "Hello"}


@app.get("/items/{item_id}")  # 기타 엔드포인트를 추가할 수 있습니다.
async def read_item(item_id: int, q: str = None):
    return {"item_id": item_id, "q": q}

# file: UploadFile = File(...)
@app.post("/upload/")
async def create_upload_file():
    """
        이미지 파일 전송 받아서 로컬에 저장 
    """
    # image_path = "C:/Users/daniel/Desktop/MEAT/backend/gogi/a.jpg"
    image_path="C:/Users/daniel/Desktop/MEAT/backend/KakaoTalk_20240520_201026903.jpg" #임시
    # dir_path = os.path.dirname(image_path) # 이미지 주소 할당
    
    #프엔 실행할 때 주석 해제
    # folder = 'uploads'
    # os.makedirs(folder, exist_ok=True)
    # file_location = f"{folder}/file.jpg"

    # with open(file_location, "wb") as buffer:
    #     shutil.copyfileobj(File.file, buffer)   
    
    json_string = yolo2cnn.yolo2cnn(YOLO_MODEL_PATH, CNN_MODEL_PATH, TEMP_PATH, image_path)
    
    # dir_path = os.path.dirname(__file__)
    
    # folder_to_delete = os.path.join(dir_path, "predict")
    # if os.path.exists(folder_to_delete):
    #     shutil.rmtree(folder_to_delete)
    #     print(f"Folder {folder_to_delete} deleted successfully.")
    # else:
    #     print(f"Folder {folder_to_delete} does not exist.")
        
    return json_string
