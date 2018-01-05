module DateHelper
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
