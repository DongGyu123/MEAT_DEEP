import yolo2cnn
from fastapi import FastAPI, File, UploadFile, Response
from fastapi.responses import FileResponse

YOLO_MODEL_PATH = './gogi/models/best.pt'
CNN_MODEL_PATH = './gogi/models/cnn 모델 이름'
TEMP_PATH = './gogi/temp'

# FastAPI 인스턴스를 만듭니다.
app = FastAPI()

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
    
    json_string = yolo2cnn.yolo2cnn(YOLO_MODEL_PATH, CNN_MODEL_PATH, TEMP_PATH, image_path)
    
    dir_path = os.path.dirname(__file__)
    
    # folder_to_delete = os.path.join(dir_path, "predict")
    # if os.path.exists(folder_to_delete):
    #     shutil.rmtree(folder_to_delete)
    #     print(f"Folder {folder_to_delete} deleted successfully.")
    # else:
    #     print(f"Folder {folder_to_delete} does not exist.")
        
    return json_string
