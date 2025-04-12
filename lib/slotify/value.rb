module Slotify
  class Value
    include InflectionHelper

    attr_reader :slot_name, :args, :block

    delegate :presence, :to_s, :to_str, to: :content

    def initialize(view_context, slot_name, args = [], options = {}, block = nil, partial_path: nil)
      @view_context = view_context
      @slot_name = slot_name.to_sym
      @args = args
      @options = options.to_h
      @block = block
      @partial_path = partial_path
    end

    def options
      ValueOptions.new(@view_context, @options)
    end

    def content
      if @block && @block.arity == 0
        body = @view_context.capture(&@block)
        ActiveSupport::SafeBuffer.new(body.presence || "")
      elsif args.first.is_a?(String)
        ActiveSupport::SafeBuffer.new(args.first)
      else
        args.first
      end
    end

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
      Value.new(@view_context, @slot_name, @args, options, @block, partial_path:)
    end

    def with_default_options(default_options)
      options = TagOptionsMerger.call(default_options, @options)
      Value.new(@view_context, @slot_name, @args, options, @block)
    end

    def respond_to_missing?(name, include_private = false)
      name.start_with?("to_") || super
    end

    def method_missing(name, ...)
      if name.start_with?("to_")
        @args.first.public_send(name, ...)
      end
    end

    def [](key)
      key.is_a?(Integer) ? @args[key] : super
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
