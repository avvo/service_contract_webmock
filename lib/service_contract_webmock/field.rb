module ServiceContractWebmock
  class Field
    attr_reader :name, :type, :value

    def initialize(name, type)
      @name = name
      @type = type
      @value = build_value(type)
    end

    def int?(t = type)
      t.type_sym == :int ||
        (t.type_sym == :array && t.items.type_sym == :int) ||
        (t.type_sym == :union && t.schemas.any? {|sub| int?(sub)})
    end

    def boolean?(t = type)
      t.type_sym == :boolean ||
        (t.type_sym == :array && t.items.type_sym == :boolean) ||
        (t.type_sym == :union && t.schemas.any? {|sub| boolean?(sub)})
    end

    def convert(value)
      if int?
        value.to_i
      elsif boolean?
        value == "true"
      else
        value
      end
    end

    def build_value(type)
      case type.type_sym
      when :union
        subtypes = type.schemas.map {|subtype| build_value(subtype)}
        "(#{subtypes.join("|")})"
      when :null
        ""
      when :int
        "\\d+"
      when :array
        case type.items.type_sym
        when :int
          "[,\\d]+"
        else
          raise "unhandled array subtype #{type.items.type_sym}"
        end
      when :string
        ".+"
      when :boolean
        "true|false"
      else
        raise "unhandled type #{type.type_sym}"
      end
    end
  end
end
