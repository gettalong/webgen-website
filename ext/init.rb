load('sass_twitter_bootstrap')
load('font_awesome')

require_relative('bundle_infos')
website.ext.context_modules << BundleInfos

require_relative('kramdown_adaptions')

website.blackboard.add_listener(:website_generated) do
  # check if all content processors are documented with correct infos
  nodes = website.ext.node_finder.find({:alcn => '/documentation/reference/content_processor/*.html', :flatten => true,
                                         :not => {:alcn => '/**/index.html'}},
                                       website.tree.root)
  website.ext.content_processor.registered_extensions.each do |name, data|
    node = nodes.find {|n| n.cn == "#{name}.html"}
    if !node
      website.logger.warn { "No documentation for content processor '#{name}'" }
    end
    if node && node['title'] != "content_processor.#{name}"
      website.logger.warn { "Node title for documentation of content processor '#{name}' not correct" }
    end
    nodes.delete(node) if node
  end

  if !nodes.empty?
    nodes = nodes.map {|n| n.cn.sub(/\.html$/, '') }.join(', ')
    website.logger.warn { "Documentation pages found for unknown content processors: #{nodes}" }
  end
end


ref_links = "\n\n"
website.blackboard.add_listener(:after_tree_populated) do
  BundleInfos.bundles(website).each do |name, infos|
    next unless name.include?('.')
    alcn = '/documentation/reference/' << name.sub(/\./, '/') << ".en.html"
    if !website.tree[alcn]
      website.logger.warn { "No documentation page for '#{name}' at <#{alcn}> found" }
    end
    desc = "'#{infos['summary'].tr("\n", ' ')}'"
    ref_links << "[#{name}]: #{alcn} #{desc}\n"
    name1, name2 = name.split('.')
    ref_links << "[#{name1.tr('_', ' ')} #{name2}]: #{alcn} #{desc}\n"
  end
  ref_links << "\n"
  website.config.options.each do |name, option|
    alcn = '/documentation/reference/config_options.en.html#' << name.tr('_.', '')
    if !website.tree[alcn]
      website.logger.warn { "No documentation page for '#{name}' at <#{alcn}> found" }
    end
    desc = option.description.include?('"') ? '' : " \"#{option.description}\""
    ref_links << "[#{name}]: #{alcn}#{desc}\n"
  end
end

website.ext.content_processor.register('link_defs') do |context|
  context.content << ref_links
  context
end
