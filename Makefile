.POSIX:

XCFLAGS = -DMAJOR_IN_SYSMACROS ${CFLAGS} -nostdlib -std=c99 -fPIC -pthread -D_POSIX_C_SOURCE=200809L \
		  -Wall -Wextra -Wno-pedantic -Wmissing-prototypes -Wstrict-prototypes \
		  -Wno-unused-parameter -I. $(shell pkg-config --cflags libdrm)
XLDFLAGS = ${LDFLAGS} -shared -Wl,-soname,libkms.so.1 $(shell pkg-config --libs libdrm)

LIBDIR ?= /lib64

ALL_OBJ = \
	linux.o \
	dumb.o \
	api.o \
	vmwgfx.o \
	intel.o \
	nouveau.o \
	radeon.o \
	exynos.o \


OBJ = \
	linux.o \
	dumb.o \
	api.o \


ifeq (${vmware}, 1)
	OBJ += vmwgfx.o
endif

ifeq (${intel}, 1)
	OBJ += intel.o
endif

ifeq (${nouveau}, 1)
	OBJ += nouveau.o
endif

ifeq (${radeon}, 1)
	OBJ += radeon.o
endif

ifeq (${exynos}, 1)
	OBJ += exynos.o
endif

all: libkms.so.1

.c.o:
	${CC} ${XCFLAGS} -c -o $@ $<

libkms.so.1: ${OBJ}
	${CC} ${XCFLAGS} -o $@ ${OBJ} ${XLDFLAGS}

install: libkms.so.1
	mkdir -p ${DESTDIR}${LIBDIR}
	cp -f libkms.so.1 ${DESTDIR}${LIBDIR}/libkms.so.1.0.0
	ln -rsf ${DESTDIR}${LIBDIR}/libkms.so.1.0.0 ${DESTDIR}${LIBDIR}/libkms.so.1
	ln -rsf ${DESTDIR}${LIBDIR}/libkms.so.1 ${DESTDIR}${LIBDIR}/libkms.so
	mkdir -p ${DESTDIR}${LIBDIR}/pkgconfig
	cp -f libkms.pc ${DESTDIR}${LIBDIR}/pkgconfig/libkms.pc
	mkdir -p ${DESTDIR}/usr/include/libkms
	cp -f libkms.h ${DESTDIR}/usr/include/libkms/libkms.h
uninstall:
	rm -f ${DESTDIR}${LIBDIR}/libkms.so.1.0.0
	rm -f ${DESTDIR}${LIBDIR}/libkms.so.1
	rm -f ${DESTDIR}${LIBDIR}/libkms.so
	rm -f ${DESTDIR}${LIBDIR}/pkgconfig/libkms.pc
	rm -f ${DESTDIR}/usr/include/libkms

clean:
	rm -f libkms.so.1 ${ALL_OBJ}

.PHONY: all clean install uninstall
