class Qt52 < Formula
  desc "Cross-platform application and UI framework"
  homepage "https://www.qt.io/"
  url "https://download.qt.io/official_releases/qt/5.2/5.2.1/single/qt-everywhere-opensource-src-5.2.1.tar.gz"
  sha256 "84e924181d4ad6db00239d87250cc89868484a14841f77fb85ab1f1dbdcd7da1"

  bottle do
    revision 1
    sha256 "daaaa01ffcd89cf498b54b4e505e8e8271a636d38610cd636ae605ebd80bc47f" => :mavericks
  end

  keg_only "Qt 5 conflicts Qt 4 (which is currently much more widely used)."

  option :universal
  option "with-docs", "Build documentation"
  option "with-developer", "Build and link with developer options"

  deprecated_option "developer" => "with-developer"
  deprecated_option "with-d-bus" => "with-dbus"

  depends_on "pkg-config" => :build
  depends_on :xcode => :build
  depends_on MaximumMacOSRequirement => :mavericks
  depends_on "dbus" => :optional
  depends_on "mysql" => :optional

  # Fails to build miserably on Xcodes which contain the 10.10 SDK
  patch :DATA if MacOS.version >= :mavericks

  def install
    # fixed hardcoded link to plugin dir: https://bugreports.qt.io/browse/QTBUG-29188
    inreplace "qttools/src/macdeployqt/macdeployqt/main.cpp", "deploymentInfo.pluginPath = \"/Developer/Applications/Qt/plugins\";",
              "deploymentInfo.pluginPath = \"#{prefix}/plugins\";"

    ENV.universal_binary if build.universal?
    args = ["-prefix", prefix,
            "-system-zlib",
            "-qt-libpng", "-qt-libjpeg",
            "-confirm-license", "-opensource",
            "-nomake", "examples",
            "-nomake", "tests",
            "-release"]

    # https://bugreports.qt.io/browse/QTBUG-34382
    args << "-no-xcb"

    args << "-plugin-sql-mysql" if build.with? "mysql"

    if build.with? "dbus"
      dbus_opt = Formula["dbus"].opt_prefix
      args << "-I#{dbus_opt}/lib/dbus-1.0/include"
      args << "-I#{dbus_opt}/include/dbus-1.0"
      args << "-L#{dbus_opt}/lib"
      args << "-ldbus-1"
      args << "-dbus-linked"
    end

    if MacOS.prefer_64_bit? || build.universal?
      args << "-arch" << "x86_64"
    end

    if !MacOS.prefer_64_bit? || build.universal?
      args << "-arch" << "x86"
    end

    args << "-developer-build" if build.with? "developer"

    system "./configure", *args
    system "make"
    ENV.j1
    system "make", "install"

    if build.with? "docs"
      system "make", "docs"
      system "make", "install_docs"
    end

    # Some config scripts will only find Qt in a "Frameworks" folder
    frameworks.install_symlink Dir["#{lib}/*.framework"]

    # The pkg-config files installed suggest that headers can be found in the
    # `include` directory. Make this so by creating symlinks from `include` to
    # the Frameworks' Headers folders.
    Pathname.glob("#{lib}/*.framework/Headers") do |path|
      include.install_symlink path => path.parent.basename(".framework")
    end

    # configure saved the PKG_CONFIG_LIBDIR set up by superenv; remove it
    # see: https://github.com/Homebrew/homebrew/issues/27184
    inreplace prefix/"mkspecs/qconfig.pri", /\n\n# pkgconfig/, ""
    inreplace prefix/"mkspecs/qconfig.pri", /\nPKG_CONFIG_.*=.*$/, ""

    Pathname.glob("#{bin}/*.app") { |app| mv app, prefix }
  end

  def caveats; <<-EOS.undent
    We agreed to the Qt opensource license for you.
    If this is unacceptable you should uninstall.
    EOS
  end

  test do
    system "#{bin}/qmake", "-project"
  end
end

__END__
diff --git a/qtmultimedia/src/plugins/avfoundation/mediaplayer/avfmediaplayersession.mm b/qtmultimedia/src/plugins/avfoundation/mediaplayer/avfmediaplayersession.mm
index a73974c..d3f3eae 100644
--- a/qtmultimedia/src/plugins/avfoundation/mediaplayer/avfmediaplayersession.mm
+++ b/qtmultimedia/src/plugins/avfoundation/mediaplayer/avfmediaplayersession.mm
@@ -322,7 +322,7 @@ static void *AVFMediaPlayerSessionObserverCurrentItemObservationContext = &AVFMe
     //AVPlayerItem "status" property value observer.
     if (context == AVFMediaPlayerSessionObserverStatusObservationContext)
     {
-        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
+        AVPlayerStatus status = (AVPlayerStatus)[[change objectForKey:NSKeyValueChangeNewKey] integerValue];
         switch (status)
         {
             //Indicates that the status of the player is not yet known because
diff --git a/qtbase/src/plugins/platforms/cocoa/qcocoaapplicationdelegate.mm b/qtbase/src/plugins/platforms/cocoa/qcocoaapplicationdelegate.mm
index f841184..548c6a2 100644
--- a/qtbase/src/plugins/platforms/cocoa/qcocoaapplicationdelegate.mm
+++ b/qtbase/src/plugins/platforms/cocoa/qcocoaapplicationdelegate.mm
@@ -124,7 +124,7 @@ static void cleanupCocoaApplicationDelegate()
     [dockMenu release];
     [qtMenuLoader release];
     if (reflectionDelegate) {
-        [NSApp setDelegate:reflectionDelegate];
+        [[NSApplication sharedApplication] setDelegate:reflectionDelegate];
         [reflectionDelegate release];
     }
     [[NSNotificationCenter defaultCenter] removeObserver:self];
diff --git a/qtbase/src/plugins/platforms/cocoa/qcocoamenuloader.mm b/qtbase/src/plugins/platforms/cocoa/qcocoamenuloader.mm
index 60bc3b5..9340e94 100644
--- a/qtbase/src/plugins/platforms/cocoa/qcocoamenuloader.mm
+++ b/qtbase/src/plugins/platforms/cocoa/qcocoamenuloader.mm
@@ -174,7 +174,7 @@ QT_END_NAMESPACE
 - (void)removeActionsFromAppMenu
 {
     for (NSMenuItem *item in [appMenu itemArray])
-        [item setTag:nil];
+        [item setTag:0];
 }

 - (void)dealloc
--
1.7.1
