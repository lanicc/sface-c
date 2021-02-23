# 版本号
VER_MAJOR := 0         #主版本号
VER_MINOR := 1         #次版本号
VER_BUILD := 0         #正式转测版本号
VER_REVISION := 0      #调试版本号

# 生成目标文件名
PROGRAM := dlc_demo
PROGRAMPATH := .

# C/C++源代码目录集（支持多个目录）
SRCDIRS := .

#是否调试
DEBUG := -Wall -g -O0

#头文件目录
INCDIR = -I./include
#库文件目录
LIBDIR = -L./lib

# C/C++编译选项设置
CPPFLAGS :=  -std=c++11

LIBS = -ldhnetsdk
