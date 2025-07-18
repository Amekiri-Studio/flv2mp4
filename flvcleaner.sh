#!/bin/bash

# =====================================================================
# FLV 文件清理工具 - 删除已转换的 FLV 文件
# 当目录中存在同名 MP4 或 MKV 文件时，删除对应的 FLV 文件
# =====================================================================

# 默认设置
DEFAULT_TARGET_DIR=$(pwd)
LOG_DIR="FLV_Cleanup_Logs"
LOG_FILE=""
TOTAL_FLV=0
DELETED=0
SKIPPED=0

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

# 显示帮助信息
show_help() {
    echo -e "${GREEN}FLV 文件清理工具${NC}"
    echo "删除存在同名 MP4 或 MKV 文件的 FLV 文件"
    echo "用法: $0 [选项] [目录]"
    echo "选项:"
    echo "  -d, --dir <路径>    指定要清理的目录 (默认: 当前目录)"
    echo "  -l, --logdir <路径> 指定日志保存目录 (默认: 目标目录/FLV_Cleanup_Logs)"
    echo "  -q, --quiet         静默模式，不显示进度"
    echo "  -h, --help          显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 -d ~/Videos      # 清理 ~/Videos 目录"
    echo "  $0                  # 清理当前目录"
    exit 0
}

# 解析命令行参数
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -d|--dir)
                TARGET_DIR="$2"
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
            -*)
                echo -e "${RED}错误: 未知选项 '$1'${NC}"
                show_help
                exit 1
                ;;
            *)
                # 位置参数处理
                if [ -z "$TARGET_DIR" ]; then
                    TARGET_DIR="$1"
                    shift
                else
                    echo -e "${RED}错误: 多余参数 '$1'${NC}"
                    show_help
                    exit 1
                fi
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
    LOG_DIR="$TARGET_DIR/$LOG_DIR"
    mkdir -p "$LOG_DIR"
    
    # 生成日志文件名
    LOG_FILE="$LOG_DIR/FLV_Cleanup_$(date +%Y%m%d_%H%M%S).log"
    
    # 显示配置信息
    if [ "$QUIET_MODE" != true ]; then
        echo -e "${GREEN}配置信息:${NC}"
        echo "目标目录: $TARGET_DIR"
        echo "日志目录: $LOG_DIR"
    fi
}

# 清理文件
clean_flv_files() {
    # 写入日志头
    echo "FLV 文件清理日志" > "$LOG_FILE"
    echo "目标目录: $TARGET_DIR" >> "$LOG_FILE"
    echo "开始时间: $(date)" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
    
    if [ "$QUIET_MODE" != true ]; then
        echo -e "${GREEN}开始扫描目录: $TARGET_DIR${NC}"
    fi
    
    # 查找所有 FLV 文件
    while IFS= read -r -d $'\0' flv_file; do
        TOTAL_FLV=$((TOTAL_FLV + 1))
        
        # 获取文件信息
        flv_dir=$(dirname "$flv_file")
        flv_name=$(basename "$flv_file" .flv)
        flv_name_no_case=$(echo "$flv_name" | tr '[:upper:]' '[:lower:]')
        
        # 写入日志
        echo "检查FLV文件: $flv_file" >> "$LOG_FILE"
        
        # 查找同名视频文件 (不区分大小写)
        found_replacement=false
        for ext in mp4 mkv; do
            # 查找匹配的文件 (不区分大小写)
            find "$flv_dir" -maxdepth 1 -type f -iname "${flv_name_no_case}.${ext}" -print0 | while IFS= read -r -d $'\0' video_file; do
                # 获取实际文件名（保留原始大小写）
                actual_name=$(basename "$video_file")
                echo "  找到同名${ext^^}文件: $actual_name" >> "$LOG_FILE"
                found_replacement=true
            done
        done
        
        if $found_replacement; then
            # 尝试删除 FLV 文件
            if rm -f "$flv_file"; then
                echo "  删除FLV文件: 成功" >> "$LOG_FILE"
                DELETED=$((DELETED + 1))
                
                if [ "$QUIET_MODE" != true ]; then
                    echo -e "  ${GREEN}✓ 已删除: $(basename "$flv_file")${NC}"
                fi
            else
                echo "  删除FLV文件: 失败 (权限错误?)" >> "$LOG_FILE"
                if [ "$QUIET_MODE" != true ]; then
                    echo -e "  ${RED}✗ 删除失败: $(basename "$flv_file")${NC}"
                fi
            fi
        else
            echo "  未找到同名MP4/MKV文件，跳过" >> "$LOG_FILE"
            SKIPPED=$((SKIPPED + 1))
            
            if [ "$QUIET_MODE" != true ]; then
                echo -e "  ${YELLOW}↷ 跳过: $(basename "$flv_file")${NC}"
            fi
        fi
        
        echo "" >> "$LOG_FILE"
    done < <(find "$TARGET_DIR" -type f -iname "*.flv" -print0)
}

# 生成报告
generate_report() {
    # 写入日志
    echo "" >> "$LOG_FILE"
    echo "============= 清理统计 =============" >> "$LOG_FILE"
    echo "目标目录: $TARGET_DIR" >> "$LOG_FILE"
    echo "扫描FLV文件数: $TOTAL_FLV" >> "$LOG_FILE"
    echo "已删除FLV文件: $DELETED" >> "$LOG_FILE"
    echo "跳过FLV文件: $SKIPPED" >> "$LOG_FILE"
    echo "开始时间: $(grep "开始时间" "$LOG_FILE" | head -1 | cut -d: -f2-)" >> "$LOG_FILE"
    echo "结束时间: $(date)" >> "$LOG_FILE"
    
    # 显示报告
    if [ "$QUIET_MODE" != true ]; then
        echo -e "\n${GREEN}===== FLV 文件清理完成 =====${NC}"
        echo -e "目标目录: ${BLUE}$TARGET_DIR${NC}"
        echo -e "扫描FLV文件数: ${BLUE}$TOTAL_FLV${NC}"
        echo -e "已删除FLV文件: ${GREEN}$DELETED${NC}"
        echo -e "跳过FLV文件: ${YELLOW}$SKIPPED${NC}"
        echo -e "\n详细日志见: ${BLUE}$LOG_FILE${NC}"
    fi
}

# 主程序
main() {
    parse_arguments "$@"
    initialize
    clean_flv_files
    generate_report
}

# 启动主程序
main "$@"
