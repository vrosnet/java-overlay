# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg eutils

MY_P="${P}-src"
DESCRIPTION="CAROL is a library allowing to use different RMI implementations."
HOMEPAGE="http://carol.objectweb.org/"
SRC_URI="http://download.fr2.forge.objectweb.org/${PN}/${MY_P}.tgz"

LICENSE="LGPL-2.1"
SLOT="2"
KEYWORDS="~x86"
IUSE="doc jikes"

DEPEND="virtual/jdk"
RDEPEND="virtual/jre
	dev-java/commons-collections
	dev-java/commons-logging
	dev-java/irmi
	dev-java/jacorb
	=dev-java/mx4j-2.1*
	dev-java/velocity"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd ${S}
	
	use jikes && epatch ${FILESDIR}/${P}-jikes.patch
	cd externals
	rm *.jar
	java-pkg_jar-from commons-collections
	java-pkg_jar-from commons-logging commons-logging-api.jar
	java-pkg_jar-from irmi
	java-pkg_jar-from jacorb jacorb.jar
	java-pkg_jar-from mx4j-2.1 mx4j.jar
	java-pkg_jar-from velocity
	java-pkg_jar-from jgroups jgroups-core.jar
}

src_compile() {
	local antflags="jar"
	use jikes && antflags="-Dbuild.compiler=jikes ${antflags}"
	use doc && antflags="${antflags} jdoc -Ddist.jdoc=output/dist/api"

	ant ${antflags} || die "Compilation failed"

	# This is provided by irmi
	rm output/dist/lib/irmi.jar
}

src_install() {
	java-pkg_dojar output/dist/lib/*.jar

	use doc && java-pkg_dohtml -r output/dist/api
}
