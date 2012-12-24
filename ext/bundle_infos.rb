module BundleInfos

  def self.bundles(website)
    unless defined?(@ext_infos)
      @ext_infos = {}
      website.ext.bundles.each do |bundle, info_file|
        next if info_file.nil?
        infos = YAML.load(File.read(info_file))
        next unless infos['extensions']
        infos['extensions'].each do |n, d|
          d['bundle'] = bundle
          d['author'] ||= infos['author']
        end
        @ext_infos.update(infos['extensions'])
      end
    end
    @ext_infos
  end

  def ext_info(name)
    BundleInfos.bundles(website)[name] || (website.logger.warn("Unknown extension: #{name}"); {})
  end

  def content_processor_info(name)
    name = name.sub(/^content_processor\./, '')
    data = {}.update(ext_info("content_processor.#{name}"))
    data[:type] = (website.ext.content_processor.is_binary?(name) ? :binary : :text)
    data[:extension_map] = website.ext.content_processor.extension_map(name)
    data[:name] = name
    data
  end

  def source_info(name)
    name = name.sub(/^source\./, '')
    data = {}.update(ext_info("source.#{name}"))
    data[:name] = name
    data
  end

  def destination_info(name)
    name = name.sub(/^destination\./, '')
    data = {}.update(ext_info("destination.#{name}"))
    data[:name] = name
    data
  end

  def tag_info(name)
    name = name.sub(/^tag\./, '')
    data = {}.update(ext_info("tag.#{name}"))
    ext_data = website.ext.tag.registered_extensions[name.to_sym]
    data[:mandatory] = ext_data.mandatory
    data[:config_prefix] = ext_data.config_prefix
    data[:names] = website.ext.tag.registered_extensions.select {|n, d| d == ext_data}.map {|n,d| n}
    data
  end

end
