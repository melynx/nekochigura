# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="Patched font collection with a high number of glyphs (icons)"
HOMEPAGE="https://github.com/ryanoasis/nerd-fonts"
SRC_BASE="https://github.com/ryanoasis/nerd-fonts/releases/download/v${PV}"
SRC_URI="
	0xproto? ( ${SRC_BASE}/0xProto.tar.xz -> 0xProto-${PV}.tar.xz )
	3270? ( ${SRC_BASE}/3270.tar.xz -> 3270-${PV}.tar.xz )
	adwaitamono? ( ${SRC_BASE}/AdwaitaMono.tar.xz -> -AdwaitaMono-${PV}.tar.xz )
	agave? ( ${SRC_BASE}/Agave.tar.xz -> Agave-${PV}.tar.xz )
	anonymouspro? ( ${SRC_BASE}/AnonymousPro.tar.xz -> AnonymousPro-${PV}.tar.xz )
	arimo? ( ${SRC_BASE}/Arimo.tar.xz -> Arimo-${PV}.tar.xz )
	atkinsonhyperlegiblemono? ( ${SRC_BASE}/AtkinsonHyperlegibleMono.tar.xz -> AtkinsonHyperlegibleMono-${PV}.tar.xz )
	aurulentsansmono? ( ${SRC_BASE}/AurulentSansMono.tar.xz -> AurulentSansMono-${PV}.tar.xz )
	bigblueterminal? ( ${SRC_BASE}/BigBlueTerminal.tar.xz -> BigBlueTerminal-${PV}.tar.xz )
	bitstreamverasansmono? ( ${SRC_BASE}/BitstreamVeraSansMono.tar.xz -> BitstreamVeraSansMono-${PV}.tar.xz )
	cascadiacode? ( ${SRC_BASE}/CascadiaCode.tar.xz -> CascadiaCode-${PV}.tar.xz )
	cascadiamono? ( ${SRC_BASE}/CascadiaMono.tar.xz -> CascadiaMono-${PV}.tar.xz )
	codenewroman? ( ${SRC_BASE}/CodeNewRoman.tar.xz -> CodeNewRoman-${PV}.tar.xz )
	comicshannsmono? ( ${SRC_BASE}/ComicShannsMono.tar.xz -> ComicShannsMono-${PV}.tar.xz )
	commitmono? ( ${SRC_BASE}/CommitMono.tar.xz -> CommitMono-${PV}.tar.xz )
	cousine? ( ${SRC_BASE}/Cousine.tar.xz -> Cousine-${PV}.tar.xz )
	d2coding? ( ${SRC_BASE}/D2Coding.tar.xz -> D2Coding-${PV}.tar.xz )
	daddytimemono? ( ${SRC_BASE}/DaddyTimeMono.tar.xz -> DaddyTimeMono-${PV}.tar.xz )
	dejavusansmono? ( ${SRC_BASE}/DejaVuSansMono.tar.xz -> DejaVuSansMono-${PV}.tar.xz )
	departuremono? ( ${SRC_BASE}/DepartureMono.tar.xz -> DepartureMono-${PV}.tar.xz )
	droidsansmono? ( ${SRC_BASE}/DroidSansMono.tar.xz -> DroidSansMono-${PV}.tar.xz )
	envycoder? ( ${SRC_BASE}/EnvyCodeR.tar.xz -> EnvyCodeR-${PV}.tar.xz )
	fantasquesansmono? ( ${SRC_BASE}/FantasqueSansMono.tar.xz -> FantasqueSansMono-${PV}.tar.xz )
	firacode? ( ${SRC_BASE}/FiraCode.tar.xz -> FiraCode-${PV}.tar.xz )
	firamono? ( ${SRC_BASE}/FiraMono.tar.xz -> FiraMono-${PV}.tar.xz )
	geistmono? ( ${SRC_BASE}/GeistMono.tar.xz -> GeistMono-${PV}.tar.xz )
	gomono? ( ${SRC_BASE}/Go-Mono.tar.xz -> Go-Mono-${PV}.tar.xz )
	gohu? ( ${SRC_BASE}/Gohu.tar.xz -> Gohu-${PV}.tar.xz )
	hack? ( ${SRC_BASE}/Hack.tar.xz -> Hack-${PV}.tar.xz )
	hasklig? ( ${SRC_BASE}/Hasklig.tar.xz -> Hasklig-${PV}.tar.xz )
	heavydata? ( ${SRC_BASE}/HeavyData.tar.xz -> HeavyData-${PV}.tar.xz )
	hermit? ( ${SRC_BASE}/Hermit.tar.xz -> Hermit-${PV}.tar.xz )
	iawriter? ( ${SRC_BASE}/iA-Writer.tar.xz -> iA-Writer-${PV}.tar.xz )
	ibmplexmono? ( ${SRC_BASE}/IBMPlexMono.tar.xz -> IBMPlexMono-${PV}.tar.xz )
	inconsolata? ( ${SRC_BASE}/Inconsolata.tar.xz -> Inconsolata-${PV}.tar.xz )
	inconsolatago? ( ${SRC_BASE}/InconsolataGo.tar.xz -> InconsolataGo-${PV}.tar.xz )
	inconsolatalgc? ( ${SRC_BASE}/InconsolataLGC.tar.xz -> InconsolataLGC-${PV}.tar.xz )
	intelonemono? ( ${SRC_BASE}/IntelOneMono.tar.xz -> IntelOneMono-${PV}.tar.xz )
	iosevka? ( ${SRC_BASE}/Iosevka.tar.xz -> Iosevka-${PV}.tar.xz )
	iosevkaterm? ( ${SRC_BASE}/IosevkaTerm.tar.xz -> IosevkaTerm-${PV}.tar.xz )
	iosevkatermslab? ( ${SRC_BASE}/IosevkaTermSlab.tar.xz -> IosevkaTermSlab-${PV}.tar.xz )
	jetbrainsmono? ( ${SRC_BASE}/JetBrainsMono.tar.xz -> JetBrainsMono-${PV}.tar.xz )
	lekton? ( ${SRC_BASE}/Lekton.tar.xz -> Lekton-${PV}.tar.xz )
	liberationmono? ( ${SRC_BASE}/LiberationMono.tar.xz -> LiberationMono-${PV}.tar.xz )
	lilex? ( ${SRC_BASE}/Lilex.tar.xz -> Lilex-${PV}.tar.xz )
	martianmono? ( ${SRC_BASE}/MartianMono.tar.xz -> MartianMono-${PV}.tar.xz )
	meslo? ( ${SRC_BASE}/Meslo.tar.xz -> Meslo-${PV}.tar.xz )
	monaspace? ( ${SRC_BASE}/Monaspace.tar.xz -> Monaspace-${PV}.tar.xz )
	monofur? ( ${SRC_BASE}/Monofur.tar.xz -> Monofur-${PV}.tar.xz )
	monoid? ( ${SRC_BASE}/Monoid.tar.xz -> Monoid-${PV}.tar.xz )
	mononoki? ( ${SRC_BASE}/Mononoki.tar.xz -> Mononoki-${PV}.tar.xz )
	mplus? ( ${SRC_BASE}/MPlus.tar.xz -> MPlus-${PV}.tar.xz )
	nerdfontssymbolsonly? ( ${SRC_BASE}/NerdFontsSymbolsOnly.tar.xz -> NerdFontsSymbolsOnly-${PV}.tar.xz )
	noto? ( ${SRC_BASE}/Noto.tar.xz -> Noto-${PV}.tar.xz )
	opendyslexic? ( ${SRC_BASE}/OpenDyslexic.tar.xz -> OpenDyslexic-${PV}.tar.xz )
	overpass? ( ${SRC_BASE}/Overpass.tar.xz -> Overpass-${PV}.tar.xz )
	profont? ( ${SRC_BASE}/ProFont.tar.xz -> ProFont-${PV}.tar.xz )
	proggyclean? ( ${SRC_BASE}/ProggyClean.tar.xz -> ProggyClean-${PV}.tar.xz )
	recursive? ( ${SRC_BASE}/Recursive.tar.xz -> Recursive-${PV}.tar.xz )
	robotomono? ( ${SRC_BASE}/RobotoMono.tar.xz -> RobotoMono-${PV}.tar.xz )
	sharetechmono? ( ${SRC_BASE}/ShareTechMono.tar.xz -> ShareTechMono-${PV}.tar.xz )
	sourcecodepro? ( ${SRC_BASE}/SourceCodePro.tar.xz -> SourceCodePro-${PV}.tar.xz )
	spacemono? ( ${SRC_BASE}/SpaceMono.tar.xz -> SpaceMono-${PV}.tar.xz )
	terminus? ( ${SRC_BASE}/Terminus.tar.xz -> Terminus-${PV}.tar.xz )
	tinos? ( ${SRC_BASE}/Tinos.tar.xz -> Tinos-${PV}.tar.xz )
	ubuntu? ( ${SRC_BASE}/Ubuntu.tar.xz -> Ubuntu-${PV}.tar.xz )
	ubuntumono? ( ${SRC_BASE}/UbuntuMono.tar.xz -> UbuntuMono-${PV}.tar.xz )
	ubuntusans? ( ${SRC_BASE}/UbuntuSans.tar.xz -> UbuntuSans-${PV}.tar.xz )
	victormono? ( ${SRC_BASE}/VictorMono.tar.xz -> VictorMono-${PV}.tar.xz )
	zedmono? ( ${SRC_BASE}/ZedMono.tar.xz -> ZedMono-${PV}.tar.xz )
