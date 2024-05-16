import cv2
import os

"""
    roboflow dataset - export - download zip to computer (yolov8, txt annotation)
"""
DATASET_DIR = "datasets"  # 데이터셋이 있는 최상위 디렉토리
CROP_IMG_DIR = "cropped_images"  # 크롭된 이미지를 저장할 디렉토리
CLASS_NAME = ["meat"]  # 클래스이름과 ID를 맵핑하기 위해, 직접 클래스 리스트를 정의


def save_cropped_image_with_label(classes, dataset_dir, save_dir):
    if not os.path.exists(save_dir):
        os.mkdir(save_dir)

    # 디렉토리 순회 (train, valid, test)
    for subdir in ["train", "valid", "test"]:
        img_dir = os.path.join(dataset_dir, subdir, "images")  # 이미지 폴더 경로
        label_dir = os.path.join(dataset_dir, subdir, "labels")  # 라벨 폴더 경로

        for filename in os.listdir(img_dir):
            if filename.endswith(('.png', '.jpg', '.jpeg')):
                # 이미지 파일 로드
                img_path = os.path.join(img_dir, filename)
                image = cv2.imread(img_path)
                if image is None:
                    continue
                height, width, _ = image.shape

                # 라벨 파일 로드
                label_path = os.path.join(
                    label_dir, os.path.splitext(filename)[0] + ".txt")
                if not os.path.isfile(label_path):
                    continue

                with open(label_path, 'r') as file:
                    for idx, line in enumerate(file.readlines()):
                        cls_id, x_center, y_center, bbox_width, bbox_height = map(
                            float, line.split())
                        class_name = classes[int(cls_id)]

                        # 디렉토리 생성
                        class_dir = os.path.join(save_dir, class_name)
                        if not os.path.exists(class_dir):
                            os.mkdir(class_dir)

                        # 바운딩 박스 계산
                        x = int((x_center - bbox_width / 2) * width)
                        y = int((y_center - bbox_height / 2) * height)
                        w = int(bbox_width * width)
                        h = int(bbox_height * height)

                        # 이미지 크롭
                        crop_img = image[y:y+h, x:x+w]

                        # 크롭 이미지 저장
                        crop_filename = f"{os.path.splitext(filename)[0]}_{cls_id}_{idx}.png"
                        cv2.imwrite(os.path.join(
                            class_dir, crop_filename), crop_img)

    print("Cropping and saving completed.")


if __name__ == "__main__":
    save_cropped_image_with_label(CLASS_NAME, DATASET_DIR, CROP_IMG_DIR)
