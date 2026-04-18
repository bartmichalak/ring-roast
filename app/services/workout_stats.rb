class WorkoutStats
  def initialize(workouts)
    @workouts = Array(workouts)
  end

  def any?
    @workouts.any?
  end

  def cards
    return [] if @workouts.empty?

    [ summary_card, top_type_card, longest_session_card, totals_card ]
  end

  def metrics
    return {} if @workouts.empty?

    durations = compact_values("duration_seconds")
    longest = @workouts.reject { |w| w["duration_seconds"].blank? }.max_by { |w| w["duration_seconds"] }
    type_counts = @workouts.each_with_object(Hash.new(0)) { |w, h| h[w["type"]] += 1 if w["type"].present? }
    top_type, top_type_count = type_counts.max_by { |_, c| c } || [ nil, 0 ]
    hrs = compact_values("avg_heart_rate_bpm")

    {
      workout_count: @workouts.size,
      total_duration_seconds: durations.sum,
      favorite_type: top_type ? humanize_type(top_type) : nil,
      favorite_type_count: top_type_count,
      longest_duration_seconds: longest ? longest["duration_seconds"].to_i : nil,
      longest_name: longest ? (longest["name"].presence || humanize_type(longest["type"])) : nil,
      total_calories_kcal: compact_values("calories_kcal").sum.round,
      total_distance_meters: compact_values("distance_meters").sum.round,
      avg_heart_rate_bpm: hrs.any? ? (hrs.sum.to_f / hrs.size).round : nil
    }
  end

  private

  def summary_card
    total_seconds = compact_values("duration_seconds").sum
    {
      kind: :summary,
      headline: "Your last 30 days",
      value: @workouts.size.to_s,
      unit: @workouts.size == 1 ? "workout" : "workouts",
      detail: total_seconds.positive? ? "#{format_duration(total_seconds)} of sweat equity" : nil
    }
  end

  def top_type_card
    counts = @workouts.each_with_object(Hash.new(0)) { |w, h| h[w["type"]] += 1 if w["type"].present? }
    return placeholder_card(:top_type, "Favorite workout", "None yet") if counts.empty?

    top_type, count = counts.max_by { |_type, c| c }
    pct = (count.to_f / @workouts.size * 100).round
    {
      kind: :top_type,
      headline: "Your go-to workout",
      value: humanize_type(top_type),
      unit: nil,
      detail: "#{count}× - #{pct}% of everything you did"
    }
  end

  def longest_session_card
    with_duration = @workouts.reject { |w| w["duration_seconds"].blank? }
    return placeholder_card(:longest, "Longest session", "None recorded") if with_duration.empty?

    longest = with_duration.max_by { |w| w["duration_seconds"] }
    title = longest["name"].presence || humanize_type(longest["type"])
    {
      kind: :longest,
      headline: "Your longest grind",
      value: format_duration(longest["duration_seconds"]),
      unit: nil,
      detail: [ title, format_date(longest["start_time"]) ].compact.join(" · ")
    }
  end

  def totals_card
    calories = compact_values("calories_kcal").sum.round
    distance_km = (compact_values("distance_meters").sum / 1000.0).round(1)
    hrs = compact_values("avg_heart_rate_bpm")
    avg_hr = hrs.any? ? (hrs.sum.to_f / hrs.size).round : nil

    detail_parts = []
    detail_parts << "#{distance_km} km covered" if distance_km.positive?
    detail_parts << "avg HR #{avg_hr} bpm" if avg_hr

    {
      kind: :totals,
      headline: "The grand total",
      value: calories.positive? ? calories.to_s : "—",
      unit: calories.positive? ? "kcal torched" : nil,
      detail: detail_parts.any? ? detail_parts.join(" · ") : nil
    }
  end

  def compact_values(field)
    @workouts.map { |w| w[field] }.compact
  end

  def placeholder_card(kind, headline, value)
    { kind: kind, headline: headline, value: value, unit: nil, detail: nil }
  end

  def humanize_type(type)
    return "Unknown" if type.blank?
    type.to_s.tr("_-", " ").split.map(&:capitalize).join(" ")
  end

  def format_duration(seconds)
    seconds = seconds.to_i
    h, rem = seconds.divmod(3600)
    m, _ = rem.divmod(60)
    if h.positive?
      "#{h}h #{m}m"
    else
      "#{m}m"
    end
  end

  def format_date(iso_time)
    return nil if iso_time.blank?
    Time.parse(iso_time.to_s).strftime("%b %-d")
  rescue ArgumentError
    nil
  end
end
