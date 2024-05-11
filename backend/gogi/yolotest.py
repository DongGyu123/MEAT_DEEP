import torch
from ultralytics import YOLO
import cv2
import ultralytics



# model = YOLO('yolov8n.yaml')  # load a pretrained YOLOv8n detection model
model = YOLO('yolov8n.pt')

model.train(data='data.yaml', epochs=3)  # train the model
model.save('gogiyolo.pt')
loaded_model = YOLO('gogiyolo.pt')

result = loaded_model.predict('datasets/test/images/360_F_277839226_3gYD8CguMESgesR2kMij52nKqLmgoskh_jpg.rf.641063b62af9fce37a2462384c1a1778.jpg')

print(result[0].boxes)

result_image = result[0].plot()
cv2.imshow('Result Image', result_image)
cv2.waitKey(0)
cv2.destroyAllWindows()

