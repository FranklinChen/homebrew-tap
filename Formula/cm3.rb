require 'formula'

class Cm3 < Formula
  desc 'Critical Mass Modula-3'
  homepage 'http://modula3.org/'
  version 'd5.10.0'
  url 'https://github.com/modula3/cm3/releases/download/snapshot-darwin-13.4.0-homebrew-0.9.5-2015-05-28/cm3-bin-core-AMD64_DARWIN-d5.10.0-i386-apple-darwin13.4.0-2015-05-28-19-56-33.tgz'
  sha256 '0be8c9bea92500ccf540d8429cccb0b608dbc3962379a3eadcdb846f7621bb53'

  def install
    system './cminstall', prefix

    inreplace bin/'cm3.cfg' do |s|
      s.gsub! 'SL', '"/"'
      s.gsub! 'path()', "\"#{bin}\""
    end

    # Note: the cm3.cfg file has to be in same directory as cm3.
    # Do not install bin/config/ because we edited cm3.cfg to point
    # to it in the Cellar and don't need it in bin.
    bin.install Dir['bin/cm3',
                    'bin/cm3.cfg',
                    'bin/cm3cg',
                    'bin/cm3ide',
                    'bin/m3bundle',
                    'bin/m3cgcat',
                    'bin/m3cggen',
                    'bin/m3sleep']
    share.install prefix/'man'
  end
end
