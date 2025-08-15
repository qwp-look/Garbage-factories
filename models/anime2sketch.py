import torch
import cv2
import numpy as np
from models.base_model import BaseAIModel
from torchvision import transforms
from PIL import Image

class Anime2SketchModel(BaseAIModel):
    def __init__(self):
        """加载Anime2Sketch预训练模型（基于PyTorch）"""
        super().__init__()
        self.device = "cuda" if torch.cuda.is_available() else "cpu"
        print(f"使用设备：{self.device}（GPU加速需安装CUDA）")
        
        # 加载模型（从Hugging Face自动下载，或本地加载）
        self.model = torch.hub.load(
            "bryandlee/anime2sketch:main",
            "anime2sketch",
            pretrained=True
        ).to(self.device).eval()
        
        # 图像预处理（模型要求）
        self.transform = transforms.Compose([
            transforms.Resize((512, 512)),  # 模型默认输入尺寸
            transforms.ToTensor(),
            transforms.Normalize([0.5, 0.5, 0.5], [0.5, 0.5, 0.5])
        ])

    def process_frame(self, img_array):
        """
        处理单帧：BGR→RGB→Sketch→BGR
        :param img_array: 输入图像（BGR, numpy.ndarray）
        :return: 素描风格图像（BGR, numpy.ndarray）
        """
        # 1. 格式转换：BGR（OpenCV）→ RGB（PIL）
        img_rgb = cv2.cvtColor(img_array, cv2.COLOR_BGR2RGB)
        img_pil = Image.fromarray(img_rgb)
        
        # 2. 预处理
        img_tensor = self.transform(img_pil).unsqueeze(0).to(self.device)
        
        # 3. 模型推理（关闭梯度计算，提升速度）
        with torch.no_grad():
            output_tensor = self.model(img_tensor)
        
        # 4. 结果后处理：张量→PIL→numpy（BGR）
        output_tensor = output_tensor.squeeze(0).cpu()
        output_pil = transforms.ToPILImage()((output_tensor + 1) / 2)  # 反归一化
        output_rgb = np.array(output_pil)
        output_bgr = cv2.cvtColor(output_rgb, cv2.COLOR_RGB2BGR)
        
        # 5. 调整尺寸为原始输入尺寸
        output_bgr = cv2.resize(output_bgr, (img_array.shape[1], img_array.shape[0]))
        
        return output_bgr