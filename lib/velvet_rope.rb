require "redcarpet"
require "pygments.rb"
require "gemoji"

module Redcarpet
  module Render
    class VelvetRope < HTML

      def initialize(extensions={})
        @extensions ||= {}
        @extensions[:highlight_syntax] = extensions.delete(:highlight_syntax) || false
        @extensions[:emoji] = extensions.delete(:emoji) || false

        # This is ugly, but is a workaround for Redcarpet not handling `super`
        # as it is a wrapper for the implementation written in C
        if @extensions[:highlight_syntax]
          self.class.send(:define_method, :block_code) do |code, language|
            if Pygments::Lexer.find_by_alias(language)
              if @extensions[:highlight_line_number]
                Pygments.highlight(code, lexer: language, options: { linespans: 'line' })
              else
                Pygments.highlight(code, lexer: language)
              end
            else
              if @extensions[:highlight_line_number]
                Pygments.highlight(code, options: { linespans: 'line' })
              else
                Pygments.highlight(code, options: { linespans: 'line' })
              end
            end
          end
        end

        # `super` however DOES work in this intializer...
        super(extensions)
      end

      def postprocess(document)
        if @extensions[:emoji]
          document.gsub!(/:([a-z0-9\+\-_]+):/) do |match|
            if Emoji.names.include?($1)
              emoji_template($1)
            else
              match
            end
          end
        end
        document
      end

      def emoji_template(name)
        '<img alt="' + name + '" src="' + "/images/emoji/#{name}.png" + '" style="vertical-align:middle" width="20" height="20" />'
      end

    end
  end
end
