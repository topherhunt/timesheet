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
    output += input.strftime("%a ") if opt[:weekday]
    output += input.strftime("%b %e")
    output += " #{input.year}" if input.year != Time.now.year
    output += input.strftime(", %l:%M %P") if opt[:time]
    output
  end

  def time(input)
    input.strftime("%l:%M %P")
  end
end
