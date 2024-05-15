import cnn
import json
import os
import shutil
from ultralytics import YOLO

def yolo2cnn(yolo_model_path, cnn_model_path, temp_path, image_path):

    model_yolo = YOLO(yolo_model_path)
    yolo_result = model_yolo.predict(source=image_path, save=True, save_crop=True, project=temp_path, name='yolo_croped')

    croped_images = os.listdir(temp_path + '/yolo_croped/crops/meat')
    cnn_result = []

    for image in croped_images:
        cnn_result.append(cnn.main(cnn_model_path, 2, image))

    shutil.rmtree(temp_path)

    data = yolo_result[0].boxes
    respond = {
    'cls': cnn_result,  # 리스트로 변환하여 추가
    'conf': data.conf.tolist(),
    'id': data.id,
    'xyxyn': data.xyxyn.tolist()  # 리스트로 변환하여 추가
    }
   
    json_string = json.dumps(respond)

    return json_string

