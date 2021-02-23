###############################################
#
#    makefile
#
###############################################
# 用法:
# $ make: 编译并链接生成可执行文件；
# $ make info: 查看帮助信息；
# $ make tar:  打包所有文件；
# $ make clean: 删除目标文件和依赖文件；
# $ make cleanall: 删除目标文件，依赖文件和可执行文件；
################################################################################

##包含配置文件
include config.mk


# 源代码文件扩展名（不包括头文件）
# 支持的文件类型有： .c, .C, .cc, .cpp, .CPP, .c++, 
SRCEXTS := .c .cpp .cc

# 设置C程序采用的编译器
CC = gcc -std=c++11 -lpthread

# 设置C++程序采用的编译器
CXX = g++ -lpthread

# 删除文件命令
RM = @rm -f

# 版本号日期
VERSION_DATE = \"`date +%Y.%m.%d-%H:%M:%S`\"

VERSION_VALUE = -DVER_MAJOR=$(VER_MAJOR) -DVER_MINOR=$(VER_MINOR) -DVER_BUILD=$(VER_BUILD) -DVER_REVISION=$(VER_REVISION) -DVERSION_DATE=$(VERSION_DATE)

## 以下内容根据你自己需要进行添加或者修改
###############################################################################
SHELL = /bin/sh
SOURCES = $(foreach d,$(SRCDIRS),$(wildcard $(addprefix $(d)/*,$(SRCEXTS)))) 
SOURCES += $(foreach d,$(SRCS),$(d)) 
CPPOBJS = $(foreach x,$(SRCEXTS), $(patsubst %$(x),%.o,$(filter %$(x),$(SOURCES))))
DEPS = $(patsubst %.o,%.d,$(CPPOBJS))

###############################################################################

all : $(PROGRAM)
	@echo
	@echo "***   make my program '$(PROGRAM)' successfully   ***"
	@echo


# 生成依赖文件 (.d)
# ##############################################################################
%.d : %.c
	@$(CC) -MM -MD $(CFLAGS) $(DEBUG) $(INCDIR) $(LIBDIR)  $(LIBS) $(VERSION_VALUE) $< -o $@
%.d : %.cpp
	@$(CC) -MM -MD $(CXXFLAGS) $(DEBUG) $(INCDIR) $(LIBDIR)  $(LIBS) $(VERSION_VALUE) $< -o $@
%.d : %.cc
	@$(CC) -MM -MD $(CXXFLAGS) $(DEBUG) $(INCDIR) $(LIBDIR) $(LIBS) $(VERSION_VALUE) $< -o $@



# 生成OBJS
###############################################################################
%.o : %.c
	@echo "======================================================================="
	$(INSURE) $(CC) -c $(CPPFLAGS) $(DEBUG) $(CFLAGS) $(DEFINE) $(INCDIR) $(LIBDIR) $(VERSION_VALUE)  $(LIBS) $< -o $@
%.o : %.cpp
	@echo "======================================================================="
	$(INSURE) $(CXX) -c $(CPPFLAGS) $(DEBUG) $(CXXFLAGS) $(DEFINE) $(INCDIR) $(LIBDIR) $(VERSION_VALUE) $(LIBS) $< -o $@
%.o : %.cc
	@echo "======================================================================="
	$(INSURE) $(CXX) -c $(CPPFLAGS) $(DEBUG) $(CXXFLAGS) $(DEFINE) $(INCDIR) $(LIBDIR) $(VERSION_VALUE) $(LIBS) $< -o $@


	
# 生成目标可执行文件
###############################################################################
$(PROGRAM) : $(DEPS) $(CPPOBJS)
	@echo "$(DEPS)"
	@echo $(CPPOBJS)
	@echo "======================================================================="
	$(INSURE) $(CXX) -o $(PROGRAMPATH)/$(PROGRAM) $(CPPOBJS) $(CPPFLAGS) $(DEBUG) $(DEFINE) $(INCDIR) $(LIBDIR)  $(LIBS) $(LIB_OBJECT)

-include $(DEPS)


tar : clean
	@tar czvf ../$(PROGRAM)$(CURRENTDATE).tgz ./*
	@echo "*** make tar successfully. ***"
	
clean :
	@echo "======================================================================="	
	@echo $(DEPS)
	@echo $(CPPOBJS)
	@echo $(PROGRAMPATH)/$(PROGRAM)
	@echo "======================================================================="
	@$(RM) $(DEPS) 
	@$(RM) $(CPPOBJS)
	@$(RM) $(PROGRAMPATH)/$(PROGRAM)

cleanall: clean
	@echo $(PROGRAMPATH)/$(PROGRAM)
	@$(RM) $(PROGRAMPATH)/$(PROGRAM)
	
info :
	@echo "usage:"
	@echo " 1) make: 编译并链接生成可执行文件；"
	@echo " 2) make info: 查看帮助信息；"
	@echo " 3) make tar:  打包所有文件；"
	@echo " 4) make clean: 删除目标文件和依赖文件；"
	@echo " 5) make cleanall: 删除目标文件，依赖文件和可执行文件；"
###############################################################################


