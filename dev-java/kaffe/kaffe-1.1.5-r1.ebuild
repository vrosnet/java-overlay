# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/kaffe/kaffe-1.1.5.ebuild,v 1.7 2005/07/19 18:36:27 axxo Exp $

inherit java flag-o-matic

DESCRIPTION="A cleanroom, open source Java VM and class libraries"
SRC_URI="http://www.kaffe.org/ftp/pub/kaffe/v1.1.x-development/${P/_/-}.tar.gz"
HOMEPAGE="http://www.kaffe.org/"

#robilad recommned in bug 103978 that we leave the X and QT 
#awt backends disabled for now. Please check the status of these
#backends with new upstream versions.
#	X?( virtual/x11 )
#	qt?( =x11-libs/qt-3.3* )

DEPEND="
	>=media-libs/jpeg-6b
	>=media-libs/libpng-1.2.1
	virtual/libc
	virtual/x11
	>=dev-java/java-config-0.2.4
	app-arch/zip
	dev-java/jikes
	dev-libs/libxml2
	sys-libs/zlib
	gtk? (
		>=dev-libs/glib-2.0
		>=x11-libs/gtk+-2.0
		>=media-libs/libart_lgpl-2.0
		media-libs/gdk-pixbuf )
	esd?( media-sound/esound )
	alsa?( media-libs/alsa-lib )
	gmp?( >=dev-libs/gmp-3.1 )"
RDEPEND=${DEPEND}
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~sparc ~amd64 -ppc"
#X qt
IUSE="alsa esd gmp gtk nls"

PROVIDE="virtual/jdk
	virtual/jre"
#S=${WORKDIR}/kaffe-${date}

src_compile() {
	local confargs=""

	# see #88330
	strip-flags "-fomit-frame-pointer"

	if ! use alsa && ! use esd; then
		confargs="${confargs} --disable-sound"
	fi

	if ! use gmp; then
		confargs="${confargs} --enable-pure-java-math"
		ewarn "You have don't have the gmp use flag set."
		ewarn "Using gmp is the default upstream setting."
		sleep 3
	fi

	if ! use gtk; then
		ewarn ""
		ewarn "The gtk use flag is needed for a awt implementation."
		ewarn "Don't file bugs for awt not working when you have"
		ewarn "gtk use flag turned off."
		sleep 3
	fi

#		$(use_with X x) \
#		$(use_with X kaffe-x-awt) \
#		$(use_with qt kaffe-qt-awt ) \

	./configure \
		--prefix=/opt/${P} \
		--host=${CHOST} \
		$(use_with alsa)\
		$(use_with esd) \
		$(use_with gmp) \
		$(use_enable nls) \
		$(use_with gtk classpath-gtk-awt) \
		${confargs} \
		--with-jikes || die "Failed to configure"
	# --with-bcel
	# --with-profiling
	make || die "Failed to compile"
}

src_install() {
	make DESTDIR=${D} install || die "Failed to install"
	set_java_env ${FILESDIR}/${VMHANDLE} || die "Failed to install environment files"
}

pkg_postinst() {
	ewarn "Plase do not use Kaffe as your default JDK/JRE!"
	ewarn "Kaffe is currently meant for testing... it should be"
	ewarn "only be used by developers or bug-hunters willing to deal"
	ewarn "with oddities that are bound to come up while using Kaffe!"
}
