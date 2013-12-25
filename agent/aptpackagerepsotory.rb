require 'net/http'
require 'tempfile'

module MCollective
  module Agent
    class Aptpackagerepsotory<RPC::Agent
      action "update" do
        validate :dist, String
        validate :dist, :shellsafe
        validate :arch, String
        validate :arch, :shellsafe
        tmpfile = get_uri(request[:uri])
        File.rename tmpfile.path "#{package_root}/dists/#{request[:dist]}/main/binary-#{request[:arch]}/"
        fixup_metadata
      end

      def get_uri(url)
        uri = URI.parse(url)
        temp = Tempfile.new('mco-agent-aptpackagerepository')
        Net::HTTP.start(uri.host,uri.port) do |http| 
          http.request_get(uri.path) do |res| 
            res.read_body do |seg|
              temp.write(seg)
              sleep 0.005 # hack
            end
          end
        end
        temp.close
        temp
      end

      def package_root
        '/var/www/packages.lemonparty.goatse.co.uk/htdocs'
      end

      def dists
        {
            :precise => [ :i386, :amd64 ],
            :squeeze => [ :i386 ]
        }
      end

      def gpg_key
        '58E2174D'
      end

      def fixup_metadata
        Dir.chdir(package_root) do
          dists.each do |name, archs|
            archs.each do |arch|
              dir = "dists/#{name.to_s}/main/binary-#{arch.to_s}"
              system("dpkg-scanpackages -m #{dir} /dev/null > #{dir}/Packages")
              system("dpkg-scansources #{dir} /dev/null > #{dir}/Sources")

              system("bzip2 -c9 #{dir}/Packages > #{dir}/Packages.bz2")
              system("gzip -c9  #{dir}/Packages > #{dir}/Packages.gz")
              system("bzip2 -c9 #{dir}/Sources  > #{dir}/Sources.bz2")
              system("gzip -c9  #{dir}/Sources  > #{dir}/Sources.gz")

            end
            File.open("dists/#{name.to_s}/Release", 'w') do |f|
              f.puts "Suite: #{name}"
              f.puts "Codename: #{name}"
              f.puts "Components: main"
              f.puts "Architectures: #{archs.join(' ')}"
              f.puts `apt-ftparchive release dists/#{name.to_s}`
            end
            system("rm -f dists/#{name.to_s}/Release.gpg")
            system("gpg --homedir=/root/.gnupg/ -abs --default-key #{gpg_key} -o dists/#{name.to_s}/Release.gpg dists/#{name.to_s}/Release")
          end

          system("sudo chgrp -R admin *")
          system("sudo chmod -R g+w *")
        end
      end
    end
  end
end

