# �汾��
VER_MAJOR := 0         #���汾��
VER_MINOR := 1         #�ΰ汾��
VER_BUILD := 0         #��ʽת��汾��
VER_REVISION := 0      #���԰汾��

# ����Ŀ���ļ���
PROGRAM := dlc_demo
PROGRAMPATH := .

# C/C++Դ����Ŀ¼����֧�ֶ��Ŀ¼��
SRCDIRS := .

#�Ƿ����
DEBUG := -Wall -g -O0

#ͷ�ļ�Ŀ¼
INCDIR = -I./include
#���ļ�Ŀ¼
LIBDIR = -L./lib

# C/C++����ѡ������
CPPFLAGS :=  -std=c++11

LIBS = -ldhnetsdk
