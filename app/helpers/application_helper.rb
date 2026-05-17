module ApplicationHelper
  def flash_message_classes(type)
    if type.to_sym.in?([:notice, :success])
      "rounded-2xl border border-[#bfd8c2] bg-[#D6EAD9] px-4 py-3 text-base font-medium text-stone-800 shadow-sm"
    else
      "rounded-2xl border border-[#e5ce94] bg-[#F5E9C8] px-4 py-3 text-base font-medium text-[#8a6510] shadow-sm"
    end
  end

  def flash_message_icon(type)
    icon_classes = if type.to_sym.in?([:notice, :success])
      "fa-solid fa-circle-check"
    else
      "fa-solid fa-triangle-exclamation"
    end

    content_tag(:i, nil, class: icon_classes, aria: { hidden: true })
  end

  def mission_icon(name)
    content_tag(:svg, xmlns: "http://www.w3.org/2000/svg", fill: "none", viewBox: "0 0 24 24", stroke: "#2C4A7C", "stroke-width": 1.8, class: "h-8 w-8", aria: { hidden: true }) do
      safe_join(mission_icon_elements(name))
    end
  end

 def bottom_nav_items
  if Current.user&.professor?
    [
      { label: "Dashboard", path: "/professor/dashboard", icon: :home },
      { label: "Perfil",    path: "/perfil",              icon: :profile }
    ]
  else
    [
      { label: "Missões",    path: "/missoes",         icon: :missions },
      { label: "Histórico",  path: "/aluno/dashboard", icon: :history },
      { label: "Conquistas", path: "/conquistas",      icon: :achievements },
      { label: "Perfil",     path: "/perfil",          icon: :profile }
    ]
  end
end

  def bottom_nav_link(item)
    active = bottom_nav_active?(item[:path])
    color = active ? "text-[#4A6FA5]" : "text-[#7A726C]"
    link_to item[:path], class: [
      "flex min-h-14 flex-col items-center justify-center gap-1 px-2 py-2 text-center text-[13px] font-semibold leading-none",
      color
    ].join(" "), aria: { current: active ? "page" : nil } do
      safe_join([
        bottom_nav_icon(item[:icon], active:),
        content_tag(:span, item[:label])
      ])
    end
  end

  private

  def bottom_nav_active?(path)
  return request.path == "/" if path == "/"
  request.path == path || request.path.start_with?("#{path}/")
end

  def bottom_nav_icon(name, active:)
    color = active ? "#4A6FA5" : "#7A726C"
    content_tag(:svg, xmlns: "http://www.w3.org/2000/svg", fill: "none", viewBox: "0 0 24 24", stroke: color, "stroke-width": 1.8, class: "h-5 w-5", aria: { hidden: true }) do
      safe_join(bottom_nav_elements(name))
    end
  end

  def bottom_nav_elements(name)
    case name
    when :home
      [
        tag.path(d: "M3 10.75 12 3l9 7.75", "stroke-linecap": "round", "stroke-linejoin": "round"),
        tag.path(d: "M5.25 9.5V21h13.5V9.5", "stroke-linecap": "round", "stroke-linejoin": "round")
      ]
    when :missions
      [
        tag.circle(cx: "12", cy: "12", r: "8"),
        tag.circle(cx: "12", cy: "12", r: "3"),
        tag.path(d: "M12 2v2", "stroke-linecap": "round"),
        tag.path(d: "M12 20v2", "stroke-linecap": "round"),
        tag.path(d: "M2 12h2", "stroke-linecap": "round"),
        tag.path(d: "M20 12h2", "stroke-linecap": "round")
      ]
    when :history
      [
        tag.circle(cx: "12", cy: "12", r: "9", "stroke-linecap": "round"),
        tag.path(d: "M12 7v5l3 3", "stroke-linecap": "round", "stroke-linejoin": "round")
      ]
    when :achievements
      [
        tag.path(d: "M8 4h8v3a4 4 0 0 1-8 0V4Z", "stroke-linecap": "round", "stroke-linejoin": "round"),
        tag.path(d: "M9 14h6", "stroke-linecap": "round"),
        tag.path(d: "M12 10v7", "stroke-linecap": "round"),
        tag.path(d: "M8 21h8", "stroke-linecap": "round"),
        tag.path(d: "M16 5h2a2 2 0 0 1 0 4h-2", "stroke-linecap": "round", "stroke-linejoin": "round"),
        tag.path(d: "M8 5H6a2 2 0 1 0 0 4h2", "stroke-linecap": "round", "stroke-linejoin": "round")
      ]
    when :profile
      [
        tag.path(d: "M18 21a6 6 0 0 0-12 0", "stroke-linecap": "round", "stroke-linejoin": "round"),
        tag.path(d: "M12 11a4 4 0 1 0 0-8 4 4 0 0 0 0 8Z", "stroke-linecap": "round", "stroke-linejoin": "round")
      ]
    else
      []
    end
  end

  def mission_icon_elements(name)
    case name
    when :leitura
      [
        tag.path(d: "M6 5.5A2.5 2.5 0 0 1 8.5 3H19v15.5A2.5 2.5 0 0 0 16.5 16H6z", "stroke-linecap": "round", "stroke-linejoin": "round"),
        tag.path(d: "M6 5.5V21", "stroke-linecap": "round", "stroke-linejoin": "round"),
        tag.path(d: "M10 7h5", "stroke-linecap": "round"),
        tag.path(d: "M10 11h5", "stroke-linecap": "round")
      ]
    when :foco
      [
        tag.circle(cx: "12", cy: "12", r: "8"),
        tag.circle(cx: "12", cy: "12", r: "3"),
        tag.path(d: "M12 4V2", "stroke-linecap": "round"),
        tag.path(d: "M20 12h2", "stroke-linecap": "round"),
        tag.path(d: "M12 20v2", "stroke-linecap": "round"),
        tag.path(d: "M2 12h2", "stroke-linecap": "round")
      ]
    when :desafio
      [
        tag.path(d: "M8 7h8", "stroke-linecap": "round"),
        tag.path(d: "M8 12h8", "stroke-linecap": "round"),
        tag.path(d: "M8 17h8", "stroke-linecap": "round"),
        tag.path(d: "M5 7h.01", "stroke-linecap": "round"),
        tag.path(d: "M5 12h.01", "stroke-linecap": "round"),
        tag.path(d: "M5 17h.01", "stroke-linecap": "round")
      ]
    else
      []
    end
  end
end
