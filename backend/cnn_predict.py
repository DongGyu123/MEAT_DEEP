import torch
import torch.nn as nn
from torchvision import models, transforms
from PIL import Image


def load_model(model_path, num_classes):
    device = torch.device('cpu')
    model = models.resnet50().to(device)  # 모델 구조 초기화 : 기본 ResNet50 모델
    model.fc = torch.nn.Linear(model.fc.in_features, num_classes)  # 출력 계층 수정
    model.load_state_dict(torch.load(model_path, map_location=device))

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
        softmax = nn.Softmax(dim=1)
        confidence = softmax(outputs).tolist()
        print(f"output: {confidence[0][0]:.2f}")
        _, predicted = torch.max(outputs, 1)
        cls = predicted.item()
        if confidence[0][0] >= 0.7 and cls == 0:
            cls = 1
        else:
            cls = 0
        result = [confidence[0][0], cls]
        return result  # 클래스 인덱스 반환


def main(model_path, num_classes, image_path):
    model = load_model(model_path, num_classes)
    image = preprocess_image(image_path)
    prediction = predict(model, image)
    return prediction
