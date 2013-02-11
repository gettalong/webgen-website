module BundleInfos

  def ws_extensions
    website.ext.bundle_infos.extensions
  end

  def ws_options
    website.ext.bundle_infos.options
  end

  def ext_info(name)
    ws_extensions[name] || (website.logger.warn("Unknown extension: #{name}"); {})
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

  def item_tracker_info(name)
    name = name.sub(/^item_tracker\./, '')
    data = {}.update(ext_info("item_tracker.#{name}"))
    data[:name] = name
    data
  end

  def path_handler_info(name)
    name = name.sub(/^path_handler\./, '')
    data = {}.update(ext_info("path_handler.#{name}"))
    data[:patterns] = website.ext.path_handler.registered_extensions[name.to_sym].patterns
    data[:mi_patterns] = website.ext.path_handler.instance('meta_info').instance_variable_get(:@paths).
      select {|pattern, mi| Marshal.load(mi)['handler'] == name }.map {|pattern, mi| pattern}
    data[:name] = name
    data
  end

end
