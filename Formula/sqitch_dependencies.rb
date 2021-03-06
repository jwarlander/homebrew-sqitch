require 'formula'

class SqitchDependencies < Formula
  version    '0.9997'
  url        "https://fastapi.metacpan.org/v1/source/DWHEELER/App-Sqitch-#{stable.version}/META.json", :using => :nounzip
  sha256     '7bf29b11920c2ce9747bcd195bd6486d8ba4944bc46abb55a736c987ec20b9a3'
  homepage   'http://sqitch.org/'
  depends_on 'cpanminus'
  conflicts_with 'sqitch_maint_depends',
    :because => "sqitch_dependencies and sqitch_maint_depends install the same plugins."

  def install
    arch  = %x(perl -MConfig -E 'print $Config{archname}')
    plib  = "#{HOMEBREW_PREFIX}/lib/perl5"
    ENV['PERL5LIB'] = "#{plib}:#{plib}/#{arch}:#{lib}:#{lib}/#{arch}"
    ENV.remove_from_cflags(/-march=\w+/)
    ENV.remove_from_cflags(/-msse\d?/)

    open 'META.json' do |f|
      JSON.parse(f.read)['prereqs'].each do |mode, prereqs|
        next if ['develop', 'test'].include? mode
        prereqs.each do |time, list|
          list.each do |pkg, version|
            next if pkg == 'perl'
            system "cpanm --local-lib '#{prefix}' --notest #{pkg}"
          end
        end
      end
    end

    # Remove perllocal.pod, since it just gets in the way of other modules.
    rm "#{prefix}/lib/perl5/#{arch}/perllocal.pod", :force => true
  end
end
