#!/bin/bash

# =============================================
# FLV 视频转换工具 (Linux Shell 版本)
# 支持无损封装转换和智能转码
# =============================================

# 默认设置
DEFAULT_TARGET_DIR=$(dirname "$0")
DEFAULT_LOG_DIR="$HOME/video_conversion_logs"
FFMPEG_CMD="ffmpeg"
LOG_FILE=""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

# 显示帮助信息
show_help() {
    echo -e "${GREEN}FLV 视频转换工具${NC}"
    echo "用法: $0 [选项]"
    echo "选项:"
    echo "  -d, --directory <路径>   指定要处理的目录 (默认: 脚本所在目录)"
    echo "  -f, --format <mp4|mkv>   指定输出格式 (默认: 询问选择)"
    echo "  -l, --logdir <路径>      指定日志保存目录 (默认: ~/video_conversion_logs)"
    echo "  -q, --quiet              静默模式，不显示进度"
    echo "  -h, --help               显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 -d ~/Videos -f mp4    # 转换 ~/Videos 目录下的 FLV 到 MP4"
    echo "  $0 -f mkv                # 转换当前目录下的 FLV 到 MKV"
    exit 0
}

# 解析命令行参数
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -d|--directory)
                TARGET_DIR="$2"
                shift 2
                ;;
            -f|--format)
                OUTPUT_EXT="$2"
                shift 2
                ;;
            -l|--logdir)
                LOG_DIR="$2"
                shift 2
                ;;
            -q|--quiet)
                QUIET_MODE=true
                shift
                ;;
            -h|--help)
                show_help
                ;;
            *)
                echo -e "${RED}错误: 未知参数 '$1'${NC}"
                show_help
                exit 1
                ;;
        esac
    done
}

# 初始化设置
initialize() {
    # 设置目标目录
    if [ -z "$TARGET_DIR" ]; then
        TARGET_DIR="$DEFAULT_TARGET_DIR"
    fi
    
    # 确保目录存在
    if [ ! -d "$TARGET_DIR" ]; then
        echo -e "${RED}错误: 目录不存在 - $TARGET_DIR${NC}"
        exit 1
    fi
    
    # 创建日志目录
    if [ -z "$LOG_DIR" ]; then
        LOG_DIR="$DEFAULT_LOG_DIR"
    fi
    mkdir -p "$LOG_DIR"
    
    # 生成日志文件名
    LOG_FILE="$LOG_DIR/video_conversion_$(date +%Y%m%d_%H%M%S).log"
    
    # 检查 ffmpeg 是否可用
    if ! command -v $FFMPEG_CMD &> /dev/null; then
        echo -e "${RED}错误: 未找到 ffmpeg，请先安装${NC}"
        exit 1
    fi
    
    # 显示配置信息
    if [ "$QUIET_MODE" != true ]; then
        echo -e "${GREEN}配置信息:${NC}"
        echo "目标目录: $TARGET_DIR"
        echo "日志目录: $LOG_DIR"
        echo "日志文件: $(basename "$LOG_FILE")"
    fi
}

# 选择输出格式
select_format() {
    if [ -z "$OUTPUT_EXT" ]; then
        echo -e "${YELLOW}请选择输出格式:${NC}"
        echo "1) MP4 (推荐)"
        echo "2) MKV"
        
        while true; do
            read -rp "输入选择 (1/2): " choice
            case $choice in
                1) 
                    OUTPUT_EXT="mp4"
                    break
                    ;;
                2) 
                    OUTPUT_EXT="mkv"
                    break
                    ;;
                *) 
                    echo -e "${RED}无效选择，请重新输入${NC}"
                    ;;
            esac
        done
    else
        # 验证格式参数
        OUTPUT_EXT=$(echo "$OUTPUT_EXT" | tr '[:upper:]' '[:lower:]')
        if [[ "$OUTPUT_EXT" != "mp4" && "$OUTPUT_EXT" != "mkv" ]]; then
            echo -e "${RED}错误: 无效的输出格式 '$OUTPUT_EXT'，必须是 mp4 或 mkv${NC}"
            exit 1
        fi
    fi
    
    if [ "$QUIET_MODE" != true ]; then
        echo -e "${GREEN}输出格式: $OUTPUT_EXT${NC}"
    fi
}

