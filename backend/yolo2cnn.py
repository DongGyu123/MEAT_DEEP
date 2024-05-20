import cnn
import json
import os
import shutil
from ultralytics import YOLO
import torch


def yolo2cnn(yolo_model_path, cnn_model_path, temp_path, image_path):
    print('yolo2cnn 실행시작')
    model_yolo = YOLO(yolo_model_path)
    yolo_result = model_yolo.predict(source=image_path, save_crop=True, project=temp_path, name='yolo_croped', device='cpu')
    print('1단계 통과')
    croped_images = os.listdir(temp_path + '/yolo_croped/crops/meat')
    print(croped_images)
    cnn_result = []

    for image in croped_images:
        cnn_result.append(cnn.main(cnn_model_path, 2, temp_path + '/yolo_croped/crops/meat/' + image))

    shutil.rmtree(temp_path)

    data = yolo_result[0].boxes
    respond = []
    for i in range(len(cnn_result)):
        respond.append(
        {
        'cls': cnn_result[i][1],  # 리스트로 변환하여 추가
        'conf': cnn_result[i][0].tolist(),
        'id': data.id,
        'xyxyn': data.xyxyn.tolist()  # 리스트로 변환하여 추가
        })
    print(respond, type(respond))
    json_string = json.dumps(respond)

    return json_string


def convert_to_onnx(pytorch_model_path, onnx_model_path):
    # Load the PyTorch model
    model = torch.load(pytorch_model_path)
    # Set the model to evaluation mode
    model.eval()
    # Create a dummy input
    dummy_input = torch.randn(1, 3, 224, 224)
    # Export the model to ONNX
    torch.onnx.export(model, dummy_input, onnx_model_path, verbose=True)