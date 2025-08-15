import os
import subprocess

class VideoSynthesizer:
    def __init__(self, processed_dir, output_video, fps=30):
        """
        初始化视频合成器（基于FFmpeg，效率更高）
        :param processed_dir: 处理后图片目录
        :param output_video: 输出视频路径
        :param fps: 输出视频帧率
        """
        self.processed_dir = processed_dir
        self.output_video = output_video
        self.fps = fps
        # 检查图片格式（默认用目录中第一个图片的格式）
        self._check_img_format()

    def _check_img_format(self):
        """检查处理后图片的格式（确保统一）"""
        img_files = [f for f in os.listdir(self.processed_dir) if f.endswith((".jpg", ".png"))]
        if not img_files:
            raise FileNotFoundError(f"处理后目录中无图片：{self.processed_dir}")
        self.img_ext = img_files[0].split(".")[-1]  # 获取图片后缀（jpg/png）

    def synthesize(self):
        """用FFmpeg合成视频（避免OpenCV编码问题）"""
        # FFmpeg命令：将图片序列合成MP4（H.264编码，兼容性好）
        ffmpeg_cmd = [
            "ffmpeg",
            "-y",  # 覆盖现有文件
            "-r", str(self.fps),  # 输入帧率（图片序列的帧率）
            "-i", os.path.join(self.processed_dir, "%05d.%s") % self.img_ext,  # 图片路径模板（00001.jpg）
            "-c:v", "libx264",  # 视频编码器
            "-crf", "23",  # 质量系数（0-51，越小质量越好）
            "-pix_fmt", "yuv420p",  # 像素格式（兼容大多数播放器）
            self.output_video
        ]
        # 执行FFmpeg命令
        result = subprocess.run(ffmpeg_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        if result.returncode != 0:
            raise RuntimeError(f"FFmpeg合成失败：{result.stderr}")