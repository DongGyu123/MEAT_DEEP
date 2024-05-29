import os
from torchvision import transforms
from torch.utils.data import Dataset
from PIL import Image
import torch
import torch.nn as nn
import torchvision.models as models
from torchvision.models import ResNet50_Weights
import numpy as np
import matplotlib.pyplot as plt


"""Dataset Utils"""
class CustomDataset(Dataset):
    def __init__(self, root_dir, data_type, transform=None):
        """
        Initializes the dataset.

        :param root_dir: The root directory where the data is stored.
        :param data_type: The type of data to load ('train', 'val', or 'test').
        :param transform: The transformations to be applied to the images.
        """
        self.root_dir = root_dir
        self.transform = transform
        self.data_type = data_type
        self.data = []
        self.labels = []

        dataset_path = os.path.join(self.root_dir, data_type)
        self.class_to_idx = {cls_name: i for i, cls_name in enumerate(os.listdir(dataset_path))}
        for cls_name, idx in self.class_to_idx.items():
            cls_dir = os.path.join(dataset_path, cls_name)
            for img_name in os.listdir(cls_dir):
                if img_name.lower().endswith(('png', 'jpg', 'jpeg')):
                    self.data.append(os.path.join(cls_dir, img_name))
                    self.labels.append(idx)

        print("------------------------------------")
        print(f"Dataset Type: {data_type}")
        print(f"Class Index Mapping: {self.class_to_idx}")
        print(f"Number of Images: {len(self.data)}")
        print("------------------------------------")

    def __len__(self):
        return len(self.data)

    def __getitem__(self, idx):
        img_path = self.data[idx]
        image = Image.open(img_path).convert('RGB')
        label = self.labels[idx]

        if self.transform:
            image = self.transform(image)

        return image, label


transform = {
    'train': transforms.Compose([
                                transforms.ToTensor(),
                                transforms.Resize((224, 224)), # ResNet input size
                                # transforms.Normalize([meanR, meanG, meanB], [stdR, stdG, stdB]) normalize the color value of IMAGENET
                                # transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225]),
                                # augmentations
                                # transforms.RandomResizedCrop((224, 224)), # 무작위 크롭 후 224x224로 리사이즈
                                # transforms.RandomVerticalFlip(),   # 50% 확률로 수직 뒤집기
                                # transforms.RandomHorizontalFlip(), # 50% 확률로 수평 뒤집기
                                # transforms.RandomRotation(10),     # -10도에서 10도 사이로 무작위 회전
                                # transforms.ColorJitter(brightness=0.2, contrast=0.2, saturation=0.2, hue=0.1),  # 색상 변조
                                # transforms.GaussianBlur(kernel_size=(5, 5), sigma=(0.1, 2.0)),  # 가우시안 블러 적용
                                ]),
    'eval': transforms.Compose([
                                transforms.ToTensor(),
                                transforms.Resize((224, 224)),
                                # transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225]),
                              ])
}


def show_dataloader(dataloader, title, num_images=4):
    TOTAL_WIDTH = 8 # 10
    plt.figure(figsize=(TOTAL_WIDTH, 1+TOTAL_WIDTH/num_images))
    col_num = num_images
    data_exists = False

    for batch_idx, (images, labels) in enumerate(dataloader):
        data_exists = True
        if batch_idx == 0:
            for i in range(min(num_images, len(images))):
                plt.subplot(1, col_num, i+1)
                plt.axis('off')
                image_np = images[i].numpy()
                image_np = np.transpose(image_np, (1, 2, 0))
                plt.imshow(image_np)
                plt.title(str(labels[i].item()))
            plt.suptitle(title)
            break

    if not data_exists:
        plt.text(0.5, 0.5, 'No data available', ha='center', va='center', fontsize=12)
        plt.suptitle(title)


"""Log Utils"""
def accuracy(output, target, topk=(1,)):
    """Computes the precision@k for the specified values of k"""
    maxk = max(topk)
    batch_size = target.size(0)

    _, pred = output.topk(maxk, 1, True, True)
    pred = pred.t()
    correct = pred.eq(target.view(1, -1).expand_as(pred))

    res = []
    for k in topk:
        correct_k = correct[:k].view(-1).float().sum(0)
        res.append(correct_k.mul_(100.0 / batch_size))
    return res


class AverageMeter(object):
    """Computes and stores the average and current value"""

    def __init__(self):
        self.reset()

    def reset(self):
        self.val = 0
        self.avg = 0
        self.sum = 0
        self.count = 0

    def update(self, val, n=1):
        self.val = val
        self.sum += val * n
        self.count += n
        self.avg = self.sum / self.count


