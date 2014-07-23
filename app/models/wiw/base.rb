module Wiw
  # Borrowed from https://raw.githubusercontent.com/maccman/nestful/master/lib/nestful/resource.rb
  class Base
    attr_reader :attributes

    def initialize(attributes = {})
      @attributes = {}
      load(attributes)
    end

    def id #:nodoc:
      self['id']
    end

    def type #:nodoc:
      self['type']
    end

    def [](key)
      attributes[key]
    end

    def []=(key,value)
      attributes[key] = value
    end

    def to_hash
      attributes.dup
    end

    def as_json(*)
      to_hash
    end

    def to_json(*)
      as_json.to_json
    end

    def load(attributes = {})
      attributes.to_hash.each do |key, value|
        send("#{key}=", value)
      end
    end

    def ==(other)
      other.equal?(self) ||
          (other.instance_of?(self.class) && other.attributes == attributes)
    end

    # Tests for equality (delegates to ==).
    def eql?(other)
      self == other
    end

    def hash
      attributes.hash
    end

    alias_method :respond_to_without_attributes?, :respond_to?

    def respond_to?(method, include_priv = false)
      method_name = method.to_s
      if attributes.nil?
        super
      elsif attributes.include?(method_name.sub(/[=\?]\Z/, ''))
        true
      else
        super
      end
    end

    protected

    def method_missing(method_symbol, *arguments) #:nodoc:
      method_name = method_symbol.to_s

      if method_name =~ /(=|\?)$/
        case $1
          when "="
            attributes[$`] = arguments.first
          when "?"
            attributes[$`]
        end
      else
        return attributes[method_name] if attributes.include?(method_name)
        super
      end
    end
  end
end
