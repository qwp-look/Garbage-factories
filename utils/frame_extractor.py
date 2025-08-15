import cv2
import os
from tqdm import tqdm

class FrameExtractor:
    def __init__(self, video_path, frame_dir):
        """
        ��ʼ����֡��
        :param video_path: ԭʼ��Ƶ·��
        :param frame_dir: ֡����Ŀ¼
        """
        self.video_path = video_path
        self.frame_dir = frame_dir
        self.cap = cv2.VideoCapture(video_path)
        if not self.cap.isOpened():
            raise ValueError(f"�޷�����Ƶ�ļ���{video_path}")
        self.frame_count = int(self.cap.get(cv2.CAP_PROP_FRAME_COUNT))  # ��֡��

    def extract_frames(self, img_format="jpg", img_quality=95):
        """
        ��ȡ��Ƶ֡������ΪͼƬ
        :param img_format: ͼƬ��ʽ��jpg/png��
        :param img_quality: JPG������0-100��
        """
        for frame_idx in tqdm(range(self.frame_count), desc="��֡����"):
            ret, frame = self.cap.read()
            if not ret:
                break  # ��ȡʧ�����˳�
            # ֡������00001.jpg��00002.jpg��ȷ��˳��
            img_name = f"{frame_idx + 1:05d}.{img_format}"
            img_path = os.path.join(self.frame_dir, img_name)
            # ����ͼƬ
            if img_format.lower() == "jpg":
                cv2.imwrite(img_path, frame, [int(cv2.IMWRITE_JPEG_QUALITY), img_quality])
            else:
                cv2.imwrite(img_path, frame)
        self.cap.release()  # �ͷ���Դ