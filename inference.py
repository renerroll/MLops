import sys
from PIL import Image
import torch
import torchvision.transforms as T

LABELS = None

def load_labels():
    # Minimal fallback labels (Imagenet idx->name mapping would be better)
    return [str(i) for i in range(1000)]

def preprocess(img_path):
    img = Image.open(img_path).convert('RGB')
    transforms = T.Compose([
        T.Resize(256),
        T.CenterCrop(224),
        T.ToTensor(),
        T.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
    ])
    return transforms(img).unsqueeze(0)

def predict(model_path, image_path):
    global LABELS
    if LABELS is None:
        LABELS = load_labels()
    model = torch.jit.load(model_path)
    model.eval()
    x = preprocess(image_path)
    with torch.no_grad():
        out = model(x)
    probs = torch.nn.functional.softmax(out[0], dim=0)
    topk = torch.topk(probs, k=3)
    for i, p in zip(topk.indices.tolist(), topk.values.tolist()):
        print(f"{LABELS[i]} — {p*100:.2f}%")

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print('Usage: python inference.py <image_path> [model_path]')
        sys.exit(1)
    img = sys.argv[1]
    model = sys.argv[2] if len(sys.argv) > 2 else 'model.pt'
    predict(model, img)
