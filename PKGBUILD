
# Contributor: chenxing <cxcxcxcx AT gmail DOT com>
# Contributor: Michael Burkhard <Michael DOT Burkhard AT web DOT de>
# Contributor: alexmo82 <25396682 AT live DOT it>
# Maintainer: jooch <jooch AT gmx DOT com>

pkgname=freefilesync
pkgver=10.9
pkgrel=1
pkgdesc="Backup software to synchronize files and folders"
arch=('i686' 'x86_64')
url="http://www.freefilesync.org/"
license=('GPLv3')
depends=(wxgtk webkit2gtk boost-libs)
makedepends=(boost)
source=(
	"FreeFileSync_${pkgver}_Source.zip::https://www.freefilesync.org/download_redirect.php?file=FreeFileSync_${pkgver}_Source.zip"		#ffs
	revert_resources_path.patch
	revert_xdg_config_path.patch
	FreeFileSync.desktop
	ffsicon.png
	RealTimeSync.desktop
	rtsicon.png
	)

sha256sums=('221b905528f8800468f2f1edc33fbaa2ff0f4b6d5a4966fa20eafc18dadac3b0'
            '052ef5bf5eb11730499f4b81cd7e70f990fff3cfcc2f7059b84981e7ededc361'
            'fef8aa099a27c277b76f1229651ed2324355528482c8f115e09c39269bbf4bdd'
            'b381bb9dbda25c3c08a67f18072a2761abe34339ddf3318e1758eb7c349f1a3b'
            '31df3fa1f1310de14bbd379f891d4f8ed2df5b0d68913eb52c88b3be682933fb'
            '1502efdbf1638856a18ab9916e0431bf6a53471792cb2daa380345bac33f67c4'
            'f28042587dbe99cf5d6bef2c1be4b026488e418e4ba8332b3016d246b7053a4e')
	 
DLAGENTS=('https::/usr/bin/curl -fLC - --retry 3 --retry-delay 3 -A Mozilla -o %o %u')

prepare() {
# wxgtk < 3.1.0
    sed -i 's/m_listBoxHistory->GetTopItem()/0/g'		FreeFileSync/Source/ui/main_dlg.cpp
    # Revert to classic config path
    patch --binary -p1 -i revert_xdg_config_path.patch

# Revert change to resources path of portable version
    patch --binary -p1 -i revert_resources_path.patch

# gcc 6.3.1
    sed -i 's!static_assert!//static_assert!'			zen/scope_guard.h

# warn_static(string)
    sed -i 's!-O3 -DN!-D"warn_static(arg)= " -O3 -DN!'		FreeFileSync/Source/Makefile
    sed -i 's!-O3 -DN!-D"warn_static(arg)= " -O3 -DN!'		FreeFileSync/Source/RealTimeSync/Makefile

# linker error
    # sed -i 's#inline##g' FreeFileSync/Source/ui/version_check_impl.h

# remove architecture suffix from filenames of binaries
    sed -i 's/EXENAME = FreeFileSync_$(shell arch)/EXENAME = FreeFileSync/' FreeFileSync/Source/Makefile
    sed -i 's/EXENAME = RealTimeSync_$(shell arch)/EXENAME = RealTimeSync/' FreeFileSync/Source/RealTimeSync/Makefile

# install error
    cp ${srcdir}/Changelog.txt ${srcdir}/FreeFileSync/Build

# edit lines to remove functions that require wxgtk 3.1.x  
    sed -e 's:m_textCtrlOfflineActivationKey->ForceUpper:// &:g' -i 'FreeFileSync/Source/ui/small_dlgs.cpp'
    sed -e 's:const double scrollSpeed =:& 6; //:g' -i 'wx+/grid.cpp'

# add '-lz' back into LINKFLAGS
    sed -i '/pie/ s/-pthread/-lz -pthread/' FreeFileSync/Source/Makefile
    sed -i '/pie/ s/-pthread/-lz -pthread/' FreeFileSync/Source/RealTimeSync/Makefile
    
# file not found error
	sed -i '/\t"..\/Build\/User Manual.pdf" \\/d' FreeFileSync/Source/Makefile

# inlining of constants not present in libssh2's distributed headers
    sed -i 's/MAX_SFTP_READ_SIZE/30000/g' FreeFileSync/Source/fs/sftp.cpp
    sed -i 's/MAX_SFTP_OUTGOING_SIZE/30000/g' FreeFileSync/Source/fs/sftp.cpp
}

build() {
### speed up compile on multithread machines
    MAKEFLAGS="-j$(nproc)"

### just in case of compile errors
    VER=`g++ -dumpversion`
    MAC=`g++ -dumpmachine`
    echo "compiler g++ $VER $MAC"

### FFS
    mkdir -p "${srcdir}/FreeFileSync/Build/Bin"
    cd ${srcdir}/FreeFileSync/Source
    make

### RTS
    cd RealTimeSync
    make
}

package() {
    bindir="${pkgdir}/usr/bin"
    appsharedir="${pkgdir}/usr/share/FreeFileSync"
    appdocdir="${pkgdir}/usr/share/doc/FreeFileSync"

    cd "${srcdir}/FreeFileSync/Source"
    install -t "${bindir}" -D ../Build/Bin/FreeFileSync ../Build/Bin/RealTimeSync
    install -t "${appsharedir}" -D -m644 \
        ../Build/ding.wav \
        ../Build/gong.wav \
        ../Build/harp.wav \
        ../Build/Resources.zip \
        ../Build/styles.gtk_rc
    install -t "${appsharedir}/Languages" -D -m644 ../Build/Languages/*.lng
    install -d "${appdocdir}"
    gzip < ../../Changelog.txt > "${appdocdir}/CHANGELOG.gz"

    cd "${srcdir}"
    # TODO: extract from zip
    install -Dm644 FreeFileSync.desktop $pkgdir/usr/share/applications/FreeFileSync.desktop
    install -Dm644 ffsicon.png $pkgdir/usr/share/pixmaps/ffsicon.png
    install -Dm644 RealTimeSync.desktop $pkgdir/usr/share/applications/RealTimeSync.desktop
    install -Dm644 rtsicon.png $pkgdir/usr/share/pixmaps/rtsicon.png
}
