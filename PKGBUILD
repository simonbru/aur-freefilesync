
# Contributor: chenxing <cxcxcxcx AT gmail DOT com>
# Contributor: Michael Burkhard <Michael DOT Burkhard AT web DOT de>
# Contributor: alexmo82 <25396682 AT live DOT it>
# Maintainer: jooch <jooch AT gmx DOT com>

pkgname=freefilesync
pkgver=10.13
pkgrel=1
pkgdesc="Backup software to synchronize files and folders"
arch=('i686' 'x86_64')
url="https://www.freefilesync.org"
license=('GPLv3')
depends=(wxgtk webkit2gtk boost-libs)
makedepends=(boost unzip)
source=(
	"FreeFileSync_${pkgver}_Source.zip::${url}/download/FreeFileSync_${pkgver}_Source.zip"		#ffs
	revert_resources_path.patch
	revert_xdg_config_path.patch
	FreeFileSync.desktop
	RealTimeSync.desktop
	)

sha256sums=('6460362e56e846535ffa07eb5e087fac1efa04c34dd8f5c323c570f7e960b72a'
            '052ef5bf5eb11730499f4b81cd7e70f990fff3cfcc2f7059b84981e7ededc361'
            'fef8aa099a27c277b76f1229651ed2324355528482c8f115e09c39269bbf4bdd'
            '590d87707240529ca893199f852143f5d7c7266cb050e37e615900b013ac3d51'
            '82439b4b81b0a72652befad9b9db52ffbc0180f307c92205aa5ab344f9f82830')
	 
DLAGENTS=("https::/usr/bin/curl -fLC - --retry 5 --retry-delay 3 -A Mozilla -o %o %u")

_auth_request="$(\
    echo "Authenticating for download ..." >&2; \
    /usr/bin/curl -fsSL -A Mozilla "$url/cookie/load-consent.php" \
)"

prepare() {
# wxgtk < 3.1.0
    # Revert to classic config path
    patch --binary -p1 -i revert_xdg_config_path.patch

# Revert change to resources path of portable version
    patch --binary -p1 -i revert_resources_path.patch

# edit lines to remove functions that require wxgtk 3.1.x  
    sed -e 's:m_textCtrlOfflineActivationKey->ForceUpper:// &:g' -i 'FreeFileSync/Source/ui/small_dlgs.cpp'
    sed -e 's:const double scrollSpeed =:& 6; //:g' -i 'wx+/grid.cpp'

# libssh2 v1.8.2 does not yet implement LIBSSH2_SFTP_DEFAULT_MODE, revert to previous impl.
    sed -e 's/LIBSSH2_SFTP_DEFAULT_MODE/LIBSSH2_SFTP_S_IRWXU | LIBSSH2_SFTP_S_IRWXG | LIBSSH2_SFTP_S_IRWXO/g' -i 'FreeFileSync/Source/afs/sftp.cpp'

# add '-lz' back into LINKFLAGS
    sed -i '/pie/ s/-pthread/-lz -pthread/' FreeFileSync/Source/Makefile
    sed -i '/pie/ s/-pthread/-lz -pthread/' FreeFileSync/Source/RealTimeSync/Makefile

# inlining of constants not present in libssh2's distributed headers
    sed -i 's/MAX_SFTP_READ_SIZE/30000/g' FreeFileSync/Source/afs/sftp.cpp
    sed -i 's/MAX_SFTP_OUTGOING_SIZE/30000/g' FreeFileSync/Source/afs/sftp.cpp
}

build() {
### speed up compile on multithread machines
    MAKEFLAGS="-j$(nproc)"

### just in case of compile errors
    VER=`g++ -dumpversion`
    MAC=`g++ -dumpmachine`
    echo "compiler g++ $VER $MAC"

### FFS
    cd "${srcdir}/FreeFileSync/Source"
    make EXENAME=FreeFileSync TMP_PATH="${srcdir}/FreeFileSync/tmp_ffs"

### RTS
    cd "${srcdir}/FreeFileSync/Source/RealTimeSync"
    make EXENAME=RealTimeSync TMP_PATH="${srcdir}/FreeFileSync/tmp_rts"
}

package() {
    bindir="${pkgdir}/usr/bin"
    appsharedir="${pkgdir}/usr/share/FreeFileSync"
    appdocdir="${pkgdir}/usr/share/doc/FreeFileSync"

    cd "${srcdir}/FreeFileSync/Build"
    install -t "${bindir}" -Dm755 Bin/FreeFileSync Bin/RealTimeSync
    install -t "${appsharedir}/Misc" -Dm644 Misc/*
    install -t "${appsharedir}/Languages" -Dm644 Languages/*.lng
    install -t "${pkgdir}/usr/share/pixmaps" -Dm644 Misc/FreeFileSync.png Misc/RealTimeSync.png

    cd "${srcdir}"
    install -d "${appdocdir}"
    gzip < Changelog.txt > "${appdocdir}/CHANGELOG.gz"
    install -Dm644 -t "${pkgdir}/usr/share/applications" FreeFileSync.desktop RealTimeSync.desktop
}
