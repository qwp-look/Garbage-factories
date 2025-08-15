import cv2
import os
from tqdm import tqdm

class FrameExtractor:
    def __init__(self, video_path, frame_dir):
        """
        初始化拆帧器
        :param video_path: 原始视频路径
        :param frame_dir: 帧保存目录
        """
        self.video_path = video_path
        self.frame_dir = frame_dir
        self.cap = cv2.VideoCapture(video_path)
        if not self.cap.isOpened():
            raise ValueError(f"无法打开视频文件：{video_path}")
        self.frame_count = int(self.cap.get(cv2.CAP_PROP_FRAME_COUNT))  # 总帧数

    def extract_frames(self, img_format="jpg", img_quality=95):
        """
        提取视频帧并保存为图片
        :param img_format: 图片格式（jpg/png）
        :param img_quality: JPG质量（0-100）
        """
        for frame_idx in tqdm(range(self.frame_count), desc="拆帧进度"):
            ret, frame = self.cap.read()
            if not ret:
                break  # 读取失败则退出
            # 帧命名：00001.jpg、00002.jpg（确保顺序）
            img_name = f"{frame_idx + 1:05d}.{img_format}"
            img_path = os.path.join(self.frame_dir, img_name)
            # 保存图片
            if img_format.lower() == "jpg":
                cv2.imwrite(img_path, frame, [int(cv2.IMWRITE_JPEG_QUALITY), img_quality])
            else:
                cv2.imwrite(img_path, frame)
        self.cap.release()  # 释放资源