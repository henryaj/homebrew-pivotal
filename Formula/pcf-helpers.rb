class PcfHelpers < Formula
  desc "Scripts for making interacting with PCF environments easier"
  homepage "https://github.com/henryaj/homebrew-pivotal"
  version "v0.0.1"
  url "https://github.com/henryaj/homebrew-pivotal/archive/#{version}.tar.gz"
  sha256 "463c765b10958b06a1c407567ab051862fcf312f5f03a214ac7be6b9f341a1a4"

  def install
    bin.install "helpers.rb" => "helpers.rb"
    bin.install "generate_ssh_aliases" => "pcf_generate_ssh_aliases"
    bin.install "target_opsman_bosh" => "pcf_target_bosh"
    bin.install "ssh_opsman_bosh" => "pcf_ssh_bosh"
  end

  def post_install
    ohai "You now have some useful helpers starting with `pcf_` on your PATH. :)"
  end

  test do
    system "#{bin}/pcf_generate_ssh_aliases"
  end
end
