# Copyright 2026 Chua Zheng Leong
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )

inherit python-single-r1 bash-completion-r1

DESCRIPTION="Command-line interface for Google Cloud Platform"
HOMEPAGE="https://cloud.google.com/sdk/"
SRC_URI="
	amd64? ( https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/${P}-linux-x86_64.tar.gz )
	arm64? ( https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/${P}-linux-arm.tar.gz )
"

S="${WORKDIR}/google-cloud-sdk"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="alpha beta"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="${PYTHON_DEPS}"

RESTRICT="mirror strip"

QA_PREBUILT="usr/share/google-cloud-sdk/*"

src_prepare() {
	default

	# Remove bundled Python and packaging scripts
	rm -rf deb rpm install.* || die
	rm -rf platform/bundledpythonunix || die
	rm -rf platform/gsutil/third_party/crcmod_osx || die
	find . -type d -name "python2" -prune -exec rm -rf {} + || die

	python_fix_shebang --force .
}

src_install() {
	insinto /usr/share/google-cloud-sdk
	doins -r .

	# Restore executable permissions on bin scripts
	local f
	for f in "${ED}"/usr/share/google-cloud-sdk/bin/*; do
		[[ -f "${f}" ]] && fperms +x "/usr/share/google-cloud-sdk/bin/${f##*/}"
	done

	# Restore executable permissions on platform scripts
	fperms +x /usr/share/google-cloud-sdk/bin/bootstrapping/gsutil.py
	fperms +x /usr/share/google-cloud-sdk/bin/bootstrapping/bq.py

	dosym ../share/google-cloud-sdk/bin/gcloud /usr/bin/gcloud
	dosym ../share/google-cloud-sdk/bin/gsutil /usr/bin/gsutil
	dosym ../share/google-cloud-sdk/bin/bq /usr/bin/bq
	dosym ../share/google-cloud-sdk/bin/gcloud-crc32c /usr/bin/gcloud-crc32c
	dosym ../share/google-cloud-sdk/bin/docker-credential-gcloud /usr/bin/docker-credential-gcloud
	dosym ../share/google-cloud-sdk/bin/git-credential-gcloud.sh /usr/bin/git-credential-gcloud.sh

	newbashcomp completion.bash.inc gcloud
	bashcomp_alias gcloud bq gsutil

	if use beta; then
		insinto /usr/share/google-cloud-sdk/lib/surface/beta
		newins "${FILESDIR}"/beta-init.py __init__.py
	fi

	if use alpha; then
		insinto /usr/share/google-cloud-sdk/lib/surface/alpha
		newins "${FILESDIR}"/alpha-init.py __init__.py
	fi

	python_optimize "${ED}/usr/share/google-cloud-sdk"
}
