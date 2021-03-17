require 'yaml'
require 'json'
require 'open-uri'

require_relative 'view'

class CaskGenerator

  DOWNLOAD_ENDPOINT = 'https://www.ujam.com/api/delivery/product'
  UPDATE_ENDPOINT = 'https://www.ujam.com/api/delivery/product_update'

  def initialize(resources_dir, templates_dir, output_dir)
    @output_dir = output_dir
    @products = YAML.load_file(File.join(resources_dir, 'products.yaml'))
    @no_downloader_tmpl = File.read(File.join(templates_dir, 'no-downloader.erb'))
    @downloader_tmpl = File.read(File.join(templates_dir, 'downloader.erb'))

  end

  def render
    unless File.writable?(@output_dir)
      raise "Output dir %s is not writeable!" % @output_dir
    else
      puts "Output dir is %s" % @output_dir
    end

    @products.each do |product|

      if product["has_downloader"]
        template = @downloader_tmpl
        # FIXME: Remove the following line once products with downloaders are supported
        raise "Products with downloaders aren't supported yet"
      else
        template = @no_downloader_tmpl
      end

      product["api_sku"] = product["sku"] unless product["api_sku"]
      product["version_with_build_numer"] = get_latest_version(product["api_sku"])
      product["url"] = get_download_url(product["api_sku"])

      puts "%s %s" % [ product["sku"], product["version_with_build_numer"] ]

      view = View.new(product)
      output = view.render(@no_downloader_tmpl)
      output_path = File.join(@output_dir, "%s.rb" % view.cask)
      File.write(output_path, output)
    end

  end

  def test
    @products.each do |product|

      system("brew audit %s --new-cask" % product["cask"])
      unless $?.exitstatus == 0
        raise "Audit for %s has failed" % product["cask"]
      end

      system("brew style %s" % product["cask"])
      unless $?.exitstatus == 0
        raise "Style check for %s has failed" % product["cask"]
      end
    end
  end

  def get_latest_version(sku)
    url = get_update_url(sku)
    res = open(url).read
    o = JSON.parse(res)
    [ o["versionno"], o["version"] ].join(',')
  end

  def get_update_url(api_sku)
    uri = URI(UPDATE_ENDPOINT)
    uri.query = URI.encode_www_form({os: "osx", version: 0, sku: api_sku })
    return uri
  end

  def get_download_url(api_sku)
    uri = URI(DOWNLOAD_ENDPOINT)
    uri.query = URI.encode_www_form({os: "osx", sku: api_sku })
    return uri
  end

end
