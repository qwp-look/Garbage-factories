import torch
import cv2
import numpy as np
from models.base_model import BaseAIModel
from diffusers import StableDiffusion3Pipeline
from PIL import Image
import torchvision.transforms as transforms

class StableDiffusion35Model(BaseAIModel):
    def __init__(self, prompts, style="anime_style", strength=0.75):
        """
        ��ʼ��Stable Diffusion 3.5 Largeģ��
        :param prompts: ��ʾ�������ֵ�
        :param style: ѡ��ķ�񣨶�Ӧprompts.json�еļ���
        :param strength: ����AI���ɵ�ǿ�ȣ�0-1��ֵԽ�ߴ�����Խǿ��
        """
        super().__init__()
        self.device = "cuda" if torch.cuda.is_available() else "cpu"
        self.strength = strength
        
        # ������Ƿ����
        if style not in prompts:
            raise ValueError(f"��� {style} �����ڣ�����prompts.json")
        
        # ��ȡ��ʾ��
        self.prompt = prompts[style]["positive_prompt"]
        self.style_name = style
        print(f"ʹ��Stable Diffusion 3.5�����{style}���豸��{self.device}")
        print(f"��ʾ�ʣ�{self.prompt}")
        
        # ����ģ��
        self.pipeline = StableDiffusion3Pipeline.from_pretrained(
            "stabilityai/stable-diffusion-3.5-large",
            torch_dtype=torch.float16 if self.device == "cuda" else torch.float32,
            variant="fp16" if self.device == "cuda" else None
        ).to(self.device)
        
        # �Ż����ã������GPU��
        if self.device == "cuda":
            self.pipeline.enable_model_cpu_offload()  # ��ʡ�Դ�
            self.pipeline.enable_xformers_memory_efficient_attention()
        
        # ͼ��Ԥ����
        self.transform = transforms.Compose([
            transforms.Resize((1024, 1024)),
            transforms.ToTensor(),
            transforms.Normalize([0.5, 0.5, 0.5], [0.5, 0.5, 0.5])
        ])
        
        self.post_transform = transforms.Compose([
            transforms.Normalize([-1.0, -1.0, -1.0], [2.0, 2.0, 2.0]),  # ����һ��
        ])

    def process_frame(self, img_array):
        """
        ����֡ͼ��Ӧ��Stable Diffusion 3.5���ת��
        :param img_array: ����ͼ��BGR, numpy.ndarray��
        :return: �����ͼ��BGR, numpy.ndarray��
        """
        # 1. ת��ΪRGB��������С
        original_size = (img_array.shape[1], img_array.shape[0])  # (width, height)
        img_rgb = cv2.cvtColor(img_array, cv2.COLOR_BGR2RGB)
        img_pil = Image.fromarray(img_rgb).convert("RGB")
        
        # 2. ����ͼ��
        with torch.no_grad():
            result = self.pipeline(
                prompt=self.prompt,
                image=img_pil,
                strength=self.strength,
                guidance_scale=7.5,
                num_inference_steps=30,
                output_type="pil"
            ).images[0]
        
        # 3. ת����BGR��ʽ������Ϊԭʼ�ߴ�
        result_rgb = np.array(result)
        result_bgr = cv2.cvtColor(result_rgb, cv2.COLOR_RGB2BGR)
        result_bgr = cv2.resize(result_bgr, original_size)
        
        return result_bgr