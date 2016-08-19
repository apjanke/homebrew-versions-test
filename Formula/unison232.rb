class Unison232 < Formula
  desc "File synchronizer"
  homepage "http://www.cis.upenn.edu/~bcpierce/unison/"
  url "http://www.seas.upenn.edu/~bcpierce/unison//download/releases/unison-2.32.52/unison-2.32.52.tar.gz"
  sha256 "1542e5d4ad03e928260e061a8ff9d5e0bca3282481ed8bec5552de17a0270485"

  bottle do
    cellar :any
    sha256 "0b3ec935ba0df5e9200d3a4b1059798ff841a07d4a38187b381abe5f0331066e" => :yosemite
    sha256 "6cab7b73547dcd37dc18a6fdc9fb3beef5366990645eb60683afdad5ff93b3c6" => :mavericks
    sha256 "de95b7deddbfe5d84ffa65e202bfd79ff8f8018386ef69f6f60d53ebf20d495f" => :mountain_lion
  end

  depends_on "ocaml"

  # http://tech.groups.yahoo.com/group/unison-users/message/9348
  # required for building 2.32.52 with ocamlc 3.12.x
  # Part 2: Fixes segfault on >= Yosemite
  # http://caml.inria.fr/mantis/view.php?id=6621
  # https://github.com/Homebrew/homebrew/issues/34392
  patch :DATA

  def install
    ENV.j1
    ENV.delete "CFLAGS" # ocamlopt reads CFLAGS but doesn't understand common options
    system "make", "./mkProjectInfo"
    system "make", "UISTYLE=text"
    bin.install "unison"
  end
end

__END__
--- unison-2.32.52/update.mli	2009-05-02 03:31:27.000000000 +0100
+++ unison-2.32.52/update.mli	2011-11-04 20:21:11.000000000 +0000
@@ -1,7 +1,7 @@
 (* Unison file synchronizer: src/update.mli *)
 (* Copyright 1999-2009, Benjamin C. Pierce (see COPYING for details) *)
 
-module NameMap : Map.S with type key = Name.t
+module NameMap : MyMap.S with type key = Name.t
 
 type archive =
     ArchiveDir of Props.t * archive NameMap.t
--- unison-2.32.52/ubase/util.ml.orig	2014-11-27 17:08:07.625677820 +0800
+++ unison-2.32.52/ubase/util.ml	2014-11-27 17:09:07.606361064 +0800
@@ -71,7 +71,7 @@
   if s <> !infos then begin clear_infos (); infos := s; show_infos () end

 let msg f =
-  clear_infos (); Uprintf.eprintf (fun () -> flush stderr; show_infos ()) f
+  clear_infos (); Printf.kfprintf (fun c -> flush c; show_infos ()) stderr f

 let msg : ('a, out_channel, unit) format -> 'a = msg
