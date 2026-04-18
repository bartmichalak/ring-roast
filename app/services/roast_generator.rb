class RoastGenerator
  MODEL = "gpt-4o-mini".freeze
  TEMPERATURE = 0.9
  KEYS = %w[summary most_common_type longest_workout totals].freeze

  SYSTEM_PROMPT = "You are a savage but funny fitness roast comedian. Roasts are 1-2 sentences max, punchy, brutal but not mean. Respond in valid JSON only with exactly these keys: summary, most_common_type, longest_workout, totals.".freeze

  def initialize(stats, client: self.class.default_client)
    @stats = stats
    @client = client
  end

  def call
    return {} unless @client && @stats.any?

    response = @client.chat(parameters: chat_parameters)
    content = response.dig("choices", 0, "message", "content")
    parsed = JSON.parse(content.to_s)

    KEYS.each_with_object({}) do |key, roasts|
      value = parsed[key]
      roasts[key.to_sym] = value if value.is_a?(String) && value.strip.present?
    end
  rescue JSON::ParserError, StandardError => e
    Rails.logger.error("RoastGenerator failed: #{e.class}: #{e.message}")
    {}
  end

  def self.default_client
    return nil if ENV["OPENAI_API_KEY"].blank?
    OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
  end

  private

  def chat_parameters
    {
      model: MODEL,
      temperature: TEMPERATURE,
      response_format: { type: "json_object" },
      messages: [
        { role: "system", content: SYSTEM_PROMPT },
        { role: "user", content: user_prompt }
      ]
    }
  end

  def user_prompt
    m = @stats.metrics
    lines = [
      "Here are my last 30 days of workouts. Roast me.",
      "",
      "- Workout count: #{m[:workout_count]}",
      "- Total duration: #{format_duration(m[:total_duration_seconds])}",
      "- Favorite workout type: #{m[:favorite_type] || 'none'} (#{m[:favorite_type_count]} sessions)",
      "- Longest session: #{m[:longest_name] || 'none'} at #{format_duration(m[:longest_duration_seconds])}",
      "- Calories burned: #{m[:total_calories_kcal]} kcal",
      "- Distance covered: #{(m[:total_distance_meters].to_f / 1000).round(1)} km",
      "- Average heart rate: #{m[:avg_heart_rate_bpm] ? "#{m[:avg_heart_rate_bpm]} bpm" : 'unknown'}",
      "",
      "Return 4 roasts as JSON with exactly these keys:",
      "- summary: roast about the overall workout count and time spent",
      "- most_common_type: roast about the favorite workout type",
      "- longest_workout: roast about the longest session",
      "- totals: roast about the calories, distance, and heart rate totals"
    ]
    lines.join("\n")
  end

  def format_duration(seconds)
    return "0m" if seconds.to_i.zero?
    h, rem = seconds.to_i.divmod(3600)
    m, _ = rem.divmod(60)
    h.positive? ? "#{h}h #{m}m" : "#{m}m"
  end
end
