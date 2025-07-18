# FLV2MP4 视频封装转换工具

## 项目简介

此脚本/批处理工具旨在帮助用户快速地将硬盘中存储的大量 FLV 封装视频 转换为现今更为主流且兼容性更佳的 MP4/MKV 封装 格式，从而省去手动逐个转换的繁琐操作。

## 为什么需要这个工具？

**Flash Video (FLV)** 曾是互联网流媒体传输的主流封装格式，以其较小的文件体积著称，并在 2008 年前后被 YouTube、NICONICO 动画、哔哩哔哩等众多平台广泛采用。

然而，**FLV 格式与 Adobe Flash 技术深度绑定**。随着移动互联网的兴起，Flash 因安全性漏洞、性能低下、耗电量大等问题逐渐被淘汰：

- Adobe 于 2011 年宣布停止移动平台 Flash 开发。
- 主流浏览器（如 Chrome 在 2015 年）开始限制 Flash 的自动运行。
- 2016 年，YouTube 等大型平台转向 HTML5 技术。
- 2020 年底，Adobe 正式终止对 Flash Player 的支持。

**Flash 技术的消亡直接导致了 FLV 格式的过时：**

1. 兼容性挑战： 现代操作系统、浏览器和移动设备已不再原生支持 Flash/FLV。虽然部分播放器仍可通过插件或特定解码器播放 FLV，但原生、广泛、无缝的支持已不复存在，给播放带来不便。
2. 格式限制： FLV 作为一种较旧的封装格式，其设计无法原生支持现代高效的视频编码标准，如 HEVC (H.265), VP9, AV1 等。虽然它支持 AVC/H.264，但 H.264 本身在压缩效率上已被更新的编码标准超越。
3. 现代应用脱节： 当前主流的视频平台、编辑软件、硬件播放设备以及流媒体服务，普遍优先支持 MP4 (通常封装 H.264/HEVC) 和 MKV 等更现代、更灵活、兼容性更广的封装格式。

因此，将存储的 FLV 视频转换为 MP4 或 MKV 封装，不仅是告别一个过时技术时代的象征，更是为了确保视频文件在现代环境中的长期可访问性、兼容性和未来适用性。本工具正是为了解决用户批量转换海量 FLV 文件的这一实际需求而设计。

## 使用方法

此项目支持**Windows**和**所有Linux发行版**使用。Windows系统建议使用**Windows 10 22H2**以及**Windows 11**。需要提前配置好**ffmpeg**

### Windows 系统

1. 安装**ffmpeg**

```powershell
winget install ffmpeg
```

2. 克隆此仓库（或下载此项目并解压）

```powershell
git clone https://github.com/Amekiri-Studio/flv2mp4.git
```

3. 进入**flv2mp4**（若直接下载并解压后则在**flv2mp4-master**）目录，应该会有如下文件

```powershell
Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a----         7/18/2025   1:39 PM           4185 flv2mp4.bat
-a----         7/18/2025   1:39 PM           8925 flv2mp4.sh
-a----         7/18/2025   1:39 PM           2700 flvcleaner.bat
-a----         7/18/2025   1:39 PM           6319 flvcleaner.sh
-a----         7/18/2025   1:39 PM           1071 LICENSE
```

> .sh是Linux/Unix的脚本文件，Windows无法直接处理该文件。这里只讲解.bat文件

#### 文件讲解

`flv2mp4.bat`：主批处理文件。通过调用ffmpeg将MP4封装转换为MKV封装。

使用方法：

方法1：将文件直接复制到FLV视频文件目录，然后双击运行，按照提示操作
方法2：打开终端（Powershell），然后执行以下命令：

```powershell
.\flv2mp4.bat [FLV视频目录] [mp4/mkv]
```

使用案例：

```powershell
.\flv2mp4.bat E:\Videos\flv mp4
```

`flvcleaner.bat`：FLV清理工具，主要用于视频顺利转换为MP4封装后，对原来的FLV文件进行清理，以节约硬盘空间。

> 温馨提示：此批处理只会删除和MP4同名（不包括拓展名）的FLV文件，不会删除转换失败的FLV文件。

使用方法：

方法1：将文件直接复制到FLV视频文件目录，然后双击运行。此批处理文件将会快速进行处理
方法2：打开终端（Powershell），然后执行以下命令：

