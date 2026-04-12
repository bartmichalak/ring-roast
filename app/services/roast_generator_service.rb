class RoastGeneratorService
  def initialize(stats, client: nil)
    @stats = stats
    @client = client
  end

  def call
    return {} if @stats[:empty]

    client = @client || OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))

    response = client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [
          { role: "system", content: system_prompt },
          { role: "user", content: user_prompt }
        ],
        temperature: 0.9
      }
    )

    parse_response(response)
  rescue => e
    Rails.logger.error("OpenAI error: #{e.message}")
    {}
  end

  private

  def system_prompt
    <<~PROMPT
      You are a savage but funny fitness roast comedian. You roast people based on their workout data.
      Keep roasts short (1-2 sentences max), punchy, and hilarious. Be creative and brutal but not mean-spirited.
      Respond in valid JSON with exactly these keys: summary, most_common_type, longest_workout, totals.
      Each value should be a short roast string. No markdown, no code blocks, just raw JSON.
    PROMPT
  end

  def user_prompt
    summary = @stats[:summary]
    common = @stats[:most_common_type]
    longest = @stats[:longest_workout]
    totals = @stats[:totals]

    <<~PROMPT
      Roast this person's workout data from the last #{summary[:period_days]} days:

      - Total workouts: #{summary[:total_count]} (#{summary[:total_duration_formatted]} total)
      - Favorite workout: #{common[:type]} (#{common[:count]} times, #{common[:percentage]}% of all workouts)
      - Longest session: #{longest[:name]} - #{longest[:duration_formatted]} on #{longest[:date]}
      - Total calories: #{totals[:total_calories_kcal]} kcal
      - Total distance: #{totals[:total_distance_km]} km
      - Average heart rate: #{totals[:avg_heart_rate_bpm] || "unknown"} bpm

      Generate 4 roasts:
      1. "summary" - roast their overall workout count and time
      2. "most_common_type" - roast their favorite workout type
      3. "longest_workout" - roast their longest session
      4. "totals" - roast their total calories/distance numbers
    PROMPT
  end

  def parse_response(response)
    content = response.dig("choices", 0, "message", "content")
    return {} unless content

    parsed = JSON.parse(content)
    {
      summary: parsed["summary"],
      most_common_type: parsed["most_common_type"],
      longest_workout: parsed["longest_workout"],
      totals: parsed["totals"]
    }
  rescue JSON::ParserError => e
    Rails.logger.error("Failed to parse OpenAI response: #{e.message}")
    {}
  end
end
