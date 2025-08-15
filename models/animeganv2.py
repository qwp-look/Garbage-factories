import torch
import cv2
import numpy as np
from models.base_model import BaseAIModel
from torchvision import transforms
from PIL import Image

class AnimeGANv2Model(BaseAIModel):
    def __init__(self, style="paprika"):
        """
        ����AnimeGANv2Ԥѵ��ģ��
        :param style: ���paprika/face1/face2��faceϵ���ʺ�����
        """
        super().__init__()
        self.device = "cuda" if torch.cuda.is_available() else "cpu"
        self.style = style
        print(f"ʹ���豸��{self.device}�����{style}")
        
        # ����ģ�ͣ�PyTorch Hub��
        self.model = torch.hub.load(
            "bryandlee/animegan2-pytorch:main",
            "generator",
            pretrained=True,
            device=self.device,
            progress=False
        ).eval()
        
        # ���ط��ת������ƥ��ָ�����
        self.style_transform = torch.hub.load(
            "bryandlee/animegan2-pytorch:main",
            "style_transform",
            style=self.style,
            device=self.device
        )
        
        # ͼ��Ԥ����
        self.transform = transforms.Compose([
            transforms.Resize((512, 512)),
            transforms.ToTensor(),
            transforms.Normalize([0.5, 0.5, 0.5], [0.5, 0.5, 0.5])
        ])

    def process_frame(self, img_array):
        """
        ����֡��BGR��RGB��Anime��BGR
        :param img_array: ����ͼ��BGR, numpy.ndarray��
        :return: �������ͼ��BGR, numpy.ndarray��
        """
        # 1. ��ʽת����BGR��RGB��PIL
        img_rgb = cv2.cvtColor(img_array, cv2.COLOR_BGR2RGB)
        img_pil = Image.fromarray(img_rgb).convert("RGB")
        
        # 2. Ԥ����
        img_tensor = self.transform(img_pil).unsqueeze(0).to(self.device)
        img_tensor = self.style_transform(img_tensor)  # Ӧ�÷��
        
        # 3. ģ������
        with torch.no_grad():
            output_tensor = self.model(img_tensor)
        
        # 4. ����������numpy��BGR��
        output_tensor = output_tensor.squeeze(0).cpu()
        output_rgb = (output_tensor + 1) / 2  # ����һ��
        output_rgb = output_rgb.permute(1, 2, 0).numpy() * 255  # ά��ת����C,H,W��H,W,C
        output_rgb = output_rgb.astype(np.uint8)
        output_bgr = cv2.cvtColor(output_rgb, cv2.COLOR_RGB2BGR)
        
        # 5. �����ߴ�Ϊԭʼ����ߴ�
        output_bgr = cv2.resize(output_bgr, (img_array.shape[1], img_array.shape[0]))
        
        return output_bgr