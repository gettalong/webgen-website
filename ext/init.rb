load('sass_twitter_bootstrap')
load('font_awesome')

require_relative('bundle_infos')
website.ext.context_modules << BundleInfos

require_relative('kramdown_adaptions')

website.blackboard.add_listener(:website_generated) do
  data = {
    'content_processor' => ['link_defs'],
    'source' => ['stacked'],
    'destination' => [],
    'item_tracker' => [],
    'tag' => ['r', 'default'],
    'task' => []
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


ref_links = "\n\n"
website.blackboard.add_listener(:after_tree_populated) do
  BundleInfos.bundles(website).each do |name, infos|
    next unless name.include?('.') || %w{node_finder}.include?(name)
    alcn = '/documentation/reference/' << name.sub(/\./, '/') << ".en.html"
    desc = "'#{infos['summary'].tr("\n", ' ')}'"
    ref_links << "[#{name}]: #{alcn} #{desc}\n"
    name1, name2 = name.split('.')
    ref_links << "[#{name1.tr('_', ' ')}#{name2 ? " #{name2}" : ''}]: #{alcn} #{desc}\n"
  end
  ref_links << "\n"
  website.config.options.each do |name, option|
    alcn = '/documentation/reference/config_options.en.html#' << name.tr('_.', '')
    desc = option.description.include?('"') ? '' : " \"#{option.description}\""
    ref_links << "[#{name}]: #{alcn}#{desc}\n"
    ref_links << "[#{name} configuration option]: #{alcn}#{desc}\n"
  end
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

website.ext.content_processor.register('link_defs') do |context|
  context.content << ref_links
  context
end
