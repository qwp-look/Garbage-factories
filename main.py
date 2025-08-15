import argparse
import os
import json
from utils.frame_extractor import FrameExtractor
from utils.video_synthesizer import VideoSynthesizer
from models.anime2sketch import Anime2SketchModel
from models.animeganv2 import AnimeGANv2Model
from models.stable_diffusion_3_5 import StableDiffusion35Model
from tqdm import tqdm

def parse_args():
    """���������в���"""
    parser = argparse.ArgumentParser(description="Garbage Factories: AI ��Ƶ���δ���")
    parser.add_argument("--action", required=True, choices=["extract", "ai_process", "synthesize", "full"],
                        help="�������ͣ�extract����֡����ai_process��AI������synthesize���ϳ���Ƶ����full���������̣�")
    parser.add_argument("--input_video", default="input/input.mp4", help="ԭʼ��Ƶ·������ extract/full ���ã�")
    parser.add_argument("--frame_dir", default="output/frames", help="��֡��ͼƬ����Ŀ¼���� extract/full ���ã�")
    parser.add_argument("--processed_dir", default="output/processed", help="AI�����ͼƬ����Ŀ¼���� ai_process/full ���ã�")
    parser.add_argument("--output_video", default="output/final.mp4", help="�ϳɺ���Ƶ·������ synthesize/full ���ã�")
    parser.add_argument("--model", default="anime2sketch", choices=["anime2sketch", "animeganv2", "stable_diffusion_3.5"], help="AIģ�����ͣ��� ai_process/full ���ã�")
    parser.add_argument("--style", default="default", help="ģ�ͷ�񣨲���ģ��֧�֣�")
    parser.add_argument("--fps", type=int, default=30, help="�����Ƶ֡�ʣ��� synthesize/full ���ã�")
    return parser.parse_args()

def init_dirs(dirs):
    """��ʼ���ļ��У��������򴴽���"""
    for dir_path in dirs:
        if not os.path.exists(dir_path):
            os.makedirs(dir_path)
            print(f"�����ļ��У�{dir_path}")

def load_ai_model(model_type, style="default"):
    """����ָ����AIģ��"""
    print(f"���� {model_type} ģ��...")
    if model_type == "anime2sketch":
        return Anime2SketchModel()
    elif model_type == "animeganv2":
        return AnimeGANv2Model(style=style if style != "default" else "paprika")
    elif model_type == "stable_diffusion_3.5":
        # ������ʾ������
        prompts = load_prompts()
        return StableDiffusion35Model(prompts=prompts, style=style if style != "default" else "anime_style")
    else:
        raise ValueError(f"��֧�ֵ�ģ�����ͣ�{model_type}")

def load_prompts():
    """������ʾ�������ļ�"""
    prompts_path = os.path.join("config", "prompts.json")
    if not os.path.exists(prompts_path):
        raise FileNotFoundError(f"��ʾ�������ļ������ڣ�{prompts_path}")
    
    with open(prompts_path, 'r', encoding='utf-8') as f:
        return json.load(f)

def main():
    args = parse_args()
    
    # 1. ����֡
    if args.action == "extract":
        init_dirs([args.frame_dir])
        extractor = FrameExtractor(args.input_video, args.frame_dir)
        extractor.extract_frames()
        print(f"��֡��ɣ�����ȡ {extractor.frame_count} ֡�������� {args.frame_dir}")
    
    # 2. ��AI����
    elif args.action == "ai_process":
        if not os.path.exists(args.frame_dir):
            raise FileNotFoundError(f"��֡Ŀ¼�����ڣ�{args.frame_dir}")
        init_dirs([args.processed_dir])
        model = load_ai_model(args.model, args.style)
        
        # ��������ͼƬ������
        frame_files = [f for f in os.listdir(args.frame_dir) if f.endswith((".jpg", ".png"))]
        frame_files.sort()  # ȷ����֡˳����
        for img_name in tqdm(frame_files, desc="AI�������"):
            img_path = os.path.join(args.frame_dir, img_name)
            save_path = os.path.join(args.processed_dir, img_name)
            model.process_and_save(img_path, save_path)
        print(f"AI������ɣ������� {len(frame_files)} ֡�������� {args.processed_dir}")
    
    # 3. ���ϳ���Ƶ
    elif args.action == "synthesize":
        if not os.path.exists(args.processed_dir):
            raise FileNotFoundError(f"�����ͼƬĿ¼�����ڣ�{args.processed_dir}")
        init_dirs([os.path.dirname(args.output_video)])
        synthesizer = VideoSynthesizer(args.processed_dir, args.output_video, args.fps)
        synthesizer.synthesize()
        print(f"��Ƶ�ϳ���ɣ������� {args.output_video}")
    
    # 4. �������̣���֡��AI���ϳɣ�
    elif args.action == "full":
        init_dirs([args.frame_dir, args.processed_dir, os.path.dirname(args.output_video)])
        print("=== ����1����֡ ===")
        extractor = FrameExtractor(args.input_video, args.frame_dir)
        extractor.extract_frames()
        print(f"��֡��ɣ�{extractor.frame_count} ֡")
        
        print("\n=== ����2��AI���� ===")
        model = load_ai_model(args.model, args.style)
        frame_files = [f for f in os.listdir(args.frame_dir) if f.endswith((".jpg", ".png"))]
        frame_files.sort()
        for img_name in tqdm(frame_files, desc="AI�������"):
            img_path = os.path.join(args.frame_dir, img_name)
            save_path = os.path.join(args.processed_dir, img_name)
            model.process_and_save(img_path, save_path)
        print(f"AI������ɣ�{len(frame_files)} ֡")
        
        print("\n=== ����3���ϳ���Ƶ ===")
        synthesizer = VideoSynthesizer(args.processed_dir, args.output_video, args.fps)
        synthesizer.synthesize()
        print(f"����������ɣ�������Ƶ��{args.output_video}")

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"�������{str(e)}")
        input("��������˳�...")