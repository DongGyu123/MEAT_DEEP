from . import cnn_predict
import json
import os
import shutil
from ultralytics import YOLO
import torch


def yolo2cnn(yolo_model_path, cnn_model_path, backend_path, image_path):
    yolo_name = 'yolo_croped'
    croped_path = backend_path+f'/{yolo_name}/crops/meat/'

    print('yolo2cnn 실행시작')
    model_yolo = YOLO(yolo_model_path)
    yolo_result = model_yolo.predict(
        source=image_path, save_crop=True, project=backend_path, name=yolo_name, device='cpu')
    print('yolo_result: \n', yolo_result)
    print('1단계 통과')

    print(croped_path)
    croped_images = os.listdir(croped_path)
    print(croped_images)
    cnn_result = []

    for image in croped_images:
        cnn_result.append(cnn_predict.main(
            cnn_model_path, 2, croped_path + image))

    shutil.rmtree(f'{backend_path}/{yolo_name}')

    data = yolo_result[0].boxes
    respond = {'cls': [], 'conf': []}
    for i in range(len(cnn_result)):
        respond['cls'].append(cnn_result[i][1])
        respond['conf'].append(cnn_result[i][0])
    respond['xywhn'] = data.xywhn.tolist()  # 리스트로 변환하여 추가
    # json_string = json.dumps(respond)

    return respond
