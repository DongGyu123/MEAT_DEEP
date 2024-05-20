
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
def load_model(model_path, num_classes):
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    model = models.resnet50().to(device)  # 모델 구조 초기화 : 기본 ResNet50 모델
    model.fc = torch.nn.Linear(model.fc.in_features, num_classes)  # 출력 계층 수정
    if torch.cuda.is_available():
        model.load_state_dict(torch.load(model_path))
    else:
        # CUDA를 사용할 수 없는 경우 CPU로 매핑하여 모델 로드
        model.load_state_dict(torch.load(model_path, map_location=torch.device('cpu')))
    model.eval()  
    return model

def preprocess_image(image_path):
    transform = transforms.Compose([
        transforms.Resize(224),
        transforms.ToTensor(),
        # transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
    ])
    image = Image.open(image_path)
    image = transform(image).unsqueeze(0)  # 배치 차원 추가
    return image

def predict(model, processed_image):
    with torch.no_grad():  # 그라디언트 계산 비활성화
        outputs = model(processed_image)
        _, predicted = torch.max(outputs, 1)
        return predicted.item()  # 클래스 인덱스 반환
    
def main(model_path, num_classes, image_path):
    model = load_model(model_path, num_classes)
    image = preprocess_image(image_path)
    prediction = predict(model, image)
    print("Predicted class index:", prediction)
    return 1 if prediction == 0 else 0
    
def yolo2cnn(yolo_model_path, cnn_model_path, temp_path, image_path):
    print('yolo2cnn 실행시작')
    model_yolo = YOLO(yolo_model_path)
    yolo_result = model_yolo.predict(source=image_path, save_crop=True, project=temp_path, name='yolo_croped', device='cpu')
    print('1단계 통과')
    croped_images = os.listdir(temp_path + '/yolo_croped/crops/meat')
    print(croped_images)
    cnn_result = []

    for image in croped_images:
        cnn_result.append(main(cnn_model_path, 2, temp_path + '/yolo_croped/crops/meat/' + image))

    shutil.rmtree(temp_path)

    data = yolo_result[0].boxes
    respond = []
    for i in range(len(cnn_result)):
        respond.append(
        {
        'cls': cnn_result[i][1],  # 리스트로 변환하여 추가
        'conf': cnn_result[i][0],
        'id': data.id,
        'xyxyn': data.xyxyn.tolist()  # 리스트로 변환하여 추가
        })
   
    json_string = json.dumps(respond)

    return json_string
image_path='C:/Users/daniel/Desktop/MEAT/backend/KakaoTalk_20240520_201026903.jpg' #임시
YOLO_MODEL_PATH = 'C:/Users/daniel/Desktop/MEAT/backend/gogi/models/yolo.pt'
CNN_MODEL_PATH = 'C:/Users/daniel/Desktop/MEAT/backend/gogi/models/cnn.pth'
TEMP_PATH = 'C:/Users/daniel/Desktop/MEAT/backend/gogi/temp'
json_string = yolo2cnn(YOLO_MODEL_PATH, CNN_MODEL_PATH, TEMP_PATH, image_path)
print(json_string)