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
        初始化Stable Diffusion 3.5 Large模型
        :param prompts: 提示词配置字典
        :param style: 选择的风格（对应prompts.json中的键）
        :param strength: 控制AI生成的强度（0-1，值越高创意性越强）
        """
        super().__init__()
        self.device = "cuda" if torch.cuda.is_available() else "cpu"
        self.strength = strength
        
        # 检查风格是否存在
        if style not in prompts:
            raise ValueError(f"风格 {style} 不存在，请检查prompts.json")
        
        # 获取提示词
        self.prompt = prompts[style]["positive_prompt"]
        self.style_name = style
        print(f"使用Stable Diffusion 3.5，风格：{style}，设备：{self.device}")
        print(f"提示词：{self.prompt}")
        
        # 加载模型
        self.pipeline = StableDiffusion3Pipeline.from_pretrained(
            "stabilityai/stable-diffusion-3.5-large",
            torch_dtype=torch.float16 if self.device == "cuda" else torch.float32,
            variant="fp16" if self.device == "cuda" else None
        ).to(self.device)
        
        # 优化设置（如果是GPU）
        if self.device == "cuda":
            self.pipeline.enable_model_cpu_offload()  # 节省显存
            self.pipeline.enable_xformers_memory_efficient_attention()
        
        # 图像预处理
        self.transform = transforms.Compose([
            transforms.Resize((1024, 1024)),
            transforms.ToTensor(),
            transforms.Normalize([0.5, 0.5, 0.5], [0.5, 0.5, 0.5])
        ])
        
        self.post_transform = transforms.Compose([
            transforms.Normalize([-1.0, -1.0, -1.0], [2.0, 2.0, 2.0]),  # 反归一化
        ])

    def process_frame(self, img_array):
        """
        处理单帧图像，应用Stable Diffusion 3.5风格转换
        :param img_array: 输入图像（BGR, numpy.ndarray）
        :return: 处理后图像（BGR, numpy.ndarray）
        """
        # 1. 转换为RGB并调整大小
        original_size = (img_array.shape[1], img_array.shape[0])  # (width, height)
        img_rgb = cv2.cvtColor(img_array, cv2.COLOR_BGR2RGB)
        img_pil = Image.fromarray(img_rgb).convert("RGB")
        
        # 2. 生成图像
        with torch.no_grad():
            result = self.pipeline(
                prompt=self.prompt,
                image=img_pil,
                strength=self.strength,
                guidance_scale=7.5,
                num_inference_steps=30,
                output_type="pil"
            ).images[0]
        
        # 3. 转换回BGR格式并调整为原始尺寸
        result_rgb = np.array(result)
        result_bgr = cv2.cvtColor(result_rgb, cv2.COLOR_RGB2BGR)
        result_bgr = cv2.resize(result_bgr, original_size)
        
        return result_bgr