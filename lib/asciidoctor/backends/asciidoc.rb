class Asciidoctor::BaseTemplate
  def unescape(str)
    str.gsub('{', '\\{').gsub('&#160;', '{nbsp}').gsub('&#43;', '{plus}').gsub('&#8217;', '\'').
        gsub('&#8230;', '...').gsub('&#8201;&#8212;&#8201;', ' -- ').gsub('&lt;', '<').gsub('&gt;', '>').gsub('&amp;', '&')
  end

  def block_meta
    %q{<% unless id.nil? %>[[<%= id %>]]
<% end %><% if attr? :role %>[role="<%= attr :role %>"]
<% end %><% if title? %>.<%= title %>
<% end %>}
  end
end

module Asciidoctor::AsciiDoc
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
<% if has_header? %><%= doctitle %>
<%= '=' * doctitle.length %>
<% if (attr? :author) or (attr? :email) %><%
if attr? :author %><%= attr :author%><% end
%><% if attr? :email %> <<%= attr :email %>><% end %>
<% end %><% end %><% attributes.select {|k, v| !template.class::BUILTIN_ATTRIBUTES.include?(k) }.each do |k, v| %>:<%= k %>: <%= v %>
<% end %>

<%= content.rstrip %>

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
<% unless id.nil? || id.start_with?('_') %>[[<%= id %>]]
<% end %><%= '=' * (@level + 1) %> <%= template.unescape(title) %>

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
#{block_meta}<% if blocks? %>[<%= (attr :name).upcase %>]
====
<%= content.rstrip %>
====
<% else %><%= (attr :name).upcase %>: <%= content.rstrip %>
<% end %>

    EOS
  end
end

# TODO list continuation lines
class BlockUlistTemplate < ::Asciidoctor::BaseTemplate
  def template
    @template ||= @eruby.new <<-EOS
#{block_meta}<% content.each do |li| %><%= li.marker %> <%= template.unescape(li.text.gsub(/\n[[:space:]]*\n/, "\n")) %>
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
#{block_meta}<% content.each do |li| %><%= '.' * li.level %> <%= template.unescape(li.text.gsub(/\n[[:space:]]*\n/, "\n")) %>
<% if li.blocks? %><%= li.content.rstrip %>

<% else %>

<% end %>
<% end %>

    EOS
  end
end

class BlockColistTemplate < ::Asciidoctor::BaseTemplate
  def template
    @template ||= @eruby.new <<-EOS
#{block_meta}<% content.each_with_index do |li, i| %><<%= i + 1 %>> <%= li.text %>
<% end %>

    EOS
  end
end

class BlockDlistTemplate < ::Asciidoctor::BaseTemplate
  def template
    @template ||= @eruby.new <<-EOS
#{block_meta}<% content.each do |dt, dd| %><%= dt.text %>::<% unless dd.nil? %> <%= dd.text %><% end %>
<% end %>

    EOS
  end
end

class BlockLiteralTemplate < ::Asciidoctor::BaseTemplate
  def template
    @template ||= @eruby.new <<-EOS
#{block_meta}<% if (attr? :options) && (attr :options).include?('listparagraph') %>
  <%= template.unescape(content) %><% else %>....
<%= template.unescape(content) %>
....
<% end %>

    EOS
  end
end

class BlockListingTemplate < ::Asciidoctor::BaseTemplate
  def template
    @template ||= @eruby.new <<-EOS
#{block_meta}----
<%= template.unescape(content) %>
----

    EOS
  end
end

class BlockQuoteTemplate < ::Asciidoctor::BaseTemplate
  def template
    @template ||= @eruby.new <<-EOS
#{block_meta}____
<%= content.rstrip %>
____

    EOS
  end
end

class BlockVerseTemplate < ::Asciidoctor::BaseTemplate
  def template
    @template ||= @eruby.new <<-EOS
#{block_meta}[verse]
____
<%= content.rstrip %>
____

    EOS
  end
end

class BlockExampleTemplate < ::Asciidoctor::BaseTemplate
  def template
    @template ||= @eruby.new <<-EOS
#{block_meta}====
<%= content.rstrip %>
====

    EOS
  end
end

class BlockSidebarTemplate < ::Asciidoctor::BaseTemplate
  def template
    @template ||= @eruby.new <<-EOS
#{block_meta}****
<%= content.rstrip %>
****

    EOS
  end
end

class BlockOpenTemplate < ::Asciidoctor::BaseTemplate
  def template
    @template ||= @eruby.new <<-EOS
#{block_meta}--
<%= content.rstrip %>
--

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
#{block_meta}image::<%= attr :target %>[<%= attr :alt %><%
if attr? :width %>, <%= attr :width %><% end %><%
if attr? :height %>, <%= attr :height %><% end %>]

    EOS
  end
end

class BlockRulerTemplate < ::Asciidoctor::BaseTemplate
  def template
    @template ||= @eruby.new <<-EOS
'''

    EOS
  end
end

class InlineQuotedTemplate < ::Asciidoctor::BaseTemplate
  QUOTED_TAGS = {
    :emphasis => ['\'', '\''],
    :strong => ['*', '*'],
    :monospaced => ['`', '`'],
    :superscript => ['^', '^'],
    :subscript => ['~', '~'],
    :double => ['``', '\'\''],
    :single => ['`', '\''],
    :none => ['#', '#']
  }

  def template
    @template ||= @eruby.new <<-EOS
<% tags = template.class::QUOTED_TAGS[@type] %><%= tags.first %><%= @text %><%= tags.last %>
    EOS
  end
end

class InlineAnchorTemplate < ::Asciidoctor::BaseTemplate
  def template
    @template ||= @eruby.new <<-EOS
<%
if type == :xref
%><<<%= @target %><% if @text %>,<%= @text %><% end %>>><%
elsif @type == :ref
%>[[<%= @target %>]]<%
else
%><% if !@target.include?('://') %>link:<% end %><%= @target %><% if @text != @target %>[<%= @text %>]<% end %><%
end
%>
    EOS
  end
end

class InlineBreakTemplate < ::Asciidoctor::BaseTemplate
  def template
    @template ||= @eruby.new <<-EOS
<%= @text %> +
    EOS
  end
end

class InlineImageTemplate < ::Asciidoctor::BaseTemplate
  def template
    # care is taken here to avoid a space inside the optional <a> tag
    @template ||= @eruby.new <<-EOS
image:<%= @target %>[<%= attr :alt %><%
if attr? :width %>, <%= attr :width %><% end %><%
if attr? :height %>, <%= attr :height %><% end %>]
    EOS
  end
end

class InlineCalloutTemplate < ::Asciidoctor::BaseTemplate
  def template
    @template ||= @eruby.new <<-EOS
<<%= text %>>
    EOS
  end
end
end
