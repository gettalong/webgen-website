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
