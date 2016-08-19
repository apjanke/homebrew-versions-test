class Nu0 < Formula
  desc "Object-oriented, Lisp-like programming language"
  homepage "http://programming.nu"
  # Upstream link used previously is dead - Using MacPorts mirror instead.
  url "https://distfiles.macports.org/nu/Nu-0.4.0.tgz"
  sha256 "4fb346c4ce938b987faf4591f7a71b6d482ee622fa597a4572c5d573a6f022d1"

  depends_on "pcre"
  depends_on MaximumMacOSRequirement => :lion

  def install
    ENV["PREFIX"] = prefix

    inreplace "Makefile" do |s|
      cflags = s.get_make_var "CFLAGS"
      s.change_make_var! "CFLAGS", "#{cflags} #{ENV["CPPFLAGS"]}"
    end

    inreplace "Nukefile" do |s|
      case Hardware.cpu_type
      when :intel
        arch = :i386
      when :ppc
        arch = :ppc
      end
      arch = :x86_64 if arch == :i386 && Hardware.is_64_bit?
      s.sub!(/^;;\(set @arch '\("i386"\)\)$/, "(set @arch '(\"#{arch}\"))") unless arch.nil?
      s.gsub!('(SH "sudo ', '(SH "') # don't use sudo to install
      s.gsub!('#{@destdir}/Library/Frameworks', '#{@prefix}/Library/Frameworks')
      s.sub!(/^;; source files$/, <<-EOS.undent)
        ;; source files
        (set @framework_install_path "#{frameworks}")
      EOS
    end

    system "make"
    system "./mininush", "tools/nuke"
    bin.mkpath
    lib.mkpath
    include.mkpath
    system "./mininush", "tools/nuke", "install"
  end

  def caveats
    if installed? && File.exist?(frameworks+"Nu.framework")
      return <<-EOS.undent
        Nu.framework was installed to:
          #{frameworks}/Nu.framework

        You may want to symlink this Framework to a standard OS X location,
        such as:
          ln -s "#{frameworks}/Nu.framework" /Library/Frameworks
      EOS
    end
    nil
  end
end
