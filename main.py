import json
from fastapi import FastAPI, File, UploadFile, Response
import os
import shutil
from fastapi.responses import FileResponse
from ultralytics import YOLO
from typing import Union
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
    image_path = "C:/Users/daniel/Desktop/MEAT/backend/gogi/runs/detect/predict/a.jpg"
    dir_path = os.path.dirname(image_path)
    
    folder = 'uploads'
    os.makedirs(folder, exist_ok=True)
    file_location = f"{folder}/file.jpg"

    with open(file_location, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
    result=model.predict(source='./uploads/file.jpg', save=True)
    data=result[0].boxes
    respond = {
    'cls': data.cls.tolist(),  # 리스트로 변환하여 추가
    'conf': data.conf.tolist(),
    'id': data.id,
    'xyxyn': data.xyxyn.tolist()  # 리스트로 변환하여 추가
    }
    print('the value of result: ', type(respond['cls']), type(respond['conf']), type(respond['id']), type(respond['xyxyn']))
   
    json_string = json.dumps(respond)
    dir_path = os.path.dirname(__file__)
    # folder_to_delete = os.path.join(dir_path, "predict")
    # if os.path.exists(folder_to_delete):
    #     shutil.rmtree(folder_to_delete)
    #     print(f"Folder {folder_to_delete} deleted successfully.")
    # else:
    #     print(f"Folder {folder_to_delete} does not exist.")
        
    return json_string
