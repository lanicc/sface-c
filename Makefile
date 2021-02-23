###############################################
#
#    makefile
#
###############################################
# �÷�:
# $ make: ���벢�������ɿ�ִ���ļ���
# $ make info: �鿴������Ϣ��
# $ make tar:  ��������ļ���
# $ make clean: ɾ��Ŀ���ļ��������ļ���
# $ make cleanall: ɾ��Ŀ���ļ��������ļ��Ϳ�ִ���ļ���
################################################################################

##���������ļ�
include config.mk


# Դ�����ļ���չ����������ͷ�ļ���
# ֧�ֵ��ļ������У� .c, .C, .cc, .cpp, .CPP, .c++, 
SRCEXTS := .c .cpp .cc

# ����C������õı�����
CC = gcc -std=c++11 -lpthread

# ����C++������õı�����
CXX = g++ -lpthread

# ɾ���ļ�����
RM = @rm -f

# �汾������
VERSION_DATE = \"`date +%Y.%m.%d-%H:%M:%S`\"

VERSION_VALUE = -DVER_MAJOR=$(VER_MAJOR) -DVER_MINOR=$(VER_MINOR) -DVER_BUILD=$(VER_BUILD) -DVER_REVISION=$(VER_REVISION) -DVERSION_DATE=$(VERSION_DATE)

## �������ݸ������Լ���Ҫ������ӻ����޸�
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


# ���������ļ� (.d)
# ##############################################################################
%.d : %.c
	@$(CC) -MM -MD $(CFLAGS) $(DEBUG) $(INCDIR) $(LIBDIR)  $(LIBS) $(VERSION_VALUE) $< -o $@
%.d : %.cpp
	@$(CC) -MM -MD $(CXXFLAGS) $(DEBUG) $(INCDIR) $(LIBDIR)  $(LIBS) $(VERSION_VALUE) $< -o $@
%.d : %.cc
	@$(CC) -MM -MD $(CXXFLAGS) $(DEBUG) $(INCDIR) $(LIBDIR) $(LIBS) $(VERSION_VALUE) $< -o $@



# ����OBJS
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


	
# ����Ŀ���ִ���ļ�
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
	@echo " 1) make: ���벢�������ɿ�ִ���ļ���"
	@echo " 2) make info: �鿴������Ϣ��"
	@echo " 3) make tar:  ��������ļ���"
	@echo " 4) make clean: ɾ��Ŀ���ļ��������ļ���"
	@echo " 5) make cleanall: ɾ��Ŀ���ļ��������ļ��Ϳ�ִ���ļ���"
###############################################################################


