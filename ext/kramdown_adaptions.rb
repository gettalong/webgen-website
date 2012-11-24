require 'webgen/content_processor/kramdown'

class Webgen::ContentProcessor::Kramdown::CustomHtmlConverter

  def convert_codeblock(el, indent)
    attr = el.attr.dup
    lang = extract_code_language!(attr)
    if lang == 'shell'
      result = el.value.strip.lines.map do |line|
        if line =~ /^(\$|C:\\>) (.*)$/
          "<span class=\"prompt\">#{escape_html($1)}</span> <kbd>#{escape_html($2)}</kbd>"
        else
          escape_html(line)
        end
      end.join("\n")
      "#{' '*indent}<pre#{html_attributes(attr)}>#{result}</pre>\n"
    else
      super
    end
  end

end
