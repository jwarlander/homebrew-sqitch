require 'formula'

class SqitchMaintDepends < Formula
  version    '0.9997'
  url        "https://fastapi.metacpan.org/v1/source/DWHEELER/App-Sqitch-#{stable.version}/META.json", :using => :nounzip
  sha256     '7bf29b11920c2ce9747bcd195bd6486d8ba4944bc46abb55a736c987ec20b9a3'
  homepage   'http://sqitch.org/'
  depends_on 'cpanminus'
  conflicts_with 'sqitch_dependencies',
    :because => "sqitch_maint_depends and sqitch_dependencies install the same plugins."

  def install
    arch  = %x(perl -MConfig -E 'print $Config{archname}')
    plib  = "#{HOMEBREW_PREFIX}/lib/perl5"
    ENV['PERL5LIB'] = "#{plib}:#{plib}/#{arch}:#{lib}:#{lib}/#{arch}"
    ENV.remove_from_cflags(/-march=\w+/)
    ENV.remove_from_cflags(/-msse\d?/)

    # Install all the testing dependencies
    open 'META.json' do |f|
      Utils::JSON.load(f.read)['prereqs']['test'].each do |time, list|
        list.each do |pkg, version|
          next if pkg == 'perl'
          system "cpanm --local-lib '#{prefix}' --notest #{pkg}"
        end
      end
    end

    # Also need Dist::Zilla and a bunch of plugins.
    system "cpanm --local-lib '#{prefix}' --notest Dist::Zilla"
    %w{AutoPrereqs CheckExtraTests ConfirmRelease ExecDir GatherDir License LocaleTextDomain Manifest ManifestSkip MetaJSON MetaNoIndex MetaResources MetaYAML ModuleBuild Prereqs PruneCruft Readme ShareDir TestRelease UploadToCPAN VersionFromModule}.each do |plugin|
      system "cpanm --local-lib '#{prefix}' --notest Dist::Zilla::Plugin::#{plugin}"
    end

    # Remove perllocal.pod, since it just gets in the way of other modules.
    rm "#{prefix}/lib/perl5/#{arch}/perllocal.pod", :force => true
  end
end
