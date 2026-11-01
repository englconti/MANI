require "yaml"

# An avatar of the Mani Store. The catalog lives in config/avatars.yml; what a person owns is in
# avatar_purchases and the one in use is users.avatar_key. The base avatar (the teal Mani) is
# everyone's from the start.
class Avatar
  class Error < StandardError; end
  class Unknown < Error; end
  class AlreadyOwned < Error; end
  class NotOwned < Error; end

  class NotEnoughManis < Error
    attr_reader :missing

    def initialize(missing)
      @missing = missing
      super("faltam #{missing} M$")
    end
  end

  # Cheap to rare, by price: just a label to show next to the price
  TIERS = [[30, "Comum"], [60, "Raro"], [100, "Épico"], [Float::INFINITY, "Lendário"]].freeze

  attr_reader :key, :name, :price, :description

  def initialize(key:, name:, description:, price: 0)
    @key = key.to_s
    @name = name
    @price = price.to_i
    @description = description
  end

  class << self
    def data
      @data ||= YAML.safe_load_file(Rails.root.join("config/avatars.yml"))
    end

    def default
      @default ||= from_entry(data.fetch("base"))
    end

    # Everything in the store, cheapest first (the base avatar is not for sale)
    def for_sale
      @for_sale ||= data.fetch("avatars").map { |entry| from_entry(entry) }.sort_by { |avatar| [avatar.price, avatar.name] }
    end

    def all
      [default] + for_sale
    end

    def keys
      all.map(&:key)
    end

    def find(key)
      all.find { |avatar| avatar.key == key.to_s }
    end

    def find!(key)
      find(key) || raise(Unknown, "avatar desconhecido: #{key}")
    end

    private

    def from_entry(entry)
      new(key: entry.fetch("key"), name: entry.fetch("name"), price: entry["price"].to_i, description: entry.fetch("description"))
    end
  end

  def default?
    key == self.class.default.key
  end

  def tier
    return "Inicial" if default?

    TIERS.find { |limit, _label| price <= limit }.last
  end

  # Asset path of the picture: the base one is a file of its own, the others are PNGs in avatars/
  def image
    default? ? "avatar-mani.webp" : "avatars/#{key}.png"
  end

  def ==(other)
    other.is_a?(Avatar) && other.key == key
  end
  alias eql? ==

  def hash
    key.hash
  end
end
