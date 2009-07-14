# Prefer RDiscount because BlueCloth is slow and has problems with Ruby 1.9.
begin
  require 'rdiscount'
  BlueCloth = RDiscount
rescue LoadError => e
  require 'bluecloth'
end
begin
  require 'uv'
rescue LoadError => e
  Uv = nil
end
  
class BlueCloth
  CodeBlockClassNameRegexp = /(?:\s*lang(?:uage)?:\s*(\w+)\s*\n)(.*)/
  def transform_code_blocks( str, rs )
    @log.debug " Transforming code blocks"
    class_name = "javascript_+_prototype"
    str.gsub( CodeBlockRegexp ) do |block|
      codeblock = $1
      remainder = $2
      codeblock = codeblock.sub( CodeBlockClassNameRegexp ) do |b|
        class_name = $1
        $2
      end
      if (Uv)
        res = Uv.parse( outdent(codeblock).strip(), "xhtml", class_name, false, UV_THEME)
        "#{res}\n\n#{remainder}"
      else
        # Generate the codeblock
        %{\n\n<pre><code class="%s">%s\n</code></pre>\n\n%s} %
          [ class_name, encode_code( outdent(codeblock), rs ).rstrip, remainder ]
      end
    end
  end
end