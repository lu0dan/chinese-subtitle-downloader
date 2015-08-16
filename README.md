### Chinese Subtitle Downloader
by luodan@gmail.com

A Chinese subtitle downloader for video files written in linux shell scripts.
Since it's for Chinese only, the readme file is written in Chinese below.

### 中文字幕下载脚本

Chinese subtitle download 是一个简单, 轻量级的中文字幕下载具. 可以根据视频文件的文件名称搜索各大字幕网站, 
并根据搜索结果排序并下载字幕. 因为使用shell脚本编写, 所以不需要安装其它任何支持的软件, 只要是在linux系列系统, 
都可以正常运行(特别是NAS服务器).

主要功能有:

* 支持手动单个或多个文件或目录下载
* 支持集成到transmission-daemon, 当种子下载完成后自动下载字幕
* 可扩展的字幕站下载脚本的结构设计
* 搜索所有相关字幕, 并根据关键字智能评分, 排序.
* 可用于各种NAS服务器

### 使用方法

* 手动下载
  subtitle.sh [-r] [-v] [-o] [-l] [-f] video_file_or_directory [video_file_or_directory ...]

* 集成到transmission-daemon
  scripts/transmission/install.sh

### 参数解释

-r: 搜索子目录
-f: 强制处理所有视频文件.(缺省只处理没有字幕的视频文件, 忽略已有字幕的视频文件)
-v: 输出详细信息.(缺省只输出需要下载字幕的视频文件信息, 忽略目录扫描及已有字幕的视频文件信息)
-o: 输出信息到日志文件
-l: 仅仅列出需要下载字幕的视频文件. 当与 -f 同时使用时会列出所有视频文件.

### 版本历史

v0.9.1 2015.08.16
* 改进log记录方式

v0.9 2015.08.10
+ 初始版本

