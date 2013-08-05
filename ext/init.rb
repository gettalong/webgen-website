load('zurb_foundation')
load('font_awesome')

require_relative('bundle_infos')
website.ext.context_modules << BundleInfos

require_relative('kramdown_adaptions')

website.blackboard.add_listener(:website_generated) do
  ignored = %w[content_processor.glossary source.stacked tag.r tag.default tag.describe_ext
               task task.create_bundle task.create_website task.generate_website bundle_infos]

  doc_pages = []
  nodes = website.ext.node_finder.find({:alcn => "/documentation/reference/extensions/**/*.html", :flatten => true,
                                         :not => {:alcn => '/**/index.en.html'}, :lang => 'en'},
                                       website.tree.root)
  website.ext.bundle_infos.extensions.each do |name, infos|
    alcn = '/documentation/reference/extensions/' << name.sub(/\./, '/') << ".en.html"
    next if ignored.include?(name.to_s)
    node = nodes.find {|n| n.alcn == alcn}
    if !node
      website.logger.warn { "No documentation for extension '#{name}'" }
    elsif node['title'] != name
      website.logger.warn { "Node title for documentation of extension '#{name}' not correct" }
    end
    nodes.delete(node) if node
  end

  if !nodes.empty?
    nodes = nodes.map do |n|
      n.alcn.sub(/\/documentation\/reference\/extensions\//, '').sub(/\.html$/, '')
    end.join(', ')
    website.logger.warn { "Documentation pages found for unknown extensions: #{nodes}" }
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
link_defs['destinations'] = ['/documentation/reference/extensions/destination/',
                             'Information about and list of destination extensions']
link_defs['path handlers'] = ['/documentation/reference/extensions/path_handler/',
                              'Information about and list of path handlers']
link_defs['source extension'] = ['/documentation/reference/extensions/source/',
                                 'Information about and list of source extensions']
link_defs['tags'] = ['/documentation/reference/extensions/tag/',
                     'Information about and list of webgen tags']
link_defs['node finder'] = ['/documentation/reference/extensions/node_finder.html',
                            website.ext.bundle_infos.extensions['node_finder']['summary'].tr("\n", ' ')]
link_defs['webgen page format'] = ['/documentation/reference/webgen_page_format.html',
                                   'Information about the custom file format used by webgen']
link_defs['yaml'] = ['/documentation/reference/yaml.html',
                     'Information about the YAML markup language']

website.ext.bundle_infos.options.each do |name, infos|
  alcn = '/documentation/reference/configuration_options.en.html#' << name.tr('_.', '')
  link_defs["#{name} configuration option"] = link_defs[name] = [alcn, infos['summary'][/\A.*?(\.|\Z)/m]]
end


########################################################################
# extension documentation helpers

option('tag.describe_ext.names', '')
website.ext.tag.register('describe_ext', config_prefix: 'tag.describe_ext', :mandatory => ['names']) do |tag, body, context|
  result = "<dl>"
  context[:config]['tag.describe_ext.names'].map do |ext|
    if ext.include?('*')
      context.ws_extensions.keys.select {|k| File.fnmatch(ext, k)}.sort
    else
      ext
    end
  end.flatten.each do |ext|
    ext_path = "#{ext.tr('.', '/')}.html"
    if n = context.website.tree['/documentation/reference/extensions/'].resolve(ext_path, context.node.lang, true)
      summary = context.ext_info(ext)['summary']
      website.cache[:referenced_extensions] << ext
      result << "<dt><h5 id=\"#{ext}\">#{context.dest_node.link_to(n)}</h5></dt><dd>#{ERB::Util.h(summary)}</dd>"
    end
  end
  result << "</dl>"
end

website.blackboard.add_listener(:website_initialized) do
  require 'set'
  website.cache[:referenced_extensions] ||= []
end

website.blackboard.add_listener(:website_generated) do
  excluded = %w[source.stacked task task.create_bundle task.create_website task.generate_website bundle_infos]
  website.cache[:referenced_extensions].uniq!
  (website.ext.bundle_infos.extensions.keys - website.cache[:referenced_extensions] - excluded).each do |ext|
    website.logger.error { "Missing link for extension '#{ext}'"}
  end
end


########################################################################
# config option documentation helpers

ignore_options = ['tag.describe_ext.names']

# Check if there are fragment nodes for all configuration options
website.blackboard.add_listener(:after_node_written) do |node|
  next unless node.cn == 'configuration_options.html'

  website.config.options.each do |name, option|
    next if ignore_options.include?(name)

    alcn = node.alcn + '#' + name.tr('_.', '')
    if !website.tree.resolve_node(alcn, node.lang)
      website.ext.item_tracker.add(node, :missing_node, alcn, node.lang)
      website.logger.error { "Missing documentation for configuration option '#{name}'"}
    end
  end
end


########################################################################
# meta information keys documentation helpers

# Add link definitions for all meta information keys
website.blackboard.add_listener(:website_initialized) do
  mi = website.ext.source.paths.find {|path| path == '/documentation/reference/meta_information_keys.page'}.
    data.scan(/^###\s*(\S+)\s*$/)

  mi.each do |name|
    name = name.shift
    alcn = '/documentation/reference/meta_information_keys.en.html#' << name.tr('_.', '')
    link_defs["#{name} meta information"] = [alcn]
  end

end


########################################################################
# glossary: link definitions and fragment nodes

# Add link definitions for all glossary items
website.blackboard.add_listener(:website_initialized) do
  items = website.ext.source.paths.find {|path| path == '/documentation/reference/glossary.page'}.
    data.scan(/^(.*?)\n\n:/)

  items.each do |item|
    item = item.shift
    alcn = '/documentation/reference/glossary.en.html#' << item.tr(' ', '-')
    link_defs["g:#{item}"] = [alcn, "Glossary information about #{item}"]
  end
end

# Add special content processor for creating fragment nodes for the glossary pages
website.ext.content_processor.register('glossary') do |context|
  si = 500
  context.content.gsub!(/<dt>(.*?)<\/dt>/) do |data|
    item = $1
    id = item.tr(' ', '-')

    path = Webgen::Path.new(context.content_node.alcn + '#' + id)
    path['handler'] = 'copy'
    path['pipeline'] = []
    path['no_output'] = true
    path['title'] = item
    path['sort_info'] = si = si.succ
    context.website.ext.path_handler.create_secondary_nodes(path, '', context.content_node.alcn)

    "<dt id=\"#{id}\">#{item}</dt>"
  end
  context
end

########################################################################
# auto navigation links

website.blackboard.add_listener(:after_tree_populated, 'auto_nav_links', :before => 'item_tracker') do
  doc_nodes = website.ext.node_finder.find('auto_nav_links', website.tree.root).flatten

  doc_nodes.map! do |node|
    if node.is_directory?
      node.proxy_node
    else
      node
    end
  end

  doc_nodes.each_with_index do |node, index|
    node.meta_info['link'] ||= {}
    node.meta_info['link']['prev'] = doc_nodes[index-1].alcn if index != 0
    node.meta_info['link']['next'] = doc_nodes[index+1].alcn if index != doc_nodes.length - 1
  end
end
