module DateHelper
  def local_timezone; current_user&.time_zone || "America/New_York"; end

  def date(input, opts={})
    return unless input
    input = input.in_time_zone(local_timezone)

    output = ""
    output += input.strftime("%a, ") if opts[:weekday]
    output += input.strftime("%b %e")
    if opts[:year] || (input.year != Time.now.year && opts[:year] != false)
      output += " #{input.year}"
    end
    output += time(input, opts) if opts[:time]
    output.gsub("  ", " ")
  end

  def time(input, opts={})
    input = input.in_time_zone(local_timezone)
    output = input.strftime("%l:%M %P")
    output = output.gsub(" ", "")[0..-2] if opts[:short]
    output
  end

  # I don't like Rails' time_zone_options_for_select because it uses
  # the Rails friendly tz names as values, not the standard tz labels
  def correct_tz_options
    ActiveSupport::TimeZone::MAPPING.map do |human_name, value|
      tz = ActiveSupport::TimeZone.new(human_name)
      [tz.to_s, value]
    end
  end
end