# 转换单个视频文件
convert_video() {
    local input_file="$1"
    local output_file="${input_file%.*}.$OUTPUT_EXT"
    local log_entry="处理文件: $input_file"
    local success=false
    local transcoded=false
    
    # 记录开始时间
    local start_time=$(date +%s)
    
    # 写入日志
    echo -e "\n$log_entry" >> "$LOG_FILE"
    echo "开始时间: $(date)" >> "$LOG_FILE"
    
    # 显示进度
    if [ "$QUIET_MODE" != true ]; then
        echo -e "${BLUE}正在处理: $(basename "$input_file")${NC}"
    fi
    
    # 第一步：尝试无损封装转换
    echo "[步骤1] 尝试无损复制流..." >> "$LOG_FILE"
    $FFMPEG_CMD -i "$input_file" -c:v copy -c:a copy -map_metadata 0 -movflags +faststart -y "$output_file" >> "$LOG_FILE" 2>&1
    
    if [ $? -eq 0 ]; then
        success=true
        echo "[成功] 无损转换完成: $output_file" >> "$LOG_FILE"
        if [ "$QUIET_MODE" != true ]; then
            echo -e "  ${GREEN}✓ 无损转换完成${NC}"
        fi
    else
        # 第二步：如果失败则进行转码
        echo "[警告] 无损转换失败，尝试转码..." >> "$LOG_FILE"
        rm -f "$output_file" 2>/dev/null
        
        # 智能转码设置
        local vcodec="libx264"
        local acodec="aac"
        local vparams="-preset medium -crf 23"
        local aparams="-b:a 192k"
        
        echo "[步骤2] 转码为H.264/AAC..." >> "$LOG_FILE"
        $FFMPEG_CMD -i "$input_file" -c:v $vcodec $vparams -c:a $acodec $aparams -map_metadata 0 -movflags +faststart -y "$output_file" >> "$LOG_FILE" 2>&1
        
        if [ $? -eq 0 ]; then
            success=true
            transcoded=true
            echo "[成功] 转码完成: $output_file" >> "$LOG_FILE"
            if [ "$QUIET_MODE" != true ]; then
                echo -e "  ${YELLOW}⚠ 转码完成${NC}"
            fi
        else
            echo "[失败] 转换出错: $input_file" >> "$LOG_FILE"
            rm -f "$output_file" 2>/dev/null
            if [ "$QUIET_MODE" != true ]; then
                echo -e "  ${RED}✗ 转换失败${NC}"
            fi
        fi
    fi
    
    # 记录结束时间和持续时间
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    echo "结束时间: $(date)" >> "$LOG_FILE"
    echo "处理时间: ${duration}秒" >> "$LOG_FILE"
    echo "--------------------------------------------------" >> "$LOG_FILE"
    
    # 更新统计信息
    if $success; then
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        if $transcoded; then
            TRANSCODED_COUNT=$((TRANSCODED_COUNT + 1))
        fi
    fi
}

# 主处理函数
process_videos() {
    # 初始化统计变量
    TOTAL_COUNT=0
    SUCCESS_COUNT=0
    TRANSCODED_COUNT=0
    
    # 创建日志文件
    echo "视频转换日志" > "$LOG_FILE"
    echo "开始时间: $(date)" >> "$LOG_FILE"
    echo "目标目录: $TARGET_DIR" >> "$LOG_FILE"
    echo "输出格式: $OUTPUT_EXT" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
    
    # 查找并处理FLV文件
    if [ "$QUIET_MODE" != true ]; then
        echo -e "${GREEN}开始扫描目录: $TARGET_DIR${NC}"
    fi
    
    # 使用find命令递归查找FLV文件
    while IFS= read -r -d $'\0' file; do
        TOTAL_COUNT=$((TOTAL_COUNT + 1))
        convert_video "$file"
    done < <(find "$TARGET_DIR" -type f -iname "*.flv" -print0)
    
    # 生成最终报告
    generate_report
}

# 生成转换报告
generate_report() {
    # 写入日志
    echo -e "\n============= 转换统计 =============" >> "$LOG_FILE"
    echo "目标目录: $TARGET_DIR" >> "$LOG_FILE"
    echo "输出格式: $OUTPUT_EXT" >> "$LOG_FILE"
    echo "总处理文件数: $TOTAL_COUNT" >> "$LOG_FILE"
    echo "成功转换文件: $SUCCESS_COUNT" >> "$LOG_FILE"
    echo "其中无损封装: $((SUCCESS_COUNT - TRANSCODED_COUNT))" >> "$LOG_FILE"
    echo "需要转码文件: $TRANSCODED_COUNT" >> "$LOG_FILE"
    echo "失败文件数: $((TOTAL_COUNT - SUCCESS_COUNT))" >> "$LOG_FILE"
    echo "开始时间: $(date -d @$(grep "开始时间" "$LOG_FILE" | head -1 | cut -d: -f2-))" >> "$LOG_FILE"
    echo "结束时间: $(date)" >> "$LOG_FILE"
    
    # 显示报告
    if [ "$QUIET_MODE" != true ]; then
        echo -e "\n${GREEN}===== 视频转换完成 =====${NC}"
        echo -e "目标目录: ${BLUE}$TARGET_DIR${NC}"
        echo -e "输出格式: ${YELLOW}$OUTPUT_EXT${NC}"
        echo -e "总文件数:   ${BLUE}$TOTAL_COUNT${NC}"
        echo -e "成功转换:   ${GREEN}$SUCCESS_COUNT${NC}"
        echo -e "无损封装:   ${GREEN}$((SUCCESS_COUNT - TRANSCODED_COUNT))${NC}"
        echo -e "需要转码:   ${YELLOW}$TRANSCODED_COUNT${NC}"
        echo -e "失败文件:   ${RED}$((TOTAL_COUNT - SUCCESS_COUNT))${NC}"
        echo -e "\n详细日志见: ${BLUE}$LOG_FILE${NC}"
    fi
}

# 主程序
main() {
    parse_arguments "$@"
    initialize
    select_format
    process_videos
}

# 启动主程序
main "$@"
