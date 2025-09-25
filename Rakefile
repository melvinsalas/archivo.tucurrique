require 'fileutils'
require 'open-uri'
require 'tmpdir'
require 'json'

PDFJS_VERSION_FILE = '.pdfjs-version'
PDFJS_DEFAULT_VERSION = '3.11.174'
PDFJS_VENDOR_DIR = File.join('assets', 'vendor', 'pdfjs')

def fetch_latest_pdfjs_version
  url = 'https://api.github.com/repos/mozilla/pdf.js/releases/latest'
  begin
    json = URI.open(url, 'User-Agent' => 'pdfjs-rake-task').read
    data = JSON.parse(json)
    tag = data['tag_name'] || ''
    ver = tag.sub(/^v/i, '')
    return ver unless ver.empty?
  rescue => e
    warn "Could not fetch latest PDF.js version: #{e.class}: #{e.message}"
  end
  PDFJS_DEFAULT_VERSION
end

def desired_pdfjs_version
  raw = if File.exist?(PDFJS_VERSION_FILE)
    File.read(PDFJS_VERSION_FILE).strip
  else
    PDFJS_DEFAULT_VERSION
  end
  return fetch_latest_pdfjs_version if raw.empty? || raw.downcase == 'latest'
  raw.sub(/^v/i, '')
end

def installed_pdfjs_version
  ver_path = File.join(PDFJS_VENDOR_DIR, '.version')
  File.exist?(ver_path) ? File.read(ver_path).strip : nil
end

def install_pdfjs!(version)
  FileUtils.mkdir_p(PDFJS_VENDOR_DIR)
  zipname = "pdfjs-#{version}-dist.zip"
  url = "https://github.com/mozilla/pdf.js/releases/download/v#{version}/#{zipname}"
  tmpzip = File.join(Dir.tmpdir, zipname)

  puts "Downloading #{url}..."
  URI.open(url, 'rb') do |r|
    File.open(tmpzip, 'wb') { |f| IO.copy_stream(r, f) }
  end

  puts "Extracting to #{PDFJS_VENDOR_DIR}..."
  FileUtils.rm_rf(PDFJS_VENDOR_DIR)
  FileUtils.mkdir_p(PDFJS_VENDOR_DIR)
  system('unzip', '-q', '-o', tmpzip, '-d', PDFJS_VENDOR_DIR) or abort('unzip failed')

  # Mark installed version
  File.write(File.join(PDFJS_VENDOR_DIR, '.version'), version)
  puts "PDF.js v#{version} installed."
end

namespace :pdfjs do
  desc 'Install a specific PDF.js version: rake pdfjs:install[3.11.174]'
  task :install, [:version] do |_, args|
    version = args[:version] || desired_pdfjs_version
    install_pdfjs!(version)
  end

  desc 'Ensure desired PDF.js version is installed'
  task :ensure do
    desired = desired_pdfjs_version
    installed = installed_pdfjs_version
    if installed != desired || !File.directory?(File.join(PDFJS_VENDOR_DIR, 'web'))
      puts "Installing PDF.js (desired=#{desired}, installed=#{installed || 'none'})"
      install_pdfjs!(desired)
    else
      puts "PDF.js v#{installed} already present."
    end
  end
end

desc 'Build site (ensures PDF.js)'
task :build => 'pdfjs:ensure' do
  exec 'bundle', 'exec', 'jekyll', 'build'
end

desc 'Serve site (ensures PDF.js)'
task :serve => 'pdfjs:ensure' do
  exec 'bundle', 'exec', 'jekyll', 'serve'
end

task :default => :build
