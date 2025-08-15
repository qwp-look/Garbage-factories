import torch
import cv2
import numpy as np
from models.base_model import BaseAIModel
from torchvision import transforms
from PIL import Image

class AnimeGANv2Model(BaseAIModel):
    def __init__(self, style="paprika"):
        """
        加载AnimeGANv2预训练模型
        :param style: 风格（paprika/face1/face2，face系列适合人像）
        """
        super().__init__()
        self.device = "cuda" if torch.cuda.is_available() else "cpu"
        self.style = style
        print(f"使用设备：{self.device}，风格：{style}")
        
        # 加载模型（PyTorch Hub）
        self.model = torch.hub.load(
            "bryandlee/animegan2-pytorch:main",
            "generator",
            pretrained=True,
            device=self.device,
            progress=False
        ).eval()
        
        # 加载风格转换器（匹配指定风格）
        self.style_transform = torch.hub.load(
            "bryandlee/animegan2-pytorch:main",
            "style_transform",
            style=self.style,
            device=self.device
        )
        
        # 图像预处理
        self.transform = transforms.Compose([
            transforms.Resize((512, 512)),
            transforms.ToTensor(),
            transforms.Normalize([0.5, 0.5, 0.5], [0.5, 0.5, 0.5])
        ])

    def process_frame(self, img_array):
        """
        处理单帧：BGR→RGB→Anime→BGR
        :param img_array: 输入图像（BGR, numpy.ndarray）
        :return: 动漫风格图像（BGR, numpy.ndarray）
        """
        # 1. 格式转换：BGR→RGB→PIL
        img_rgb = cv2.cvtColor(img_array, cv2.COLOR_BGR2RGB)
        img_pil = Image.fromarray(img_rgb).convert("RGB")
        
        # 2. 预处理
        img_tensor = self.transform(img_pil).unsqueeze(0).to(self.device)
        img_tensor = self.style_transform(img_tensor)  # 应用风格
        
        # 3. 模型推理
        with torch.no_grad():
            output_tensor = self.model(img_tensor)
        
        # 4. 后处理：张量→numpy（BGR）
        output_tensor = output_tensor.squeeze(0).cpu()
        output_rgb = (output_tensor + 1) / 2  # 反归一化
        output_rgb = output_rgb.permute(1, 2, 0).numpy() * 255  # 维度转换：C,H,W→H,W,C
        output_rgb = output_rgb.astype(np.uint8)
        output_bgr = cv2.cvtColor(output_rgb, cv2.COLOR_RGB2BGR)
        
        # 5. 调整尺寸为原始输入尺寸
        output_bgr = cv2.resize(output_bgr, (img_array.shape[1], img_array.shape[0]))
        
        return output_bgr