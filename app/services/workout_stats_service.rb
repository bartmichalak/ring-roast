class WorkoutStatsService
  PERIOD_DAYS = 30

  def initialize(workouts)
    @workouts = workouts
  end

  def call
    return { empty: true } if @workouts.empty?

    {
      empty: false,
      summary: summary_stats,
      most_common_type: most_common_type_stats,
      longest_workout: longest_workout_stats,
      totals: totals_stats
    }
  end

  private

  def summary_stats
    total_seconds = @workouts.sum { |w| w["duration_seconds"].to_i }

    {
      total_count: @workouts.size,
      total_duration_seconds: total_seconds,
      total_duration_formatted: format_duration(total_seconds),
      period_days: PERIOD_DAYS
    }
  end

  def most_common_type_stats
    type_counts = @workouts.group_by { |w| w["type"] }.transform_values(&:size)
    top_type, top_count = type_counts.max_by { |_, count| count }

    {
      type: top_type,
      count: top_count,
      percentage: (top_count * 100.0 / @workouts.size).round,
      type_breakdown: type_counts
    }
  end

  def longest_workout_stats
    longest = @workouts.max_by { |w| w["duration_seconds"].to_i }

    {
      name: longest["name"] || longest["type"],
      type: longest["type"],
      duration_seconds: longest["duration_seconds"].to_i,
      duration_formatted: format_duration(longest["duration_seconds"].to_i),
      date: format_date(longest["start_time"]),
      calories_kcal: longest["calories_kcal"],
      avg_heart_rate_bpm: longest["avg_heart_rate_bpm"]
    }
  end

  def totals_stats
    calories = @workouts.filter_map { |w| w["calories_kcal"] }
    distances = @workouts.filter_map { |w| w["distance_meters"] }
    heart_rates = @workouts.filter_map { |w| w["avg_heart_rate_bpm"] }

    {
      total_calories_kcal: calories.sum.round,
      total_distance_meters: distances.sum.round,
      total_distance_km: (distances.sum / 1000.0).round(1),
      avg_heart_rate_bpm: heart_rates.any? ? (heart_rates.sum.to_f / heart_rates.size).round : nil
    }
  end

  def format_duration(seconds)
    hours = seconds / 3600
    minutes = (seconds % 3600) / 60

    if hours > 0
      "#{hours}h #{minutes}m"
    else
      "#{minutes}m"
    end
  end

  def format_date(time_string)
    Time.parse(time_string).strftime("%B %-d")
  rescue
    time_string
  end
end
