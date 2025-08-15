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
    """解析命令行参数"""
    parser = argparse.ArgumentParser(description="Garbage Factories: AI 视频二次创作")
    parser.add_argument("--action", required=True, choices=["extract", "ai_process", "synthesize", "full"],
                        help="操作类型：extract（拆帧）、ai_process（AI处理）、synthesize（合成视频）、full（完整流程）")
    parser.add_argument("--input_video", default="input/input.mp4", help="原始视频路径（仅 extract/full 需用）")
    parser.add_argument("--frame_dir", default="output/frames", help="拆帧后图片保存目录（仅 extract/full 需用）")
    parser.add_argument("--processed_dir", default="output/processed", help="AI处理后图片保存目录（仅 ai_process/full 需用）")
    parser.add_argument("--output_video", default="output/final.mp4", help="合成后视频路径（仅 synthesize/full 需用）")
    parser.add_argument("--model", default="anime2sketch", choices=["anime2sketch", "animeganv2", "stable_diffusion_3.5"], help="AI模型类型（仅 ai_process/full 需用）")
    parser.add_argument("--style", default="default", help="模型风格（部分模型支持）")
    parser.add_argument("--fps", type=int, default=30, help="输出视频帧率（仅 synthesize/full 需用）")
    return parser.parse_args()

def init_dirs(dirs):
    """初始化文件夹（不存在则创建）"""
    for dir_path in dirs:
        if not os.path.exists(dir_path):
            os.makedirs(dir_path)
            print(f"创建文件夹：{dir_path}")

def load_ai_model(model_type, style="default"):
    """加载指定的AI模型"""
    print(f"加载 {model_type} 模型...")
    if model_type == "anime2sketch":
        return Anime2SketchModel()
    elif model_type == "animeganv2":
        return AnimeGANv2Model(style=style if style != "default" else "paprika")
    elif model_type == "stable_diffusion_3.5":
        # 加载提示词配置
        prompts = load_prompts()
        return StableDiffusion35Model(prompts=prompts, style=style if style != "default" else "anime_style")
    else:
        raise ValueError(f"不支持的模型类型：{model_type}")

def load_prompts():
    """加载提示词配置文件"""
    prompts_path = os.path.join("config", "prompts.json")
    if not os.path.exists(prompts_path):
        raise FileNotFoundError(f"提示词配置文件不存在：{prompts_path}")
    
    with open(prompts_path, 'r', encoding='utf-8') as f:
        return json.load(f)

def main():
    args = parse_args()
    
    # 1. 仅拆帧
    if args.action == "extract":
        init_dirs([args.frame_dir])
        extractor = FrameExtractor(args.input_video, args.frame_dir)
        extractor.extract_frames()
        print(f"拆帧完成！共提取 {extractor.frame_count} 帧，保存至 {args.frame_dir}")
    
    # 2. 仅AI处理
    elif args.action == "ai_process":
        if not os.path.exists(args.frame_dir):
            raise FileNotFoundError(f"拆帧目录不存在：{args.frame_dir}")
        init_dirs([args.processed_dir])
        model = load_ai_model(args.model, args.style)
        
        # 遍历所有图片并处理
        frame_files = [f for f in os.listdir(args.frame_dir) if f.endswith((".jpg", ".png"))]
        frame_files.sort()  # 确保按帧顺序处理
        for img_name in tqdm(frame_files, desc="AI处理进度"):
            img_path = os.path.join(args.frame_dir, img_name)
            save_path = os.path.join(args.processed_dir, img_name)
            model.process_and_save(img_path, save_path)
        print(f"AI处理完成！共处理 {len(frame_files)} 帧，保存至 {args.processed_dir}")
    
    # 3. 仅合成视频
    elif args.action == "synthesize":
        if not os.path.exists(args.processed_dir):
            raise FileNotFoundError(f"处理后图片目录不存在：{args.processed_dir}")
        init_dirs([os.path.dirname(args.output_video)])
        synthesizer = VideoSynthesizer(args.processed_dir, args.output_video, args.fps)
        synthesizer.synthesize()
        print(f"视频合成完成！保存至 {args.output_video}")
    
    # 4. 完整流程（拆帧→AI→合成）
    elif args.action == "full":
        init_dirs([args.frame_dir, args.processed_dir, os.path.dirname(args.output_video)])
        print("=== 步骤1：拆帧 ===")
        extractor = FrameExtractor(args.input_video, args.frame_dir)
        extractor.extract_frames()
        print(f"拆帧完成：{extractor.frame_count} 帧")
        
        print("\n=== 步骤2：AI处理 ===")
        model = load_ai_model(args.model, args.style)
        frame_files = [f for f in os.listdir(args.frame_dir) if f.endswith((".jpg", ".png"))]
        frame_files.sort()
        for img_name in tqdm(frame_files, desc="AI处理进度"):
            img_path = os.path.join(args.frame_dir, img_name)
            save_path = os.path.join(args.processed_dir, img_name)
            model.process_and_save(img_path, save_path)
        print(f"AI处理完成：{len(frame_files)} 帧")
        
        print("\n=== 步骤3：合成视频 ===")
        synthesizer = VideoSynthesizer(args.processed_dir, args.output_video, args.fps)
        synthesizer.synthesize()
        print(f"完整流程完成！最终视频：{args.output_video}")

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"程序出错：{str(e)}")
        input("按任意键退出...")