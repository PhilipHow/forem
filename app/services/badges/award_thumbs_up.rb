module Badges
  class AwardThumbsUp
    # THUMBS_UP_BADGES = [
    #     { value: 100,	badge: "100-thumbs-up-milestone" },
    #     { value: 500, badge: "500-thumbs-up-milestone" },
    #     { value: 1000, badge: "1-2c000-thumbs-up-milestone" },
    #     { value: 5000, badge: "5-2c000-thumbs-up-milestone	badge" },
    #     { value: 10_000, badge: "10-2c000-thumbs-up-milestone" },
    #   ].freeze

    THUMBS_UP_BADGES = {
      100 => "100-thumbs-up-milestone",
      500 => "500-thumbs-up-milestone",
      1000 => "1-2c000-thumbs-up-milestone",
      5000 => "5-2c000-thumbs-up-milestone",
      10_000 => "10-2c000-thumbs-up-milestone"
    }.freeze

    MIN_THRESHOLD = THUMBS_UP_BADGES.keys.min
    # THUMBS_UP_BADGE_SLUGS = THUMBS_UP_BADGES.values

    def self.call
      user_thumbsup_counts = Reaction
        .where(category: "thumbsup", reactable_type: "Article")
        .group(:user_id)
        .having("COUNT(*) >= ?", MIN_THRESHOLD)
        .order(Arel.sql("COUNT(*) DESC"))
        .count

      user_thumbsup_counts.each do |user_thumbsup_count|
        THUMBS_UP_BADGES.each do |threshold, badge_slug|
          break unless user_thumbsup_count.count >= threshold
          next unless (badge_id = Badge.id_for_slug(badge_slug))

          user.badge_achievements.create(
            badge_id: badge_id,
            rewarding_context_message_markdown: generate_message(threshold: threshold),
          )
        end
      end
    end

    def self.generate_message(threshold:)
      I18n.t("services.badges.thumbs_up", threshold)
    end
  end
end