def result_plot(history):
    acc = history['train_acc_arr']
    val_acc = history['val_acc_arr']
    loss = history['train_loss_arr']
    val_loss = history['val_loss_arr']

    plt.clf()
    plt.figure(figsize=(15, 5))

    epochs = range(1, len(acc) + 1)

    plt.subplot(1, 2, 1)
    plt.plot(epochs, acc, 'bo', label='Training acc')
    plt.plot(epochs, val_acc, 'b', label='Validation acc')
    plt.title('Training and validation accuracy')
    plt.legend()

    plt.subplot(1, 2, 2)
    plt.plot(epochs, loss, 'bo', label='Training loss')
    plt.plot(epochs, val_loss, 'b', label='Validation loss')
    plt.title('Training and validation loss')
    plt.legend()

    plt.show()


"""Train Setting"""
def load_pretrained_resnet(class_num):
    resnet50 = models.resnet50(weights=ResNet50_Weights.IMAGENET1K_V2)  # 혹은 models.resnet50(pretrained=True)
    # change classifier
    resnet50.fc = nn.Linear(in_features=2048, out_features=class_num, bias=True)
    # freeze classifier
    for name, p in resnet50.named_parameters():
        if 'fc' in name:
            p.requires_grad = True
        else:
            p.requires_grad = False
    return resnet50


def check_params_to_update(model):
    params_to_update = []
    for name, param in model.named_parameters():
        if param.requires_grad == True:
            params_to_update.append(param)
            print("\t", name)
    return params_to_update


def train_model(model, train_loader, val_loader, criterion, optimizer, device, num_epochs=2):
    print("Start Training")
    history = {
        'train_loss_arr' : [],
        'train_acc_arr' : [],
        'val_loss_arr' : [],
        'val_acc_arr' : [],
    }

    for epoch in range(num_epochs):
        print(f"=====================================")
        print(f"Epoch: {epoch + 1}/{num_epochs} ")

        # Training phase
        model.train()
        train_losses = AverageMeter()
        train_top1 = AverageMeter()

        for i, (data, target) in enumerate(train_loader):
            data, target = data.to(device), target.to(device)
            optimizer.zero_grad()
            output = model(data)
            loss = criterion(output, target)
            loss.backward()
            optimizer.step()

            prec1 = accuracy(output.data, target)[0]

            train_losses.update(loss.item(), data.size(0))
            train_top1.update(prec1.item(), data.size(0))

            # 매 batch 마다 결과 출력
            print(f'Train Batch: [{i}/{len(train_loader)}]\t'
                  f'Loss {train_losses.val:.4f} ({train_losses.avg:.4f})')

        history['train_loss_arr'].append(train_losses.avg)
        history['train_acc_arr'].append(train_top1.avg)

        print(f"Train result: Loss: {train_losses.avg}, Acc: {train_top1.avg}\n")

        # Validation phase
        model.eval()
        val_losses = AverageMeter()
        val_top1 = AverageMeter()

        with torch.no_grad():
            for i, (data, target) in enumerate(val_loader):
                data, target = data.to(device), target.to(device)
                output = model(data)
                loss = criterion(output, target)

                prec1 = accuracy(output.data, target)[0]

                val_losses.update(loss.item(), data.size(0))
                val_top1.update(prec1.item(), data.size(0))

                # 매 batch 마다 결과 출력
                print(f'Val Batch: [{i}/{len(val_loader)}]\t'
                      f'Loss {val_losses.val:.4f} ({val_losses.avg:.4f})\t'
                      f'Prec@1 {val_top1.val:.3f} ({val_top1.avg:.3f})')

            history['val_loss_arr'].append(val_losses.avg)
            history['val_acc_arr'].append(val_top1.avg)

            print(f"Validation result: Loss: {val_losses.avg}, Acc: {val_top1.avg}\n")

        print(f"=====================================")

    print('Finished Training')
    return model, history


def evaluate_model(model, test_loader, criterion, device):
    print(f"=====================================")
    model.eval()
    test_losses = AverageMeter()
    test_accuracy = AverageMeter()

    with torch.no_grad():
        for data, target in test_loader:
            data, target = data.to(device), target.to(device)
            output = model(data)
            loss = criterion(output, target)
            prec1 = accuracy(output, target)[0]

            test_losses.update(loss.item(), data.size(0))
            test_accuracy.update(prec1.item(), data.size(0))

    print(f"Test Result - Loss: {test_losses.avg:.4f}, Accuracy: {test_accuracy.avg:.2f}%")
    print(f"=====================================")

