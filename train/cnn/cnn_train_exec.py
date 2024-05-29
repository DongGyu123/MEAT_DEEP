import torch
import torch.nn as nn
from torch.utils.data import DataLoader
import cnn_train as cg
import os
os.environ['CUDA_LAUNCH_BLOCKING'] = '1'
os.environ['KMP_DUPLICATE_LIB_OK'] = 'True'

# dataset
###################
"""ADJUST PATH"""
###################
DATA_PATH = 'cnn_datasets'
NUM_CLASSES = 2

# hyperparameters
BATCH_SIZE = 32
LEARNING_RATE = 0.001
NUM_EPOCHS = 16

# model save
MODEL_PATH = f'cnn/aug_handmade_lr{LEARNING_RATE}_batch{BATCH_SIZE}_epoch{NUM_EPOCHS}_cnn_NT.pth'


# train setting essential
GPU_NUM = 0
device = torch.device(f'cuda:{GPU_NUM}' if torch.cuda.is_available() else 'cpu')
model = cg.load_pretrained_resnet(NUM_CLASSES).to(device)
criterion = nn.CrossEntropyLoss()
params_to_update = cg.check_params_to_update(model)
optimizer_ft = torch.optim.SGD(
    params_to_update, lr=LEARNING_RATE, momentum=0.9)


# load data
train_dataset = cg.CustomDataset(DATA_PATH, data_type='train', transform=cg.transform['train'])
val_dataset = cg.CustomDataset(DATA_PATH, data_type='val', transform=cg.transform['eval'])
test_dataset = cg.CustomDataset(DATA_PATH, data_type='test', transform=cg.transform['eval'])

train_loader = DataLoader(train_dataset, batch_size=BATCH_SIZE, shuffle=True)
val_loader = DataLoader(val_dataset, batch_size=BATCH_SIZE, shuffle=False)
test_loader = DataLoader(test_dataset, batch_size=BATCH_SIZE, shuffle=False)


"""show few part of train & val dataset"""
# cg.show_dataloader(train_loader, title="train dataset")
# cg.show_dataloader(val_loader, title="val dataset")
# cg.show_dataloader(test_loader, title="test dataset")


# check code
print(model)
print(device)


"""Training"""
fine_model, history = cg.train_model(model, train_loader, val_loader, criterion, optimizer_ft, device, num_epochs=NUM_EPOCHS)

# save
torch.save(fine_model.state_dict(), MODEL_PATH)
# show
cg.result_plot(history)

# evaluate with test set
cg.evaluate_model(model, test_loader, criterion, device)

