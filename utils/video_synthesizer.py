import os
import subprocess

class VideoSynthesizer:
    def __init__(self, processed_dir, output_video, fps=30):
        """
        ��ʼ����Ƶ�ϳ���������FFmpeg��Ч�ʸ��ߣ�
        :param processed_dir: �����ͼƬĿ¼
        :param output_video: �����Ƶ·��
        :param fps: �����Ƶ֡��
        """
        self.processed_dir = processed_dir
        self.output_video = output_video
        self.fps = fps
        # ���ͼƬ��ʽ��Ĭ����Ŀ¼�е�һ��ͼƬ�ĸ�ʽ��
        self._check_img_format()

    def _check_img_format(self):
        """��鴦���ͼƬ�ĸ�ʽ��ȷ��ͳһ��"""
        img_files = [f for f in os.listdir(self.processed_dir) if f.endswith((".jpg", ".png"))]
        if not img_files:
            raise FileNotFoundError(f"�����Ŀ¼����ͼƬ��{self.processed_dir}")
        self.img_ext = img_files[0].split(".")[-1]  # ��ȡͼƬ��׺��jpg/png��

    def synthesize(self):
        """��FFmpeg�ϳ���Ƶ������OpenCV�������⣩"""
        # FFmpeg�����ͼƬ���кϳ�MP4��H.264���룬�����Ժã�
        ffmpeg_cmd = [
            "ffmpeg",
            "-y",  # ���������ļ�
            "-r", str(self.fps),  # ����֡�ʣ�ͼƬ���е�֡�ʣ�
            "-i", os.path.join(self.processed_dir, "%05d.%s") % self.img_ext,  # ͼƬ·��ģ�壨00001.jpg��
            "-c:v", "libx264",  # ��Ƶ������
            "-crf", "23",  # ����ϵ����0-51��ԽС����Խ�ã�
            "-pix_fmt", "yuv420p",  # ���ظ�ʽ�����ݴ������������
            self.output_video
        ]
        # ִ��FFmpeg����
        result = subprocess.run(ffmpeg_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        if result.returncode != 0:
            raise RuntimeError(f"FFmpeg�ϳ�ʧ�ܣ�{result.stderr}")