```powershell
.\flvcleaner.bat [FLV视频目录]
```

使用案例：

```powershell
.\flvcleaner.bat E:\Videos\flv mp4
```

通过此批处理，可以快速删除不需要的FLV文件，从而节约磁盘空间。

### 基于Linux的发行版

由于Linux发行版众多，因此这里只讲解主流发行版的安装以及使用

1. **ffmpeg安装：**

#### Ubuntu/Debian

```shell
sudo apt update
sudo apt install ffmpeg
```

#### Arch Linux/Manjaro

```shell
sudo pacman -S ffmpeg
```

#### openSUSE

```shell
sudo zypper install ffmpeg
```

#### 编译安装

由于编译安装步骤较多，这里不进行阐述。可根据**ffmpeg**官方文档进行操作

2. 克隆项目

通过``Git``，将该项目克隆到本地目录：

```shell
git clone https://github.com/Amekiri-Studio/flv2mp4.git
```

3. 进入`flv2mp4`目录，应该会有以下文件：

```
total 56K
drwxr-xr-x  3 user user 4.0K Jul 18 13:42 .
drwx------ 51 user user 4.0K Jul 18 14:34 ..
-rw-r--r--  1 user user 4.1K Jul 17 22:41 flv2mp4.bat
-rw-r--r--  1 user user 8.8K Jul 17 22:42 flv2mp4.sh
-rw-r--r--  1 user user 2.7K Jul 18 13:30 flvcleaner.bat
-rw-r--r--  1 user user 6.2K Jul 18 13:38 flvcleaner.sh
-rw-r--r--  1 user user 1.1K Jul 18 13:30 LICENSE
-rw-r--r--  1 user user 4.7K Jul 18 14:33 README.md
```

> .bat文件是Windows Batch File（批处理文件），Linux无法直接运行，因此只介绍.sh文件

4. 添加可执行权限：

由于Linux下，默认从互联网下载的文件是没有可执行权限的（如上所示），因此若要执行，需要添加可执行权限：

```sh
chmod +x flv2mp4.sh
chmod +x flvcleaner.sh
```

这个时候就可以执行了

```
drwxr-xr-x  3 user user 4.0K Jul 18 13:42 .
drwx------ 51 user user 4.0K Jul 18 14:37 ..
-rw-r--r--  1 user user 4.1K Jul 17 22:41 flv2mp4.bat
-rwxr-xr-x  1 user user 8.8K Jul 17 22:42 flv2mp4.sh
-rw-r--r--  1 user user 2.7K Jul 18 13:30 flvcleaner.bat
-rwxr-xr-x  1 user user 6.2K Jul 18 13:38 flvcleaner.sh
-rw-r--r--  1 user user 1.1K Jul 18 13:30 LICENSE
-rw-r--r--  1 user user 5.5K Jul 18 14:37 README.md
```

5. 开始使用

文件`flv2mp4.sh`，输入以下命令：

```shell
./flv2mp4.sh --help
```

```
FLV 视频转换工具
用法: ./flv2mp4.sh [选项]
选项:
  -d, --directory <路径>   指定要处理的目录 (默认: 脚本所在目录)
  -f, --format <mp4|mkv>   指定输出格式 (默认: 询问选择)
  -l, --logdir <路径>      指定日志保存目录 (默认: ~/video_conversion_logs)
  -q, --quiet              静默模式，不显示进度
  -h, --help               显示此帮助信息

示例:
  ./flv2mp4.sh -d ~/Videos -f mp4    # 转换 ~/Videos 目录下的 FLV 到 MP4
  ./flv2mp4.sh -f mkv                # 转换当前目录下的 FLV 到 MKV
```

文件`flvcleaner.sh`，输入以下命令：

```sh
./flvcleaner.sh --help
```

```
删除存在同名 MP4 或 MKV 文件的 FLV 文件
用法: ./flvcleaner.sh [选项] [目录]
选项:
  -d, --dir <路径>    指定要清理的目录 (默认: 当前目录)
  -l, --logdir <路径> 指定日志保存目录 (默认: 目标目录/FLV_Cleanup_Logs)
  -q, --quiet         静默模式，不显示进度
  -h, --help          显示此帮助信息

示例:
  ./flvcleaner.sh -d ~/Videos      # 清理 ~/Videos 目录
  ./flvcleaner.sh                  # 清理当前目录
```