"

S="${WORKDIR}"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

IUSE_FONTS="0xproto 3270 adwaitamono agave anonymouspro arimo
atkinsonhyperlegiblemono aurulentsansmono bigblueterminal bitstreamverasansmono
cascadiacode cascadiamono codenewroman comicshannsmono commitmono cousine
d2coding daddytimemono dejavusansmono departuremono droidsansmono envycoder
fantasquesansmono firacode firamono geistmono gomono gohu hack hasklig
heavydata hermit iawriter ibmplexmono inconsolata inconsolatago inconsolatalgc
intelonemono iosevka iosevkaterm iosevkatermslab jetbrainsmono lekton
liberationmono lilex martianmono meslo monaspace monofur monoid mononoki mplus
nerdfontssymbolsonly noto opendyslexic overpass profont proggyclean recursive
robotomono sharetechmono sourcecodepro spacemono terminus tinos ubuntu
ubuntumono ubuntusans victormono zedmono"
IUSE="${IUSE_FONTS} +nerdfontssymbolsonly"
REQUIRED_USE="|| ( ${IUSE_FONTS} )"

FONT_SUFFIX=""

src_install() {
	for suffix in ttf otf; do
		if nonfatal compgen -G "*.${suffix}" > /dev/null; then
			FONT_SUFFIX+=" ${suffix}"
		fi
	done

	font_src_install
}
