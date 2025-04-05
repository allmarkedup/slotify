module Slotify
  class Entry
    include InflectionHelper

    attr_reader :slot_name, :args, :block

    delegate :presence, to: :@content

    def initialize(view_context, slot_name, args = [], options = {}, block = nil, partial_path: nil)
      @view_context = view_context
      @slot_name = slot_name.to_sym
      @args = args
      @options = options.to_h
      @block = block
      @partial_path = partial_path
    end

    def options
      EntryOptions.new(@view_context, @options)
    end

    def content
      body = if @block && @block.arity == 0
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
    alias_method :to_str, :content

    def present?
      @args.present? || @options.present? || @block
    end

    def empty?
      @args.empty? || @options.empty? || !@block
    end

    alias_method :blank?, :empty?

    def to_h
      @options
    end

    alias_method :to_hash, :to_h

    def with_partial_path(partial_path)
      Entry.new(@view_context, @slot_name, @args, options, @block, partial_path:)
    end

    def with_default_options(default_options)
      options = TagOptionsMerger.call(default_options, @options)
      Entry.new(@view_context, @slot_name, @args, options, @block)
    end

    def respond_to_missing?(name, include_private = false)
      name.start_with?("to_") || super
    end

    def method_missing(name, *args, **options)
      if name.start_with?("to_") && args.none?
        @args.first.public_send(name)
      end
    end

    def render_in(view_context, &block)
      view_context.render partial_path, **@options.to_h, &@block || block
    end

    private

    def partial_path
      @partial_path || @slot_name.to_s
    end
  end
end
