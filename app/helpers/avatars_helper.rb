module AvatarsHelper
  # The picture of an avatar (or of the avatar in use by a user)
  def avatar_tag(avatar_or_user, **options)
    avatar = avatar_or_user.respond_to?(:avatar) ? avatar_or_user.avatar : avatar_or_user
    css = [options.delete(:class), (avatar.default? ? "is-base" : "is-custom")].compact.join(" ")
    image_tag avatar.image, alt: options.delete(:alt) || "", class: css, **options
  end
end
