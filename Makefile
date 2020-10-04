# $FreeBSD$

PORTNAME=				bcompare
DISTVERSION=			4.3.7
DISTVERSIONSUFFIX=		.25118
CATEGORIES=				editors devel linux
MASTER_SITES=			http://scootersoftware.com/
PKGNAMEPREFIX=			linux-
EXTRACT_SUFX=			.rpm

MAINTAINER=				matias@pizarro.net
COMMENT=				Compare, sync, and merge files and folders (X11)

LICENSE=				SCOOTERSOFTWARE
LICENSE_NAME=			Scooter Software License
LICENSE_FILE=			${FILESDIR}/LICENSE.txt
LICENSE_PERMS=			dist-mirror no-dist-sell pkg-mirror no-pkg-sell no-auto-accept

ONLY_FOR_ARCHS=			amd64 i386
ONLY_FOR_ARCHS_REASON=	Upstream only supports amd64 and i386

USES=					linux desktop-file-utils shared-mime-info shebangfix
USE_LINUX=				base:run xorglibs:run qt-x11:run devtools:build

DISTNAME_amd64=			${DISTNAME}.x86_64
DISTNAME_i386=			${DISTNAME}.i386

NO_WRKSUBDIR=			true
NO_BUILD=				yes

INSTALLS_ICONS=			yes

DATA_FILTER=			-type d \
						-o -name *\.html \
						-o -name *\.js \
						-o -name *\.css \
						-o -name *\.gif \
						-o -name *\.png \
						-o -name *\.jpg \
						-o -name *\.desktop \
						-o -name mime\.types \
						-o -name README \
						-o -name BCompare.mad \
						-o -name RPM-GPG-KEY-scootersoftware \
						-o -name scootersoftware.repo
PROGRAM_FILES=			BCompare \
						bcmount32 \
						bcmount64
SCRIPT_FILES=			bcmount.sh \
						kde_context_menu
LIB_FILES=				libQt4Pas.so.5 \
						lib7z.so \
						libunrar.so \
						nosched.so

.include <bsd.port.options.mk>

.if ${ARCH} == i386
    LIBDIR=				lib
.elif ${ARCH} == amd64
    LIBDIR=				lib64
.endif

BCLIB_SRC=				${WRKSRC}/usr/${LIBDIR}/beyondcompare
BCLIB_STG=				${STAGEDIR}${PREFIX}/lib/beyondcompare

SHEBANG_FILES=			${BCLIB_SRC}/bcmount.sh \
						${BCLIB_SRC}/kde_context_menu

pre-install:
	${LINUXBASE}/usr/bin/gcc -Wall -fPIC -shared ${FILESDIR}/nosched.c -ldl -o ${BCLIB_SRC}/nosched.so

do-install:
	# bin
	(cd ${WRKSRC}/usr/bin && ${INSTALL_SCRIPT} bcompare ${STAGEDIR}${PREFIX}/bin)
	# lib
	(cd ${BCLIB_SRC}     && ${COPYTREE_SHARE}  .                ${BCLIB_STG} "${DATA_FILTER}")
	(cd ${BCLIB_SRC}     && ${INSTALL_PROGRAM} ${PROGRAM_FILES} ${BCLIB_STG})
	(cd ${BCLIB_SRC}     && ${INSTALL_SCRIPT}  ${SCRIPT_FILES}  ${BCLIB_STG})
	(cd ${BCLIB_SRC}     && ${INSTALL_LIB}     ${LIB_FILES}     ${BCLIB_STG})
	(cd ${BCLIB_SRC}/qt4 && ${INSTALL_LIB}     $$(ls *.so.4)    ${BCLIB_STG}/qt4)
	(cd ${BCLIB_SRC}/ext && ${INSTALL_LIB}     $$(ls *.so)      ${BCLIB_STG}/ext)
	${LN} -sf ${LINUXBASE}/usr/${LIBDIR}/libbz2.so.1.0.6 ${BCLIB_STG}/libbz2.so.1.0
	# data
	(cd ${WRKSRC}/usr/share && ${COPYTREE_SHARE} . ${STAGEDIR}${PREFIX}/share)
	${MKDIR} ${STAGEDIR}${PREFIX}/share/icons/hicolor/16x16/apps
	${MKDIR} ${STAGEDIR}${PREFIX}/share/icons/hicolor/32x32/apps
	${MKDIR} ${STAGEDIR}${PREFIX}/share/icons/hicolor/48x48/apps
	${LN} -sf ../../../../pixmaps/bcompare.png ${STAGEDIR}${PREFIX}/share/icons/hicolor/16x16/apps/bcompare.png
	${LN} -sf ../../../../pixmaps/bcomparefull32.png ${STAGEDIR}${PREFIX}/share/icons/hicolor/32x32/apps/bcompare.png
	${LN} -sf ../../../../pixmaps/bcompare.png ${STAGEDIR}${PREFIX}/share/icons/hicolor/48x48/apps/bcompare.png

.include <bsd.port.mk>
