import torch
from torchvision import models, transforms
from PIL import Image

def load_model(model_path, num_classes):
    model = models.resnet50()  # 모델 구조 초기화 : 기본 ResNet50 모델
    model.fc = torch.nn.Linear(model.fc.in_features, num_classes)  # 출력 계층 수정
    model.load_state_dict(torch.load(model_path))  # 가중치 불러오기
    model.eval()  # 추론 모드로 설정
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