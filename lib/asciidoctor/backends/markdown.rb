class Asciidoctor::BaseTemplate
  def unescape(str)
    str.gsub('***', '**').gsub('&#160;', '&nbsp;').gsub('&#43;', '+').gsub('&#8217;', '\'').
        gsub('&#8230;', '...').gsub('&#8201;&#8212;&#8201;', ' -- ').gsub('&lt;', '<').gsub('&gt;', '>').gsub('&amp;', '&')
  end

  def block_meta
    ''
=begin
    %q{<% unless id.nil? %>[[<%= id %>]]
<% end %><% if attr? :role %>[role="<%= attr :role %>"]
<% end %><% if title? %>.<%= title %>
<% end %>}
=end
  end
end

module Asciidoctor::Markdown
class DocumentTemplate < ::Asciidoctor::BaseTemplate
  BUILTIN_ATTRIBUTES = [
    'asciidoctor',
    'asciidoctor-version',
    'backend',
    'basebackend',
    'backend-asciidoc',
    'basebackend-asciidoc',
    'localdate',
    'localtime',
    'localdatetime',
    'docname',
    'docdate',
    'doctime',
    'docdatetime',
    'docfile',
    'docdir',
    'filetype',
    'outfile',
    'outdir',
    'firstname',
    'lastname',
    'author',
    'authorinitials',
    'email',
    'include-depth',
    'iconsdir',
    'sectids',
    'encoding'
  ]

  def template
    @template ||= @eruby.new <<-EOS
<% if has_header? %># <%= doctitle %>

<% end %><%= content.rstrip %>

    EOS
  end
end

class BlockPreambleTemplate < ::Asciidoctor::BaseTemplate
  def template
    @template ||= @eruby.new <<-EOS
<%= content.rstrip %>

    EOS
  end
end

class SectionTemplate < ::Asciidoctor::BaseTemplate
  def template
    @template ||= @eruby.new <<-EOS
<%= '#' * (@level + 1) %> <%= template.unescape(title) %>

<%= content.rstrip %>

    EOS
  end
end

class BlockParagraphTemplate < ::Asciidoctor::BaseTemplate
  def template
    @template ||= @eruby.new <<-EOS
#{block_meta}<%= template.unescape(content) %>

    EOS
  end
end

class BlockAdmonitionTemplate < ::Asciidoctor::BaseTemplate
  def template
    @template ||= @eruby.new <<-EOS
#{block_meta}<%= (attr :name).upcase %>: <%= content.rstrip %>

    EOS
  end
end

# TODO list continuation lines
class BlockUlistTemplate < ::Asciidoctor::BaseTemplate
  def template
    @template ||= @eruby.new <<-EOS
#{block_meta}<% content.each do |li| %><%= ' ' * (li.level - 1) %>* <%= template.unescape(li.text.gsub(/\n[[:space:]]*\n/, "\n")) %>
<% if li.blocks? %><%= li.content.rstrip %>
<% else %>
<% end %>
<% end %>

    EOS
  end
end

class BlockOlistTemplate < ::Asciidoctor::BaseTemplate
  def template
    @template ||= @eruby.new <<-EOS
#{block_meta}<% content.each_with_index do |li, i| %><%= i + 1 %>. <%= li.text %>
<% end %>

    EOS
  end
end

class BlockColistTemplate < ::Asciidoctor::BaseTemplate
  def template
    @template ||= @eruby.new <<-EOS
#{block_meta}<% content.each_with_index do |li, i| %><%= i + 1 %>. <%= li.text %>
<% end %>

    EOS
  end
end

class BlockDlistTemplate < ::Asciidoctor::BaseTemplate
  def template
    @template ||= @eruby.new <<-EOS
#{block_meta}<% content.each do |dt, dd| %><%= dt.text %><% if !dd.nil? %>
: <%= dd.text.lstrip %>
<% end %><% end %>

    EOS
  end
end

class BlockLiteralTemplate < ::Asciidoctor::BaseTemplate
  def template
    @template ||= @eruby.new <<-EOS
#{block_meta}<%= template.unescape(content.gsub(/^/, '    ')) %>

    EOS
  end
end

class BlockListingTemplate < ::Asciidoctor::BaseTemplate
  def template
    @template ||= @eruby.new <<-EOS
#{block_meta}```
<%= template.unescape(content) %>
```

    EOS
  end
end

class BlockQuoteTemplate < ::Asciidoctor::BaseTemplate
  def template
    @template ||= @eruby.new <<-EOS
#{block_meta}<%= content.rstrip.gsub(/^/, '> ') %>

    EOS
  end
end

class BlockVerseTemplate < ::Asciidoctor::BaseTemplate
  def template
    @template ||= @eruby.new <<-EOS
#{block_meta}<%= content.rstrip.gsub(/^/, '> ') %>

    EOS
  end
end

class BlockExampleTemplate < ::Asciidoctor::BaseTemplate
  def template
    @template ||= @eruby.new <<-EOS
#{block_meta}<%= content.rstrip %>

    EOS
  end
end

class BlockSidebarTemplate < ::Asciidoctor::BaseTemplate
  def template
    @template ||= @eruby.new <<-EOS
#{block_meta}<%= content.rstrip %>

    EOS
  end
end

class BlockOpenTemplate < ::Asciidoctor::BaseTemplate
  def template
    @template ||= @eruby.new <<-EOS
#{block_meta}<%= content.rstrip %>

    EOS
  end
end

class BlockTableTemplate < ::Asciidoctor::BaseTemplate
  def template
    @template ||= @eruby.new <<-EOS
#{block_meta}|===
|TODO
|===

    EOS
  end
end

class BlockImageTemplate < ::Asciidoctor::BaseTemplate
  def template
    @template ||= @eruby.new <<-EOS
#{block_meta}![<%= attr :alt %>](<%= attr :target %><% if title? %> "<%= title %>"<% end %>)
    EOS
  end
end

class BlockRulerTemplate < ::Asciidoctor::BaseTemplate
  def template
    @template ||= @eruby.new <<-EOS
---

    EOS
  end
end

class InlineQuotedTemplate < ::Asciidoctor::BaseTemplate
  QUOTED_TAGS = {
    :emphasis => ['*', '*'],
    :strong => ['**', '**'],
    :monospaced => ['`', '`'],
    :superscript => ['<sup>', '</sup>'],
    :subscript => ['<sub>', '</sub>'],
    :double => ['"', '"'],
    :single => ['\'', '\''],
    :none => ['', '']
  }

  def template
    @template ||= @eruby.new <<-EOS
<% tags = template.class::QUOTED_TAGS[@type] %><%= "\#{tags.first}\#@text\#{tags.last}" %>
    EOS
  end
end

class InlineAnchorTemplate < ::Asciidoctor::BaseTemplate
  def template
    @template ||= @eruby.new <<-EOS
<%
if type == :xref
%><%
elsif @type == :ref
%><%
else
%><% if @text == @target %><%= @target %><% else %>[<%= @text %>](<%= @target %>)<% end %><%
end
%>
    EOS
  end
end

class InlineBreakTemplate < ::Asciidoctor::BaseTemplate
  def template
    @template ||= @eruby.new <<-EOS
<%= @text %>  
    EOS
  end
end

class InlineImageTemplate < ::Asciidoctor::BaseTemplate
  def template
    # care is taken here to avoid a space inside the optional <a> tag
    @template ||= @eruby.new <<-EOS
![<%= attr :alt %>](<%= @target %>)
    EOS
  end
end

class InlineCalloutTemplate < ::Asciidoctor::BaseTemplate
  def template
    @template ||= @eruby.new <<-EOS
    EOS
  end
end
end
