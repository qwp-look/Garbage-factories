# Garbage Factories

> **垃圾工厂：** 使用 AI 对原视频进行二次创作，将输入视频转为图片，生成新图片后再合成新视频。

## 📖 项目简介

本项目旨在演示如何利用开源工具与 AI 模型对视频进行二创（二次创作），包括：

1. **视频拆帧**：将原视频拆分为连续的图片序列。
2. **AI 处理**：使用 AI 模型（如 Stable Diffusion、Anime2Sketch、ComfyUI 等）对拆分的图片进行风格化或重绘。
3. **视频合成**：将处理后的一系列新图片重新合成为视频，得到最终二创效果。

> **注意：** 本人水平有限，欢迎指正与贡献。

## 🚀 功能特性

* **支持多种 AI 模型**：可选用 Frame-Extractor、Anime2Sketch 等项目模型。
* **自动化流程**：一键拆帧、AI 渲染、合成视频。
* **可定制化**：可根据需求更换或调整模型与参数。

## 📦 环境依赖

* **操作系统**：Windows 10/11（推荐）
* **Git**（用于克隆仓库）
* **Python 3.10**
* **FFmpeg**

## 🔧 安装与配置

1. 安装 [Git](https://git-scm.com/book/zh/v2/起步-安装-Git)，并将其添加至环境变量。
2. 安装 [Python 3.10](https://www.python.org/downloads/release/python-3100/)，并将其添加至环境变量。
3. 安装 [FFmpeg](https://ffmpeg.org/download.html)，并添加至环境变量。
4. 克隆仓库：

   ```bash
   git clone https://github.com/qwp-look/Garbage-factories.git
   cd Garbage-factories
   ```
5. 安装 Python 依赖：

   ```bash
   setup.cmd
   ```

## 🎬 使用方法

1. **检查环境**：

   ```bash
   check.bat
   ```
2. **流程控制**（可选）：

   ```bash
   control.bat
   ```
3. **启动项目**：

   ```bash
   start.bat
   ```

处理完成后，结果视频文件将保存在 `output/` 目录下。

## 📂 文件结构

```
├── control.bat    # 流程控制脚本
├── check.bat      # 环境检测脚本
├── setup.cmd      # 安装依赖脚本
├── start.bat      # 启动处理脚本
├── requirement.txt# Python 依赖清单
├── input/         # 原始视频及资源目录
├── output/        # 生成的视频及图片
└── models/        # 存放 AI 模型文件
```

## 🤝 致谢 & 参考项目

* [OldDriver258/frame\_extractor](https://github.com/OldDriver258/frame_extractor)
* [comfyanonymous/ComfyUI](https://github.com/comfyanonymous/ComfyUI)
* [Mukosame/Anime2Sketch](https://github.com/Mukosame/Anime2Sketch)
* [FFmpeg](https://github.com/FFmpeg/FFmpeg)
* [CompVis/stable-diffusion](https://github.com/CompVis/stable-diffusion)

模型文件来源：

* [stabilityai/stable-diffusion-3.5-large (Hugging Face)](https://huggingface.co/stabilityai/stable-diffusion-3.5-large)
* Google Drive 资源链接

## 📄 许可协议

本项目采用 MIT 许可，详情请参阅 [LICENSE](LICENSE)。

---

*作者：qwp-look* & 20V14A
