# Inline SVG icons that replace the emojis. They follow the mascot's look:
# ink outline, flat colour. Size comes from CSS (.mani-icon is 1.25em by default).
module IconsHelper
  INK = "#1b1411".freeze

  ICONS = {
    check: <<~SVG,
      <circle cx="24" cy="24" r="20" fill="#3fb06b" stroke="#{INK}" stroke-width="3"/>
      <path d="M14 25l7 7 13-15" fill="none" stroke="#{INK}" stroke-width="8.5" stroke-linecap="round" stroke-linejoin="round"/>
      <path d="M14 25l7 7 13-15" fill="none" stroke="#fffaf0" stroke-width="4.5" stroke-linecap="round" stroke-linejoin="round"/>
    SVG
    lock: <<~SVG,
      <path d="M15 22v-6a9 9 0 0 1 18 0v6" fill="none" stroke="#{INK}" stroke-width="9" stroke-linecap="round"/>
      <path d="M15 22v-6a9 9 0 0 1 18 0v6" fill="none" stroke="#8a8f98" stroke-width="3.5" stroke-linecap="round"/>
      <rect x="8" y="21" width="32" height="22" rx="5" fill="#ffb81c" stroke="#{INK}" stroke-width="3"/>
      <circle cx="24" cy="30" r="3.4" fill="#{INK}"/>
      <path d="M22.2 31h3.6l1 7h-5.6z" fill="#{INK}"/>
    SVG
    flame: <<~SVG,
      <path d="M24 4c2 8 12 12 12 25a12 12 0 0 1-24 0c0-6 3-9 5-12 1 3 2 4 4 5-1-7 0-13 3-18z" fill="#f26b3a" stroke="#{INK}" stroke-width="3" stroke-linejoin="round"/>
      <path d="M24 22c2 5 6 7 6 12a6 6 0 0 1-12 0c0-4 3-6 6-12z" fill="#ffc21a"/>
    SVG
    heart: <<~SVG,
      <path d="M24 41C10 31 5 24 5 17a9.5 9.5 0 0 1 19-3 9.5 9.5 0 0 1 19 3c0 7-5 14-19 24z" fill="#ef4f5a" stroke="#{INK}" stroke-width="3" stroke-linejoin="round"/>
      <path d="M12 16a5 5 0 0 1 5-4.5" fill="none" stroke="#fff" stroke-opacity=".65" stroke-width="3" stroke-linecap="round"/>
    SVG
    star: <<~SVG,
      <path d="M24 6l5 12.1 13.1 1-10 8.5 3.1 12.8L24 33.5l-11.2 6.9 3.1-12.8-10-8.5 13.1-1z" fill="#ffb81c" stroke="#{INK}" stroke-width="3" stroke-linejoin="round"/>
    SVG
    books: <<~SVG,
      <rect x="6" y="31" width="34" height="11" rx="2.5" fill="#5a9a2f" stroke="#{INK}" stroke-width="3"/>
      <rect x="12" y="33" width="26" height="7" rx="1" fill="#fbeccb" stroke="#{INK}" stroke-width="2"/>
      <rect x="9" y="20" width="34" height="11" rx="2.5" fill="#d9503a" stroke="#{INK}" stroke-width="3"/>
      <rect x="15" y="22" width="26" height="7" rx="1" fill="#fbeccb" stroke="#{INK}" stroke-width="2"/>
      <rect x="5" y="9" width="34" height="11" rx="2.5" fill="#0e6b78" stroke="#{INK}" stroke-width="3"/>
      <rect x="11" y="11" width="26" height="7" rx="1" fill="#fbeccb" stroke="#{INK}" stroke-width="2"/>
    SVG
    trophy: <<~SVG,
      <path d="M14 9H8v4a7 7 0 0 0 7 7M34 9h6v4a7 7 0 0 1-7 7" fill="none" stroke="#{INK}" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
      <path d="M14 5h20v11a10 10 0 0 1-20 0z" fill="#ffb81c" stroke="#{INK}" stroke-width="3" stroke-linejoin="round"/>
      <path d="M24 10l1.7 3.4 3.8.5-2.8 2.6.7 3.7-3.4-1.8-3.4 1.8.7-3.7-2.8-2.6 3.8-.5z" fill="#d98a00"/>
      <rect x="21" y="26" width="6" height="7" fill="#ffb81c" stroke="#{INK}" stroke-width="3"/>
      <rect x="13" y="33" width="22" height="9" rx="2" fill="#7a4a2b" stroke="#{INK}" stroke-width="3"/>
    SVG
    handshake: <<~SVG,
      <rect x="2" y="15" width="9" height="17" rx="2" fill="#0e6b78" stroke="#{INK}" stroke-width="3"/>
      <rect x="37" y="15" width="9" height="17" rx="2" fill="#f26b54" stroke="#{INK}" stroke-width="3"/>
      <path d="M11 19l8-4 8 3 10 1v12l-6 6-6 3-6-2-6-6-4-1z" fill="#f6a98a" stroke="#{INK}" stroke-width="3" stroke-linejoin="round"/>
      <path d="M20 28l5 5M24 25l5 5M28 22l4 4" fill="none" stroke="#{INK}" stroke-width="2.5" stroke-linecap="round"/>
    SVG
    play: <<~SVG,
      <path d="M16 10l22 14-22 14z" fill="#fffaf0" stroke="#{INK}" stroke-width="3" stroke-linejoin="round"/>
    SVG
    # Controls: they take the colour of the text around them
    close_circle: <<~SVG,
      <circle cx="24" cy="24" r="20" fill="currentColor"/>
      <path d="M17 17l14 14M31 17L17 31" fill="none" stroke="#fff" stroke-width="4" stroke-linecap="round"/>
    SVG
    volume_on: <<~SVG,
      <path d="M7 19h8l11-9v28l-11-9H7z" fill="currentColor"/>
      <path d="M32 17a10 10 0 0 1 0 14M37 12a17 17 0 0 1 0 24" fill="none" stroke="currentColor" stroke-width="3.5" stroke-linecap="round"/>
    SVG
    volume_off: <<~SVG,
      <path d="M7 19h8l11-9v28l-11-9H7z" fill="currentColor"/>
      <path d="M33 19l10 10M43 19L33 29" fill="none" stroke="currentColor" stroke-width="3.5" stroke-linecap="round"/>
    SVG
    users: <<~SVG
      <circle cx="18" cy="16" r="7" fill="currentColor"/>
      <path d="M4 41c0-8 6-13 14-13s14 5 14 13z" fill="currentColor"/>
      <circle cx="34" cy="17" r="5.5" fill="currentColor" opacity=".65"/>
      <path d="M34 27c6 0 11 4 11 11 0 1-.2 2-.5 3H36c.3-1 .5-2 .5-3 0-4-1-8-2.5-11z" fill="currentColor" opacity=".65"/>
    SVG
  }.freeze

  PLAIN = %i[close_circle volume_on volume_off users].freeze

  # The mascot picture of a lesson: one of the poses in app/assets/images/mascot/ (cut from
  # the sheet in docs/art), named by lessons.intro_image. The plain mascot when there is none.
  def lesson_image_tag(lesson, **options)
    mascot_tag(lesson.intro_image, **options)
  end

  # mascot_tag("pig-cheering"): a pose of the mascot; the plain mascot if the pose is unknown
  def mascot_tag(name, **options)
    key = name.to_s
    path = "mascot/#{key}.png"
    path = "Mani-oficial.png" if key.blank? || Rails.application.assets.load_path.find(path).nil?
    image_tag path, alt: "", **options
  end

  # mani_icon(:flame), mani_icon(:star, class: "off")
  def mani_icon(name, **options)
    body = ICONS.fetch(name.to_sym)
    css = ["mani-icon", "mani-icon-#{name}", ("is-plain" if PLAIN.include?(name.to_sym)), options[:class]].compact.join(" ")
    %(<svg class="#{css}" viewBox="0 0 48 48" aria-hidden="true" focusable="false">#{body}</svg>).html_safe
  end
end
