load('sass_twitter_bootstrap')
load('font_awesome')

require_relative('bundle_infos')
website.ext.context_modules << BundleInfos

require_relative('kramdown_adaptions')

website.blackboard.add_listener(:website_generated) do
  data = {
    'content_processor' => [],
    'source' => ['stacked'],
    'destination' => [],
    'item_tracker' => [],
    'tag' => ['r', 'default'],
    'task' => [],
    'path_handler' => [],
  }

  data.each do |ext_name, ignored|
    nodes = website.ext.node_finder.find({:alcn => "/documentation/reference/#{ext_name}/*.html", :flatten => true,
                                           :not => {:alcn => '/**/index.html'}, :lang => 'en'},
                                         website.tree.root)
    website.ext.send(ext_name).registered_extensions.each do |name, data|
      next if ignored.include?(name.to_s)
      node = nodes.find {|n| n.lcn == "#{name}.en.html"}
      if !node
        website.logger.warn { "No documentation for #{ext_name} '#{name}'" }
      elsif node['title'] != "#{ext_name}.#{name}"
        website.logger.warn { "Node title for documentation of #{ext_name} '#{name}' not correct" }
      end
      nodes.delete(node) if node
    end
    if !nodes.empty?
      nodes = nodes.map {|n| n.cn.sub(/\.html$/, '') }.join(', ')
      website.logger.warn { "Documentation pages found for unknown #{ext_name}: #{nodes}" }
    end
  end
end

link_defs = website.ext.link_definitions

website.ext.bundle_infos.extensions.each do |name, infos|
  alcn = '/documentation/reference/extensions/' << name.sub(/\./, '/') << ".en.html"
  data = [alcn, infos['summary'].tr("\n", ' ')]
  link_defs["#{name} extension"] = data
  if name.include?('.')
    link_defs[name] = data
    name1, name2 = name.split('.')
    link_defs[name1.tr('_', ' ') + (name2 ? " #{name2}" : '')] = data
  end
end
link_defs['content processors'] = ['/documentation/reference/extensions/content_processor/',
                                   'Information about and list of content processors']
website.config.options.each do |name, option|
  alcn = '/documentation/reference/config_options.en.html#' << name.tr('_.', '')
  link_defs["#{name} configuration option"] = link_defs[name] = [alcn, option.description]
end

website.blackboard.add_listener(:website_generated) do
  next # TODO: renable after most things are done!
  BundleInfos.bundles(website).each do |name, infos|
    next unless name.include?('.')
    alcn = '/documentation/reference/' << name.sub(/\./, '/') << ".en.html"
    if !website.tree[alcn]
      website.logger.warn { "No documentation page for '#{name}' at <#{alcn}> found" }
    end
  end
  website.config.options.each do |name, option|
    alcn = '/documentation/reference/config_options.en.html#' << name.tr('_.', '')
    if !website.tree[alcn]
      website.logger.warn { "No documentation page for '#{name}' at <#{alcn}> found" }
    end
  end
end
