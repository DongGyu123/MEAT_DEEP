from ultralytics import YOLO
import cv2
import os

"""
    DATASET_DIR mode : roboflow dataset - export - download zip to computer (yolov8, txt annotation)
    ORI_IMG_DIR mode : 임의 test dataset - single dir 
"""
TRAINED_MODEL_PATH = 'gogibest.pt'  # "yolov8n.pt"
# ORI_IMG_DIR = "path/to/test_dir"  # 테스트 이미지가 있는 디렉토리  #------splited=False
DATASET_DIR = "datasets"  # 데이터셋이 있는 최상위 디렉토리          #------splited=True
CROP_IMG_DIR = "cropped_images"  # 크롭된 이미지를 저장할 디렉토리


def save_cropped_image_with_model(model_path, dataset_dir, save_dir, splited=True):
    model = YOLO(model_path)
    names = model.names

    if not os.path.exists(save_dir):
        os.mkdir(save_dir)

    # 디렉토리 순회 (train, valid, test) -------------------- splited=True
    for subdir in ["train", "valid", "test"]:
        img_dir = os.path.join(dataset_dir, subdir, "images")  # 이미지 폴더 경로
        for filename in os.listdir(img_dir):
            cropsave_single_image(model, names, img_dir, save_dir, filename)

    # 단일 디렉토리 ----------------------------------------- splited=False
    for filename in os.listdir(dataset_dir):
        cropsave_single_image(model, names, dataset_dir, save_dir, filename)


def cropsave_single_image(model, names, img_dir, save_dir, filename):
    file_path = os.path.join(img_dir, filename)
    if os.path.isfile(file_path) and filename.lower().endswith(('.png', '.jpg', '.jpeg')):
        im0 = cv2.imread(file_path)
        if im0 is None:
            return

        results = model.predict(im0, show=False)
        boxes = results[0].boxes.xyxy.cpu().tolist()
        classes = results[0].boxes.cls.cpu().tolist()

        for box, cls in zip(boxes, classes):
            class_name = names[int(cls)]
            class_dir = os.path.join(save_dir, class_name)
            if not os.path.exists(class_dir):
                os.mkdir(class_dir)

            crop_obj = im0[int(box[1]):int(box[3]),
                           int(box[0]):int(box[2])]
            crop_filename = f"{os.path.splitext(filename)[0]}_crop{cls}_{len(os.listdir(class_dir)) + 1}.png"
            cv2.imwrite(os.path.join(
                class_dir, crop_filename), crop_obj)


if __name__ == "__main__":
    save_cropped_image_with_model(
        TRAINED_MODEL_PATH, DATASET_DIR, CROP_IMG_DIR, splited=True)
