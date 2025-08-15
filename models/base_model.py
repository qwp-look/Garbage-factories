from abc import ABC, abstractmethod

class BaseAIModel(ABC):
    """AI模型基类，所有模型需继承并实现process_frame方法"""
    @abstractmethod
    def process_frame(self, img_array):
        """
        处理单帧图像（输入/输出均为numpy数组，BGR格式）
        :param img_array: 输入图像（numpy.ndarray, shape=(H,W,3), BGR）
        :return: 处理后图像（numpy.ndarray, shape=(H,W,3), BGR）
        """
        pass

    def process_and_save(self, img_path, save_path):
        """
        读取图片→处理→保存（封装通用流程）
        :param img_path: 输入图片路径
        :param save_path: 输出图片保存路径
        """
        import cv2
        # 读取图片（OpenCV默认BGR格式）
        img = cv2.imread(img_path)
        if img is None:
            raise ValueError(f"无法读取图片：{img_path}")
        # 处理图片
        processed_img = self.process_frame(img)
        # 保存图片
        cv2.imwrite(save_path, processed_img)