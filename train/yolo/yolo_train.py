import torch
from ultralytics import YOLO
import os
from multiprocessing import freeze_support


if __name__ == '__main__':
    freeze_support()

    """gpu 사용"""
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    # print(device)
    os.environ['KMP_DUPLICATE_LIB_OK'] = 'True'

    """모델학습"""
    BASE_WEIGHT_PATH = 'gogibest.pt'
    DATA_PATH = 'handmade_data.yaml'
    EPOCH = 300

    # Load a model
    model = YOLO(BASE_WEIGHT_PATH)  # load a pretrained model (recommended for training)
    # Use the model
    results = model.train(data=DATA_PATH, epochs=EPOCH, device=0)  # train the model

    print(model.val())

