import torch
import cv2
import numpy as np
from models.base_model import BaseAIModel
from torchvision import transforms
from PIL import Image

class Anime2SketchModel(BaseAIModel):
    def __init__(self):
        """����Anime2SketchԤѵ��ģ�ͣ�����PyTorch��"""
        super().__init__()
        self.device = "cuda" if torch.cuda.is_available() else "cpu"
        print(f"ʹ���豸��{self.device}��GPU�����谲װCUDA��")
        
        # ����ģ�ͣ���Hugging Face�Զ����أ��򱾵ؼ��أ�
        self.model = torch.hub.load(
            "bryandlee/anime2sketch:main",
            "anime2sketch",
            pretrained=True
        ).to(self.device).eval()
        
        # ͼ��Ԥ����ģ��Ҫ��
        self.transform = transforms.Compose([
            transforms.Resize((512, 512)),  # ģ��Ĭ������ߴ�
            transforms.ToTensor(),
            transforms.Normalize([0.5, 0.5, 0.5], [0.5, 0.5, 0.5])
        ])

    def process_frame(self, img_array):
        """
        ����֡��BGR��RGB��Sketch��BGR
        :param img_array: ����ͼ��BGR, numpy.ndarray��
        :return: ������ͼ��BGR, numpy.ndarray��
        """
        # 1. ��ʽת����BGR��OpenCV���� RGB��PIL��
        img_rgb = cv2.cvtColor(img_array, cv2.COLOR_BGR2RGB)
        img_pil = Image.fromarray(img_rgb)
        
        # 2. Ԥ����
        img_tensor = self.transform(img_pil).unsqueeze(0).to(self.device)
        
        # 3. ģ�������ر��ݶȼ��㣬�����ٶȣ�
        with torch.no_grad():
            output_tensor = self.model(img_tensor)
        
        # 4. �������������PIL��numpy��BGR��
        output_tensor = output_tensor.squeeze(0).cpu()
        output_pil = transforms.ToPILImage()((output_tensor + 1) / 2)  # ����һ��
        output_rgb = np.array(output_pil)
        output_bgr = cv2.cvtColor(output_rgb, cv2.COLOR_RGB2BGR)
        
        # 5. �����ߴ�Ϊԭʼ����ߴ�
        output_bgr = cv2.resize(output_bgr, (img_array.shape[1], img_array.shape[0]))
        
        return output_bgr