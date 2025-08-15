from abc import ABC, abstractmethod

class BaseAIModel(ABC):
    """AIģ�ͻ��࣬����ģ����̳в�ʵ��process_frame����"""
    @abstractmethod
    def process_frame(self, img_array):
        """
        ����֡ͼ������/�����Ϊnumpy���飬BGR��ʽ��
        :param img_array: ����ͼ��numpy.ndarray, shape=(H,W,3), BGR��
        :return: �����ͼ��numpy.ndarray, shape=(H,W,3), BGR��
        """
        pass

    def process_and_save(self, img_path, save_path):
        """
        ��ȡͼƬ����������棨��װͨ�����̣�
        :param img_path: ����ͼƬ·��
        :param save_path: ���ͼƬ����·��
        """
        import cv2
        # ��ȡͼƬ��OpenCVĬ��BGR��ʽ��
        img = cv2.imread(img_path)
        if img is None:
            raise ValueError(f"�޷���ȡͼƬ��{img_path}")
        # ����ͼƬ
        processed_img = self.process_frame(img)
        # ����ͼƬ
        cv2.imwrite(save_path, processed_img)