module Slotify
  class Entry
    include Utils

    attr_reader :slot_name, :args, :block

    delegate_missing_to :content

    def initialize(view_context, slot_name, args = [], options = {}, block = nil)
      @view_context = view_context
      @slot_name = slot_name.to_sym
      @args = args
      @options = options
      @block = block
    end

    def options
      EntryOptions.new(@view_context, @options)
    end

    def content
      body = if @block
        @view_context.capture(&@block)
      else
        begin
          args.first.to_str
        rescue NoMethodError
          ""
        end
      end
      ActiveSupport::SafeBuffer.new(body.presence || "")
    end

    alias_method :to_s, :content

    def present?
      true
    end

    def to_partial_path
      @slot_name.to_s
    end

    def with_default_options(default_options, view_context = @view_context)
      options = merge_tag_options(default_options, @options)
      Entry.new(view_context, @slot_name, @args, options, &@block)
    end

    def render_in(view_context, &block)
      view_context.render to_partial_path, **options.to_h.except(:partial_path), &block
    end

    def merged_args(args, options, block)
      [
        args.clone + @args.clone,
        merge_tag_options(options, @options),
        @block || block
      ]
    end
  end
end
