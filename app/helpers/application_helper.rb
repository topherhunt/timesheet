module ApplicationHelper

  def bootstrap_flash_class(key)
    case key.to_sym
    when :notice
      'info'
    when :alert
      'warning'
    else
      raise "Unrecognized flash key '#{key.to_s}'!"
    end
  end

  def active_if_current(path)
    "active" if request.path.include?(path)
  end

  def success_or_danger(condition)
    condition ? "text-success" : "text-danger"
  end

  def show_errors_for (object)
    render 'shared/errors', object: object if object.errors.any?
  end

  def breadcrumbs(parts, opt={})
    active = opt[:active] || parts.last
    render 'shared/breadcrumbs', parts: parts.compact, active: active
  end

  def glyph (name)
    content_tag :span, '', class: "glyphicon glyphicon-#{name.to_s}"
  end



  def date(input, opt={})
    return unless input

    output = ""
    output += input.strftime("%a, ") if opt[:weekday]
    output += input.strftime("%b %e")
    output += " #{input.year}" if opt[:year] || (input.year != Time.now.year && opt[:year] != false)
    output += input.strftime(", %l:%M %P") if opt[:time]
    output.gsub("  ", " ")
  end

  def time(input)
    input.strftime("%l:%M %P")
  end
end
