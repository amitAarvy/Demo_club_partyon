class InstagramURL {

  static String usernameURL = 'https://api.insightiq.ai/v1/accounts';
  static String publicAnalyticsOfAProfileDataURL =
      'https://api.insightiq.ai/v1/social/creators/profiles/analytics';
  static String getProfileDataURL =
      'https://api.insightiq.ai/v1/social/creators/profiles/analytics';
  static String getAllContentItemsURL =
      'https://api.insightiq.ai/v1/social/contents';

  static String analyticsDataURL =
      'https://api.insightiq.ai/v1/professional/creators/profiles/analytics';

  static String getIGAccountDetailsURL =
      'https://api.insightiq.ai/v1/profiles';
  static String audienceDemographicsURL =
      'https://api.insightiq.ai/v1/profiles/a072af5d-367b-4c81-a401-d4f0bb3b5fa2';

  static String get baseURL => 'https://graph.facebook.com';

  static String get versionURL => '/v21.0';

  static String storyMetrics =
      'impressions,reach,replies,follows,navigation,profile_activity,profile_visits,shares,total_interactions';
  static String storyBreakdown = 'story_navigation_action_type,action_type';

  static String postMetrics =
      'impressions,reach,saved,comments,follows,likes,profile_visits,total_interactions';

  static String postBreakdown = 'action_type';

  static String reelsMetric =
      'clips_replays_count,plays,comments,likes,reach,saved,ig_reels_aggregated_all_plays_count,clips_replays_count';

  static String getInstaData(String accessToken) =>
      '$baseURL$versionURL/me/accounts?fields=instagram_business_account{id,name,username,profile_picture_url,media{comments_count,like_count,play_count,media_url,media_type,thumbnail_url}}&access_token=$accessToken';

  static String getMediaData(String mediaId, String accessToken) =>
      '$baseURL$versionURL/$mediaId/insights?metric=impressions,reach,saved,follows,profile_visits,shares,likes,comments,total_interactions&access_token=$accessToken';

  static String getPostData(String igUserId, String accessToken) =>
      '$baseURL$versionURL/$igUserId/insights?metric=$postMetrics&breakdown=$postBreakdown&access_token=$accessToken';

  static String getStoryData(String igUserId, String accessToken) =>
      '$baseURL$versionURL/$igUserId/insights?metric=$storyMetrics&breakdown=$storyBreakdown&access_token=$accessToken';

  static String getReelsData(String igUserId, String accessToken) =>
      '$baseURL$versionURL/$igUserId/insights?metric=$reelsMetric&access_token=$accessToken';

  // static String getDemographicsData(String igUserId, String accessToken) =>
  //     '$baseURL$versionURL/$igUserId/metric=engaged_audience_demographics,reached_audience_demographics,follower_demographics&period=lifetime&timeframe=this_week&breakdown=age,city,country,gender&metric_type=total_value&access_token=$accessToken';

  static String getEngagedAudienceDemographicsData(
          String igUserId, String accessToken, String breakdown) =>
      '$baseURL$versionURL/$igUserId/insights?metric=engaged_audience_demographics&breakdown=$breakdown&period=lifetime&timeframe=this_week&metric_type=total_value&access_token=$accessToken';

  static String getFollowers(String igUserId, String accessToken) =>
      '$baseURL$versionURL/$igUserId/follows_and_unfollows&period=day&breakdown=follow_type&metric_type=total_value&access_token=$accessToken';
}
