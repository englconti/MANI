require "yaml"

module PagesHelper
  # The example testimonials of the landing page (config/testimonials.yml)
  def testimonials
    YAML.safe_load_file(Rails.root.join("config/testimonials.yml"))
  end
end
