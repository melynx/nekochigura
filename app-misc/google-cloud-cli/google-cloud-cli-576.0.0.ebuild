# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )

inherit python-single-r1 shell-completion

DESCRIPTION="Command-line interface for Google Cloud Platform"
HOMEPAGE="https://cloud.google.com/sdk/"
SRC_URI="
	amd64? ( https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/${P}-linux-x86_64.tar.gz )
	arm64? ( https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/${P}-linux-arm.tar.gz )
"

S="${WORKDIR}/google-cloud-sdk"

LICENSE="Apache-2.0 BSD BSD-2 ISC LGPL-2.1+ MIT MPL-2.0 PSF-2 public-domain"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="alpha-commands beta-commands"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="${PYTHON_DEPS}"

RESTRICT="mirror strip"

QA_PREBUILT="usr/share/google-cloud-sdk/bin/gcloud-crc32c"

src_prepare() {
	default

	# Remove bundled Python and packaging scripts
	rm -rf deb rpm install.* || die
	rm -rf platform/bundledpythonunix || die
	rm -rf platform/gsutil/third_party/crcmod_osx || die
	find . -type d -name "python2" -prune -exec rm -rf {} + || die
	# Keep complete runtime boundaries: gcloud has a real "firebase test"
	# command under these otherwise test-like paths, and gslib is one
	# self-checksummed unit with an installed "test" command of its own.
	find . \
		\( \
			-path "./lib/googlecloudsdk" -o \
			-path "./lib/surface" -o \
			-path "./platform/gsutil/gslib" \
		\) -prune -o \
		-type d \( \
			-name "test" -o \
			-name "tests" -o \
			-name "docs" -o \
			-name "examples" \
		\) -prune -exec rm -rf {} + || die
	rm -rf \
		lib/third_party/lark/__pyinstaller \
		platform/gsutil/third_party/charset_normalizer/data || die

	# Portage owns this installation, so component updates must go through
	# the package manager.
	sed -i 's/"disable_updater": false/"disable_updater": true/' \
		lib/googlecloudsdk/core/config.json || die
	grep -q '"disable_updater": true' \
		lib/googlecloudsdk/core/config.json || die

	# Honor PYTHON_SINGLE_TARGET while preserving explicit CLOUDSDK_PYTHON,
	# CLOUDSDK_BQ_PYTHON, and CLOUDSDK_GSUTIL_PYTHON overrides.
	local launcher
	for launcher in \
		bin/bq \
		bin/docker-credential-gcloud \
		bin/gcloud \
		bin/git-credential-gcloud.sh \
		bin/gsutil \
		bin/java_dev_appserver.sh
	do
		sed -i "s/primary_python=python3.14/primary_python=${EPYTHON}/" \
			"${launcher}" || die
		grep -q "primary_python=${EPYTHON}" "${launcher}" || die
	done

	# The platform component trees contain Python 2 compatibility/test files;
	# rewriting them changes gsutil's self-checksum. Only these entry points
	# need their shebangs tied to the selected interpreter.
	python_fix_shebang --force bin
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

	if use beta-commands; then
		insinto /usr/share/google-cloud-sdk/lib/surface/beta
		newins "${FILESDIR}"/beta-init.py __init__.py
	fi

	if use alpha-commands; then
		insinto /usr/share/google-cloud-sdk/lib/surface/alpha
		newins "${FILESDIR}"/alpha-init.py __init__.py
	fi

	# Some bundled component/test trees still contain Python 2-only sources.
	# Precompile the active Python 3 runtime without emitting errors for those
	# inactive compatibility files.
	python_optimize \
		"${ED}/usr/share/google-cloud-sdk/bin/bootstrapping" \
		"${ED}/usr/share/google-cloud-sdk/lib/googlecloudsdk" \
		"${ED}/usr/share/google-cloud-sdk/lib/surface"
}
