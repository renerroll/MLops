import torch
from torchvision import models

def main():
    model = models.mobilenet_v2(pretrained=True)
    model.eval()
    example = torch.randn(1, 3, 224, 224)
    traced = torch.jit.trace(model, example)
    traced.save('model.pt')
    print('Saved model.pt')

if __name__ == '__main__':
    main()
