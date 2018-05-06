module DateHelper
  def date(input, opts={})
    return unless input

    output = ""
    output += input.strftime("%a, ") if opts[:weekday]
    output += input.strftime("%b %e")
    if opts[:year] || (input.year != Time.now.year && opts[:year] != false)
      output += " #{input.year}"
    end
    output += input.strftime(", %l:%M %P") if opts[:time]
    output.gsub("  ", " ")
  end

  def time(input, opts={})
    output = input.strftime("%l:%M %P")
    output = output.gsub(" ", "")[0..-2] if opts[:short]
    output
  end
end
