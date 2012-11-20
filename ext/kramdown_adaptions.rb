require 'webgen/content_processor/kramdown'

class Webgen::ContentProcessor::Kramdown::CustomHtmlConverter

  def convert_codeblock(el, indent)
    attr = el.attr.dup
    lang = extract_code_language!(attr)
    if lang == 'shell'
      result = el.value.strip
      result.gsub!(/^\$ (.*?)$/) do
        "<span class=\"prompt\">$</span> <kbd>#{$1}</kbd>"
      end
      "#{' '*indent}<pre#{html_attributes(attr)}>#{result}</pre>\n"
    else
      super
    end
  end

end
