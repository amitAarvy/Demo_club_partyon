// /// value : {"id":"string","created_at":"string","updated_at":"string","work_platform":{"id":"string","name":"string","logo_url":"string"},"is_creator":true,"is_influencer":true,"skills":["string"],"first_name":"string","middle_name":"string","sales_id":"string","sales_link":"string","last_name":"string","platform_username":"string","profile_summary":"string","platform_account_type":["string"],"url":"string","profile_headline":"string","image_url":"string","industry":"string","follower_count":0,"average_likes":0,"average_comments":0,"average_shares":0,"engagement_rate":0,"languages":["string"],"reputation":{"follower_count":0,"connection_count":0},"location":{"name":"string","country":"string","country_name":"string","city":"string","state":"string"},"contact_details":[{"type":"string","value":"string"}],"top_contents":[{"type":"string","url":"string","description":"string","thumbnail_url":null,"engagement":{"like_count":0,"comment_count":0},"published_at":"string"}],"recent_contents":[{"type":"string","url":"string","description":"string","thumbnail_url":null,"engagement":{"like_count":0,"comment_count":0},"published_at":"string"}],"top_hashtags":[{"name":"string"}],"top_mentions":[{"name":"string"}],"talks_about":[{"name":"string"}],"work_experiences":{"title":"string","company":{"name":"string","industries":[null],"logo_url":"string","employee_count":{"min":0,"max":0}},"description":"string","time_period":{"start_date":{"month":0,"year":0},"end_date":{"month":0,"year":0}},"location":{"name":null,"country":"string","country_name":null,"city":"string","state":"string"}},"education":{"degree":"string","field_study":["string"],"grade":null,"school":{"name":"string","logo_url":null},"description":"string","time_period":{"start_date":{"month":0,"year":0},"end_date":{"month":0,"year":0}},"activities":"string"},"publications":[{}],"certifications":[{}],"volunteer_experiences":[{}],"people_also_viewed":[{"last_name":"string","first_name":"string","profile_headline":"string","entity_urn":"string","public_identifier":"string","premium":true,"image_url":"string","url":"string","reputation":{"follower_count":0}}],"honors":[{}],"projects":[{}],"external_id":"string","patents":[{}],"recommendations_received":[{"name":"string","subtitle":"string","date":"string","context":"string","description":"string","urn":"string","url":"string"}],"recommendations_given":[{"name":"string","subtitle":"string","date":"string","context":"string","urn":"string","url":"string"}]}
//
// class PublicAnalyticsProfessionalProfile {
//   PublicAnalyticsProfessionalProfile({
//       Value? value,}){
//     _value = value;
// }
//
//   PublicAnalyticsProfessionalProfile.fromJson(dynamic json) {
//     _value = json['value'] != null ? Value.fromJson(json['value']) : null;
//   }
//   Value? _value;
// PublicAnalyticsProfessionalProfile copyWith({  Value? value,
// }) => PublicAnalyticsProfessionalProfile(  value: value ?? _value,
// );
//   Value? get value => _value;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     if (_value != null) {
//       map['value'] = _value?.toJson();
//     }
//     return map;
//   }
//
// }
//
// /// id : "string"
// /// created_at : "string"
// /// updated_at : "string"
// /// work_platform : {"id":"string","name":"string","logo_url":"string"}
// /// is_creator : true
// /// is_influencer : true
// /// skills : ["string"]
// /// first_name : "string"
// /// middle_name : "string"
// /// sales_id : "string"
// /// sales_link : "string"
// /// last_name : "string"
// /// platform_username : "string"
// /// profile_summary : "string"
// /// platform_account_type : ["string"]
// /// url : "string"
// /// profile_headline : "string"
// /// image_url : "string"
// /// industry : "string"
// /// follower_count : 0
// /// average_likes : 0
// /// average_comments : 0
// /// average_shares : 0
// /// engagement_rate : 0
// /// languages : ["string"]
// /// reputation : {"follower_count":0,"connection_count":0}
// /// location : {"name":"string","country":"string","country_name":"string","city":"string","state":"string"}
// /// contact_details : [{"type":"string","value":"string"}]
// /// top_contents : [{"type":"string","url":"string","description":"string","thumbnail_url":null,"engagement":{"like_count":0,"comment_count":0},"published_at":"string"}]
// /// recent_contents : [{"type":"string","url":"string","description":"string","thumbnail_url":null,"engagement":{"like_count":0,"comment_count":0},"published_at":"string"}]
// /// top_hashtags : [{"name":"string"}]
// /// top_mentions : [{"name":"string"}]
// /// talks_about : [{"name":"string"}]
// /// work_experiences : {"title":"string","company":{"name":"string","industries":[null],"logo_url":"string","employee_count":{"min":0,"max":0}},"description":"string","time_period":{"start_date":{"month":0,"year":0},"end_date":{"month":0,"year":0}},"location":{"name":null,"country":"string","country_name":null,"city":"string","state":"string"}}
// /// education : {"degree":"string","field_study":["string"],"grade":null,"school":{"name":"string","logo_url":null},"description":"string","time_period":{"start_date":{"month":0,"year":0},"end_date":{"month":0,"year":0}},"activities":"string"}
// /// publications : [{}]
// /// certifications : [{}]
// /// volunteer_experiences : [{}]
// /// people_also_viewed : [{"last_name":"string","first_name":"string","profile_headline":"string","entity_urn":"string","public_identifier":"string","premium":true,"image_url":"string","url":"string","reputation":{"follower_count":0}}]
// /// honors : [{}]
// /// projects : [{}]
// /// external_id : "string"
// /// patents : [{}]
// /// recommendations_received : [{"name":"string","subtitle":"string","date":"string","context":"string","description":"string","urn":"string","url":"string"}]
// /// recommendations_given : [{"name":"string","subtitle":"string","date":"string","context":"string","urn":"string","url":"string"}]
//
// class Value {
//   Value({
//       String? id,
//       String? createdAt,
//       String? updatedAt,
//       WorkPlatform? workPlatform,
//       bool? isCreator,
//       bool? isInfluencer,
//       List<String>? skills,
//       String? firstName,
//       String? middleName,
//       String? salesId,
//       String? salesLink,
//       String? lastName,
//       String? platformUsername,
//       String? profileSummary,
//       List<String>? platformAccountType,
//       String? url,
//       String? profileHeadline,
//       String? imageUrl,
//       String? industry,
//       num? followerCount,
//       num? averageLikes,
//       num? averageComments,
//       num? averageShares,
//       num? engagementRate,
//       List<String>? languages,
//       Reputation? reputation,
//       Location? location,
//       List<ContactDetails>? contactDetails,
//       List<TopContents>? topContents,
//       List<RecentContents>? recentContents,
//       List<TopHashtags>? topHashtags,
//       List<TopMentions>? topMentions,
//       List<TalksAbout>? talksAbout,
//       WorkExperiences? workExperiences,
//       Education? education,
//       List<dynamic>? publications,
//       List<dynamic>? certifications,
//       List<dynamic>? volunteerExperiences,
//       List<PeopleAlsoViewed>? peopleAlsoViewed,
//       List<dynamic>? honors,
//       List<dynamic>? projects,
//       String? externalId,
//       List<dynamic>? patents,
//       List<RecommendationsReceived>? recommendationsReceived,
//       List<RecommendationsGiven>? recommendationsGiven,}){
//     _id = id;
//     _createdAt = createdAt;
//     _updatedAt = updatedAt;
//     _workPlatform = workPlatform;
//     _isCreator = isCreator;
//     _isInfluencer = isInfluencer;
//     _skills = skills;
//     _firstName = firstName;
//     _middleName = middleName;
//     _salesId = salesId;
//     _salesLink = salesLink;
//     _lastName = lastName;
//     _platformUsername = platformUsername;
//     _profileSummary = profileSummary;
//     _platformAccountType = platformAccountType;
//     _url = url;
//     _profileHeadline = profileHeadline;
//     _imageUrl = imageUrl;
//     _industry = industry;
//     _followerCount = followerCount;
//     _averageLikes = averageLikes;
//     _averageComments = averageComments;
//     _averageShares = averageShares;
//     _engagementRate = engagementRate;
//     _languages = languages;
//     _reputation = reputation;
//     _location = location;
//     _contactDetails = contactDetails;
//     _topContents = topContents;
//     _recentContents = recentContents;
//     _topHashtags = topHashtags;
//     _topMentions = topMentions;
//     _talksAbout = talksAbout;
//     _workExperiences = workExperiences;
//     _education = education;
//     _publications = publications;
//     _certifications = certifications;
//     _volunteerExperiences = volunteerExperiences;
//     _peopleAlsoViewed = peopleAlsoViewed;
//     _honors = honors;
//     _projects = projects;
//     _externalId = externalId;
//     _patents = patents;
//     _recommendationsReceived = recommendationsReceived;
//     _recommendationsGiven = recommendationsGiven;
// }
//
//   Value.fromJson(dynamic json) {
//     _id = json['id'];
//     _createdAt = json['created_at'];
//     _updatedAt = json['updated_at'];
//     _workPlatform = json['work_platform'] != null ? WorkPlatform.fromJson(json['work_platform']) : null;
//     _isCreator = json['is_creator'];
//     _isInfluencer = json['is_influencer'];
//     _skills = json['skills'] != null ? json['skills'].cast<String>() : [];
//     _firstName = json['first_name'];
//     _middleName = json['middle_name'];
//     _salesId = json['sales_id'];
//     _salesLink = json['sales_link'];
//     _lastName = json['last_name'];
//     _platformUsername = json['platform_username'];
//     _profileSummary = json['profile_summary'];
//     _platformAccountType = json['platform_account_type'] != null ? json['platform_account_type'].cast<String>() : [];
//     _url = json['url'];
//     _profileHeadline = json['profile_headline'];
//     _imageUrl = json['image_url'];
//     _industry = json['industry'];
//     _followerCount = json['follower_count'];
//     _averageLikes = json['average_likes'];
//     _averageComments = json['average_comments'];
//     _averageShares = json['average_shares'];
//     _engagementRate = json['engagement_rate'];
//     _languages = json['languages'] != null ? json['languages'].cast<String>() : [];
//     _reputation = json['reputation'] != null ? Reputation.fromJson(json['reputation']) : null;
//     _location = json['location'] != null ? Location.fromJson(json['location']) : null;
//     if (json['contact_details'] != null) {
//       _contactDetails = [];
//       json['contact_details'].forEach((v) {
//         _contactDetails?.add(ContactDetails.fromJson(v));
//       });
//     }
//     if (json['top_contents'] != null) {
//       _topContents = [];
//       json['top_contents'].forEach((v) {
//         _topContents?.add(TopContents.fromJson(v));
//       });
//     }
//     if (json['recent_contents'] != null) {
//       _recentContents = [];
//       json['recent_contents'].forEach((v) {
//         _recentContents?.add(RecentContents.fromJson(v));
//       });
//     }
//     if (json['top_hashtags'] != null) {
//       _topHashtags = [];
//       json['top_hashtags'].forEach((v) {
//         _topHashtags?.add(TopHashtags.fromJson(v));
//       });
//     }
//     if (json['top_mentions'] != null) {
//       _topMentions = [];
//       json['top_mentions'].forEach((v) {
//         _topMentions?.add(TopMentions.fromJson(v));
//       });
//     }
//     if (json['talks_about'] != null) {
//       _talksAbout = [];
//       json['talks_about'].forEach((v) {
//         _talksAbout?.add(TalksAbout.fromJson(v));
//       });
//     }
//     _workExperiences = json['work_experiences'] != null ? WorkExperiences.fromJson(json['work_experiences']) : null;
//     _education = json['education'] != null ? Education.fromJson(json['education']) : null;
//     if (json['publications'] != null) {
//       _publications = [];
//       json['publications'].forEach((v) {
//         _publications?.add(v);
//       });
//     }
//     if (json['certifications'] != null) {
//       _certifications = [];
//       json['certifications'].forEach((v) {
//         _certifications?.add(v);
//       });
//     }
//     if (json['volunteer_experiences'] != null) {
//       _volunteerExperiences = [];
//       json['volunteer_experiences'].forEach((v) {
//         _volunteerExperiences?.add(v);
//       });
//     }
//     if (json['people_also_viewed'] != null) {
//       _peopleAlsoViewed = [];
//       json['people_also_viewed'].forEach((v) {
//         _peopleAlsoViewed?.add(PeopleAlsoViewed.fromJson(v));
//       });
//     }
//     if (json['honors'] != null) {
//       _honors = [];
//       json['honors'].forEach((v) {
//         _honors?.add(v);
//       });
//     }
//     if (json['projects'] != null) {
//       _projects = [];
//       json['projects'].forEach((v) {
//         _projects?.add(v);
//       });
//     }
//     _externalId = json['external_id'];
//     if (json['patents'] != null) {
//       _patents = [];
//       json['patents'].forEach((v) {
//         _patents?.add(v);
//       });
//     }
//     if (json['recommendations_received'] != null) {
//       _recommendationsReceived = [];
//       json['recommendations_received'].forEach((v) {
//         _recommendationsReceived?.add(RecommendationsReceived.fromJson(v));
//       });
//     }
//     if (json['recommendations_given'] != null) {
//       _recommendationsGiven = [];
//       json['recommendations_given'].forEach((v) {
//         _recommendationsGiven?.add(RecommendationsGiven.fromJson(v));
//       });
//     }
//   }
//   String? _id;
//   String? _createdAt;
//   String? _updatedAt;
//   WorkPlatform? _workPlatform;
//   bool? _isCreator;
//   bool? _isInfluencer;
//   List<String>? _skills;
//   String? _firstName;
//   String? _middleName;
//   String? _salesId;
//   String? _salesLink;
//   String? _lastName;
//   String? _platformUsername;
//   String? _profileSummary;
//   List<String>? _platformAccountType;
//   String? _url;
//   String? _profileHeadline;
//   String? _imageUrl;
//   String? _industry;
//   num? _followerCount;
//   num? _averageLikes;
//   num? _averageComments;
//   num? _averageShares;
//   num? _engagementRate;
//   List<String>? _languages;
//   Reputation? _reputation;
//   Location? _location;
//   List<ContactDetails>? _contactDetails;
//   List<TopContents>? _topContents;
//   List<RecentContents>? _recentContents;
//   List<TopHashtags>? _topHashtags;
//   List<TopMentions>? _topMentions;
//   List<TalksAbout>? _talksAbout;
//   WorkExperiences? _workExperiences;
//   Education? _education;
//   List<dynamic>? _publications;
//   List<dynamic>? _certifications;
//   List<dynamic>? _volunteerExperiences;
//   List<PeopleAlsoViewed>? _peopleAlsoViewed;
//   List<dynamic>? _honors;
//   List<dynamic>? _projects;
//   String? _externalId;
//   List<dynamic>? _patents;
//   List<RecommendationsReceived>? _recommendationsReceived;
//   List<RecommendationsGiven>? _recommendationsGiven;
// Value copyWith({  String? id,
//   String? createdAt,
//   String? updatedAt,
//   WorkPlatform? workPlatform,
//   bool? isCreator,
//   bool? isInfluencer,
//   List<String>? skills,
//   String? firstName,
//   String? middleName,
//   String? salesId,
//   String? salesLink,
//   String? lastName,
//   String? platformUsername,
//   String? profileSummary,
//   List<String>? platformAccountType,
//   String? url,
//   String? profileHeadline,
//   String? imageUrl,
//   String? industry,
//   num? followerCount,
//   num? averageLikes,
//   num? averageComments,
//   num? averageShares,
//   num? engagementRate,
//   List<String>? languages,
//   Reputation? reputation,
//   Location? location,
//   List<ContactDetails>? contactDetails,
//   List<TopContents>? topContents,
//   List<RecentContents>? recentContents,
//   List<TopHashtags>? topHashtags,
//   List<TopMentions>? topMentions,
//   List<TalksAbout>? talksAbout,
//   WorkExperiences? workExperiences,
//   Education? education,
//   List<dynamic>? publications,
//   List<dynamic>? certifications,
//   List<dynamic>? volunteerExperiences,
//   List<PeopleAlsoViewed>? peopleAlsoViewed,
//   List<dynamic>? honors,
//   List<dynamic>? projects,
//   String? externalId,
//   List<dynamic>? patents,
//   List<RecommendationsReceived>? recommendationsReceived,
//   List<RecommendationsGiven>? recommendationsGiven,
// }) => Value(  id: id ?? _id,
//   createdAt: createdAt ?? _createdAt,
//   updatedAt: updatedAt ?? _updatedAt,
//   workPlatform: workPlatform ?? _workPlatform,
//   isCreator: isCreator ?? _isCreator,
//   isInfluencer: isInfluencer ?? _isInfluencer,
//   skills: skills ?? _skills,
//   firstName: firstName ?? _firstName,
//   middleName: middleName ?? _middleName,
//   salesId: salesId ?? _salesId,
//   salesLink: salesLink ?? _salesLink,
//   lastName: lastName ?? _lastName,
//   platformUsername: platformUsername ?? _platformUsername,
//   profileSummary: profileSummary ?? _profileSummary,
//   platformAccountType: platformAccountType ?? _platformAccountType,
//   url: url ?? _url,
//   profileHeadline: profileHeadline ?? _profileHeadline,
//   imageUrl: imageUrl ?? _imageUrl,
//   industry: industry ?? _industry,
//   followerCount: followerCount ?? _followerCount,
//   averageLikes: averageLikes ?? _averageLikes,
//   averageComments: averageComments ?? _averageComments,
//   averageShares: averageShares ?? _averageShares,
//   engagementRate: engagementRate ?? _engagementRate,
//   languages: languages ?? _languages,
//   reputation: reputation ?? _reputation,
//   location: location ?? _location,
//   contactDetails: contactDetails ?? _contactDetails,
//   topContents: topContents ?? _topContents,
//   recentContents: recentContents ?? _recentContents,
//   topHashtags: topHashtags ?? _topHashtags,
//   topMentions: topMentions ?? _topMentions,
//   talksAbout: talksAbout ?? _talksAbout,
//   workExperiences: workExperiences ?? _workExperiences,
//   education: education ?? _education,
//   publications: publications ?? _publications,
//   certifications: certifications ?? _certifications,
//   volunteerExperiences: volunteerExperiences ?? _volunteerExperiences,
//   peopleAlsoViewed: peopleAlsoViewed ?? _peopleAlsoViewed,
//   honors: honors ?? _honors,
//   projects: projects ?? _projects,
//   externalId: externalId ?? _externalId,
//   patents: patents ?? _patents,
//   recommendationsReceived: recommendationsReceived ?? _recommendationsReceived,
//   recommendationsGiven: recommendationsGiven ?? _recommendationsGiven,
// );
//   String? get id => _id;
//   String? get createdAt => _createdAt;
//   String? get updatedAt => _updatedAt;
//   WorkPlatform? get workPlatform => _workPlatform;
//   bool? get isCreator => _isCreator;
//   bool? get isInfluencer => _isInfluencer;
//   List<String>? get skills => _skills;
//   String? get firstName => _firstName;
//   String? get middleName => _middleName;
//   String? get salesId => _salesId;
//   String? get salesLink => _salesLink;
//   String? get lastName => _lastName;
//   String? get platformUsername => _platformUsername;
//   String? get profileSummary => _profileSummary;
//   List<String>? get platformAccountType => _platformAccountType;
//   String? get url => _url;
//   String? get profileHeadline => _profileHeadline;
//   String? get imageUrl => _imageUrl;
//   String? get industry => _industry;
//   num? get followerCount => _followerCount;
//   num? get averageLikes => _averageLikes;
//   num? get averageComments => _averageComments;
//   num? get averageShares => _averageShares;
//   num? get engagementRate => _engagementRate;
//   List<String>? get languages => _languages;
//   Reputation? get reputation => _reputation;
//   Location? get location => _location;
//   List<ContactDetails>? get contactDetails => _contactDetails;
//   List<TopContents>? get topContents => _topContents;
//   List<RecentContents>? get recentContents => _recentContents;
//   List<TopHashtags>? get topHashtags => _topHashtags;
//   List<TopMentions>? get topMentions => _topMentions;
//   List<TalksAbout>? get talksAbout => _talksAbout;
//   WorkExperiences? get workExperiences => _workExperiences;
//   Education? get education => _education;
//   List<dynamic>? get publications => _publications;
//   List<dynamic>? get certifications => _certifications;
//   List<dynamic>? get volunteerExperiences => _volunteerExperiences;
//   List<PeopleAlsoViewed>? get peopleAlsoViewed => _peopleAlsoViewed;
//   List<dynamic>? get honors => _honors;
//   List<dynamic>? get projects => _projects;
//   String? get externalId => _externalId;
//   List<dynamic>? get patents => _patents;
//   List<RecommendationsReceived>? get recommendationsReceived => _recommendationsReceived;
//   List<RecommendationsGiven>? get recommendationsGiven => _recommendationsGiven;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['id'] = _id;
//     map['created_at'] = _createdAt;
//     map['updated_at'] = _updatedAt;
//     if (_workPlatform != null) {
//       map['work_platform'] = _workPlatform?.toJson();
//     }
//     map['is_creator'] = _isCreator;
//     map['is_influencer'] = _isInfluencer;
//     map['skills'] = _skills;
//     map['first_name'] = _firstName;
//     map['middle_name'] = _middleName;
//     map['sales_id'] = _salesId;
//     map['sales_link'] = _salesLink;
//     map['last_name'] = _lastName;
//     map['platform_username'] = _platformUsername;
//     map['profile_summary'] = _profileSummary;
//     map['platform_account_type'] = _platformAccountType;
//     map['url'] = _url;
//     map['profile_headline'] = _profileHeadline;
//     map['image_url'] = _imageUrl;
//     map['industry'] = _industry;
//     map['follower_count'] = _followerCount;
//     map['average_likes'] = _averageLikes;
//     map['average_comments'] = _averageComments;
//     map['average_shares'] = _averageShares;
//     map['engagement_rate'] = _engagementRate;
//     map['languages'] = _languages;
//     if (_reputation != null) {
//       map['reputation'] = _reputation?.toJson();
//     }
//     if (_location != null) {
//       map['location'] = _location?.toJson();
//     }
//     if (_contactDetails != null) {
//       map['contact_details'] = _contactDetails?.map((v) => v.toJson()).toList();
//     }
//     if (_topContents != null) {
//       map['top_contents'] = _topContents?.map((v) => v.toJson()).toList();
//     }
//     if (_recentContents != null) {
//       map['recent_contents'] = _recentContents?.map((v) => v.toJson()).toList();
//     }
//     if (_topHashtags != null) {
//       map['top_hashtags'] = _topHashtags?.map((v) => v.toJson()).toList();
//     }
//     if (_topMentions != null) {
//       map['top_mentions'] = _topMentions?.map((v) => v.toJson()).toList();
//     }
//     if (_talksAbout != null) {
//       map['talks_about'] = _talksAbout?.map((v) => v.toJson()).toList();
//     }
//     if (_workExperiences != null) {
//       map['work_experiences'] = _workExperiences?.toJson();
//     }
//     if (_education != null) {
//       map['education'] = _education?.toJson();
//     }
//     if (_publications != null) {
//       map['publications'] = _publications?.map((v) => v.toJson()).toList();
//     }
//     if (_certifications != null) {
//       map['certifications'] = _certifications?.map((v) => v.toJson()).toList();
//     }
//     if (_volunteerExperiences != null) {
//       map['volunteer_experiences'] = _volunteerExperiences?.map((v) => v.toJson()).toList();
//     }
//     if (_peopleAlsoViewed != null) {
//       map['people_also_viewed'] = _peopleAlsoViewed?.map((v) => v.toJson()).toList();
//     }
//     if (_honors != null) {
//       map['honors'] = _honors?.map((v) => v.toJson()).toList();
//     }
//     if (_projects != null) {
//       map['projects'] = _projects?.map((v) => v.toJson()).toList();
//     }
//     map['external_id'] = _externalId;
//     if (_patents != null) {
//       map['patents'] = _patents?.map((v) => v.toJson()).toList();
//     }
//     if (_recommendationsReceived != null) {
//       map['recommendations_received'] = _recommendationsReceived?.map((v) => v.toJson()).toList();
//     }
//     if (_recommendationsGiven != null) {
//       map['recommendations_given'] = _recommendationsGiven?.map((v) => v.toJson()).toList();
//     }
//     return map;
//   }
//
// }
//
// /// name : "string"
// /// subtitle : "string"
// /// date : "string"
// /// context : "string"
// /// urn : "string"
// /// url : "string"
//
// class RecommendationsGiven {
//   RecommendationsGiven({
//       String? name,
//       String? subtitle,
//       String? date,
//       String? context,
//       String? urn,
//       String? url,}){
//     _name = name;
//     _subtitle = subtitle;
//     _date = date;
//     _context = context;
//     _urn = urn;
//     _url = url;
// }
//
//   RecommendationsGiven.fromJson(dynamic json) {
//     _name = json['name'];
//     _subtitle = json['subtitle'];
//     _date = json['date'];
//     _context = json['context'];
//     _urn = json['urn'];
//     _url = json['url'];
//   }
//   String? _name;
//   String? _subtitle;
//   String? _date;
//   String? _context;
//   String? _urn;
//   String? _url;
// RecommendationsGiven copyWith({  String? name,
//   String? subtitle,
//   String? date,
//   String? context,
//   String? urn,
//   String? url,
// }) => RecommendationsGiven(  name: name ?? _name,
//   subtitle: subtitle ?? _subtitle,
//   date: date ?? _date,
//   context: context ?? _context,
//   urn: urn ?? _urn,
//   url: url ?? _url,
// );
//   String? get name => _name;
//   String? get subtitle => _subtitle;
//   String? get date => _date;
//   String? get context => _context;
//   String? get urn => _urn;
//   String? get url => _url;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['name'] = _name;
//     map['subtitle'] = _subtitle;
//     map['date'] = _date;
//     map['context'] = _context;
//     map['urn'] = _urn;
//     map['url'] = _url;
//     return map;
//   }
//
// }
//
// /// name : "string"
// /// subtitle : "string"
// /// date : "string"
// /// context : "string"
// /// description : "string"
// /// urn : "string"
// /// url : "string"
//
// class RecommendationsReceived {
//   RecommendationsReceived({
//       String? name,
//       String? subtitle,
//       String? date,
//       String? context,
//       String? description,
//       String? urn,
//       String? url,}){
//     _name = name;
//     _subtitle = subtitle;
//     _date = date;
//     _context = context;
//     _description = description;
//     _urn = urn;
//     _url = url;
// }
//
//   RecommendationsReceived.fromJson(dynamic json) {
//     _name = json['name'];
//     _subtitle = json['subtitle'];
//     _date = json['date'];
//     _context = json['context'];
//     _description = json['description'];
//     _urn = json['urn'];
//     _url = json['url'];
//   }
//   String? _name;
//   String? _subtitle;
//   String? _date;
//   String? _context;
//   String? _description;
//   String? _urn;
//   String? _url;
// RecommendationsReceived copyWith({  String? name,
//   String? subtitle,
//   String? date,
//   String? context,
//   String? description,
//   String? urn,
//   String? url,
// }) => RecommendationsReceived(  name: name ?? _name,
//   subtitle: subtitle ?? _subtitle,
//   date: date ?? _date,
//   context: context ?? _context,
//   description: description ?? _description,
//   urn: urn ?? _urn,
//   url: url ?? _url,
// );
//   String? get name => _name;
//   String? get subtitle => _subtitle;
//   String? get date => _date;
//   String? get context => _context;
//   String? get description => _description;
//   String? get urn => _urn;
//   String? get url => _url;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['name'] = _name;
//     map['subtitle'] = _subtitle;
//     map['date'] = _date;
//     map['context'] = _context;
//     map['description'] = _description;
//     map['urn'] = _urn;
//     map['url'] = _url;
//     return map;
//   }
//
// }
//
// /// last_name : "string"
// /// first_name : "string"
// /// profile_headline : "string"
// /// entity_urn : "string"
// /// public_identifier : "string"
// /// premium : true
// /// image_url : "string"
// /// url : "string"
// /// reputation : {"follower_count":0}
//
// class PeopleAlsoViewed {
//   PeopleAlsoViewed({
//       String? lastName,
//       String? firstName,
//       String? profileHeadline,
//       String? entityUrn,
//       String? publicIdentifier,
//       bool? premium,
//       String? imageUrl,
//       String? url,
//       Reputation? reputation,}){
//     _lastName = lastName;
//     _firstName = firstName;
//     _profileHeadline = profileHeadline;
//     _entityUrn = entityUrn;
//     _publicIdentifier = publicIdentifier;
//     _premium = premium;
//     _imageUrl = imageUrl;
//     _url = url;
//     _reputation = reputation;
// }
//
//   PeopleAlsoViewed.fromJson(dynamic json) {
//     _lastName = json['last_name'];
//     _firstName = json['first_name'];
//     _profileHeadline = json['profile_headline'];
//     _entityUrn = json['entity_urn'];
//     _publicIdentifier = json['public_identifier'];
//     _premium = json['premium'];
//     _imageUrl = json['image_url'];
//     _url = json['url'];
//     _reputation = json['reputation'] != null ? Reputation.fromJson(json['reputation']) : null;
//   }
//   String? _lastName;
//   String? _firstName;
//   String? _profileHeadline;
//   String? _entityUrn;
//   String? _publicIdentifier;
//   bool? _premium;
//   String? _imageUrl;
//   String? _url;
//   Reputation? _reputation;
// PeopleAlsoViewed copyWith({  String? lastName,
//   String? firstName,
//   String? profileHeadline,
//   String? entityUrn,
//   String? publicIdentifier,
//   bool? premium,
//   String? imageUrl,
//   String? url,
//   Reputation? reputation,
// }) => PeopleAlsoViewed(  lastName: lastName ?? _lastName,
//   firstName: firstName ?? _firstName,
//   profileHeadline: profileHeadline ?? _profileHeadline,
//   entityUrn: entityUrn ?? _entityUrn,
//   publicIdentifier: publicIdentifier ?? _publicIdentifier,
//   premium: premium ?? _premium,
//   imageUrl: imageUrl ?? _imageUrl,
//   url: url ?? _url,
//   reputation: reputation ?? _reputation,
// );
//   String? get lastName => _lastName;
//   String? get firstName => _firstName;
//   String? get profileHeadline => _profileHeadline;
//   String? get entityUrn => _entityUrn;
//   String? get publicIdentifier => _publicIdentifier;
//   bool? get premium => _premium;
//   String? get imageUrl => _imageUrl;
//   String? get url => _url;
//   Reputation? get reputation => _reputation;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['last_name'] = _lastName;
//     map['first_name'] = _firstName;
//     map['profile_headline'] = _profileHeadline;
//     map['entity_urn'] = _entityUrn;
//     map['public_identifier'] = _publicIdentifier;
//     map['premium'] = _premium;
//     map['image_url'] = _imageUrl;
//     map['url'] = _url;
//     if (_reputation != null) {
//       map['reputation'] = _reputation?.toJson();
//     }
//     return map;
//   }
//
// }
//
// /// follower_count : 0
//
// class Reputation {
//   Reputation({
//       num? followerCount,}){
//     _followerCount = followerCount;
// }
//
//   Reputation.fromJson(dynamic json) {
//     _followerCount = json['follower_count'];
//   }
//   num? _followerCount;
// Reputation copyWith({  num? followerCount,
// }) => Reputation(  followerCount: followerCount ?? _followerCount,
// );
//   num? get followerCount => _followerCount;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['follower_count'] = _followerCount;
//     return map;
//   }
//
// }
//
// /// degree : "string"
// /// field_study : ["string"]
// /// grade : null
// /// school : {"name":"string","logo_url":null}
// /// description : "string"
// /// time_period : {"start_date":{"month":0,"year":0},"end_date":{"month":0,"year":0}}
// /// activities : "string"
//
// class Education {
//   Education({
//       String? degree,
//       List<String>? fieldStudy,
//       dynamic grade,
//       School? school,
//       String? description,
//       TimePeriod? timePeriod,
//       String? activities,}){
//     _degree = degree;
//     _fieldStudy = fieldStudy;
//     _grade = grade;
//     _school = school;
//     _description = description;
//     _timePeriod = timePeriod;
//     _activities = activities;
// }
//
//   Education.fromJson(dynamic json) {
//     _degree = json['degree'];
//     _fieldStudy = json['field_study'] != null ? json['field_study'].cast<String>() : [];
//     _grade = json['grade'];
//     _school = json['school'] != null ? School.fromJson(json['school']) : null;
//     _description = json['description'];
//     _timePeriod = json['time_period'] != null ? TimePeriod.fromJson(json['time_period']) : null;
//     _activities = json['activities'];
//   }
//   String? _degree;
//   List<String>? _fieldStudy;
//   dynamic _grade;
//   School? _school;
//   String? _description;
//   TimePeriod? _timePeriod;
//   String? _activities;
// Education copyWith({  String? degree,
//   List<String>? fieldStudy,
//   dynamic grade,
//   School? school,
//   String? description,
//   TimePeriod? timePeriod,
//   String? activities,
// }) => Education(  degree: degree ?? _degree,
//   fieldStudy: fieldStudy ?? _fieldStudy,
//   grade: grade ?? _grade,
//   school: school ?? _school,
//   description: description ?? _description,
//   timePeriod: timePeriod ?? _timePeriod,
//   activities: activities ?? _activities,
// );
//   String? get degree => _degree;
//   List<String>? get fieldStudy => _fieldStudy;
//   dynamic get grade => _grade;
//   School? get school => _school;
//   String? get description => _description;
//   TimePeriod? get timePeriod => _timePeriod;
//   String? get activities => _activities;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['degree'] = _degree;
//     map['field_study'] = _fieldStudy;
//     map['grade'] = _grade;
//     if (_school != null) {
//       map['school'] = _school?.toJson();
//     }
//     map['description'] = _description;
//     if (_timePeriod != null) {
//       map['time_period'] = _timePeriod?.toJson();
//     }
//     map['activities'] = _activities;
//     return map;
//   }
//
// }
//
// /// start_date : {"month":0,"year":0}
// /// end_date : {"month":0,"year":0}
//
// class TimePeriod {
//   TimePeriod({
//       StartDate? startDate,
//       EndDate? endDate,}){
//     _startDate = startDate;
//     _endDate = endDate;
// }
//
//   TimePeriod.fromJson(dynamic json) {
//     _startDate = json['start_date'] != null ? StartDate.fromJson(json['start_date']) : null;
//     _endDate = json['end_date'] != null ? EndDate.fromJson(json['end_date']) : null;
//   }
//   StartDate? _startDate;
//   EndDate? _endDate;
// TimePeriod copyWith({  StartDate? startDate,
//   EndDate? endDate,
// }) => TimePeriod(  startDate: startDate ?? _startDate,
//   endDate: endDate ?? _endDate,
// );
//   StartDate? get startDate => _startDate;
//   EndDate? get endDate => _endDate;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     if (_startDate != null) {
//       map['start_date'] = _startDate?.toJson();
//     }
//     if (_endDate != null) {
//       map['end_date'] = _endDate?.toJson();
//     }
//     return map;
//   }
//
// }
//
// /// month : 0
// /// year : 0
//
// class EndDate {
//   EndDate({
//       num? month,
//       num? year,}){
//     _month = month;
//     _year = year;
// }
//
//   EndDate.fromJson(dynamic json) {
//     _month = json['month'];
//     _year = json['year'];
//   }
//   num? _month;
//   num? _year;
// EndDate copyWith({  num? month,
//   num? year,
// }) => EndDate(  month: month ?? _month,
//   year: year ?? _year,
// );
//   num? get month => _month;
//   num? get year => _year;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['month'] = _month;
//     map['year'] = _year;
//     return map;
//   }
//
// }
//
// /// month : 0
// /// year : 0
//
// class StartDate {
//   StartDate({
//       num? month,
//       num? year,}){
//     _month = month;
//     _year = year;
// }
//
//   StartDate.fromJson(dynamic json) {
//     _month = json['month'];
//     _year = json['year'];
//   }
//   num? _month;
//   num? _year;
// StartDate copyWith({  num? month,
//   num? year,
// }) => StartDate(  month: month ?? _month,
//   year: year ?? _year,
// );
//   num? get month => _month;
//   num? get year => _year;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['month'] = _month;
//     map['year'] = _year;
//     return map;
//   }
//
// }
//
// /// name : "string"
// /// logo_url : null
//
// class School {
//   School({
//       String? name,
//       dynamic logoUrl,}){
//     _name = name;
//     _logoUrl = logoUrl;
// }
//
//   School.fromJson(dynamic json) {
//     _name = json['name'];
//     _logoUrl = json['logo_url'];
//   }
//   String? _name;
//   dynamic _logoUrl;
// School copyWith({  String? name,
//   dynamic logoUrl,
// }) => School(  name: name ?? _name,
//   logoUrl: logoUrl ?? _logoUrl,
// );
//   String? get name => _name;
//   dynamic get logoUrl => _logoUrl;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['name'] = _name;
//     map['logo_url'] = _logoUrl;
//     return map;
//   }
//
// }
//
// /// title : "string"
// /// company : {"name":"string","industries":[null],"logo_url":"string","employee_count":{"min":0,"max":0}}
// /// description : "string"
// /// time_period : {"start_date":{"month":0,"year":0},"end_date":{"month":0,"year":0}}
// /// location : {"name":null,"country":"string","country_name":null,"city":"string","state":"string"}
//
// class WorkExperiences {
//   WorkExperiences({
//       String? title,
//       Company? company,
//       String? description,
//       TimePeriod? timePeriod,
//       Location? location,}){
//     _title = title;
//     _company = company;
//     _description = description;
//     _timePeriod = timePeriod;
//     _location = location;
// }
//
//   WorkExperiences.fromJson(dynamic json) {
//     _title = json['title'];
//     _company = json['company'] != null ? Company.fromJson(json['company']) : null;
//     _description = json['description'];
//     _timePeriod = json['time_period'] != null ? TimePeriod.fromJson(json['time_period']) : null;
//     _location = json['location'] != null ? Location.fromJson(json['location']) : null;
//   }
//   String? _title;
//   Company? _company;
//   String? _description;
//   TimePeriod? _timePeriod;
//   Location? _location;
// WorkExperiences copyWith({  String? title,
//   Company? company,
//   String? description,
//   TimePeriod? timePeriod,
//   Location? location,
// }) => WorkExperiences(  title: title ?? _title,
//   company: company ?? _company,
//   description: description ?? _description,
//   timePeriod: timePeriod ?? _timePeriod,
//   location: location ?? _location,
// );
//   String? get title => _title;
//   Company? get company => _company;
//   String? get description => _description;
//   TimePeriod? get timePeriod => _timePeriod;
//   Location? get location => _location;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['title'] = _title;
//     if (_company != null) {
//       map['company'] = _company?.toJson();
//     }
//     map['description'] = _description;
//     if (_timePeriod != null) {
//       map['time_period'] = _timePeriod?.toJson();
//     }
//     if (_location != null) {
//       map['location'] = _location?.toJson();
//     }
//     return map;
//   }
//
// }
//
// /// name : null
// /// country : "string"
// /// country_name : null
// /// city : "string"
// /// state : "string"
//
// class Location {
//   Location({
//       dynamic name,
//       String? country,
//       dynamic countryName,
//       String? city,
//       String? state,}){
//     _name = name;
//     _country = country;
//     _countryName = countryName;
//     _city = city;
//     _state = state;
// }
//
//   Location.fromJson(dynamic json) {
//     _name = json['name'];
//     _country = json['country'];
//     _countryName = json['country_name'];
//     _city = json['city'];
//     _state = json['state'];
//   }
//   dynamic _name;
//   String? _country;
//   dynamic _countryName;
//   String? _city;
//   String? _state;
// Location copyWith({  dynamic name,
//   String? country,
//   dynamic countryName,
//   String? city,
//   String? state,
// }) => Location(  name: name ?? _name,
//   country: country ?? _country,
//   countryName: countryName ?? _countryName,
//   city: city ?? _city,
//   state: state ?? _state,
// );
//   dynamic get name => _name;
//   String? get country => _country;
//   dynamic get countryName => _countryName;
//   String? get city => _city;
//   String? get state => _state;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['name'] = _name;
//     map['country'] = _country;
//     map['country_name'] = _countryName;
//     map['city'] = _city;
//     map['state'] = _state;
//     return map;
//   }
//
// }
//
// /// start_date : {"month":0,"year":0}
// /// end_date : {"month":0,"year":0}
//
// class TimePeriod {
//   TimePeriod({
//       StartDate? startDate,
//       EndDate? endDate,}){
//     _startDate = startDate;
//     _endDate = endDate;
// }
//
//   TimePeriod.fromJson(dynamic json) {
//     _startDate = json['start_date'] != null ? StartDate.fromJson(json['start_date']) : null;
//     _endDate = json['end_date'] != null ? EndDate.fromJson(json['end_date']) : null;
//   }
//   StartDate? _startDate;
//   EndDate? _endDate;
// TimePeriod copyWith({  StartDate? startDate,
//   EndDate? endDate,
// }) => TimePeriod(  startDate: startDate ?? _startDate,
//   endDate: endDate ?? _endDate,
// );
//   StartDate? get startDate => _startDate;
//   EndDate? get endDate => _endDate;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     if (_startDate != null) {
//       map['start_date'] = _startDate?.toJson();
//     }
//     if (_endDate != null) {
//       map['end_date'] = _endDate?.toJson();
//     }
//     return map;
//   }
//
// }
//
// /// month : 0
// /// year : 0
//
// class EndDate {
//   EndDate({
//       num? month,
//       num? year,}){
//     _month = month;
//     _year = year;
// }
//
//   EndDate.fromJson(dynamic json) {
//     _month = json['month'];
//     _year = json['year'];
//   }
//   num? _month;
//   num? _year;
// EndDate copyWith({  num? month,
//   num? year,
// }) => EndDate(  month: month ?? _month,
//   year: year ?? _year,
// );
//   num? get month => _month;
//   num? get year => _year;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['month'] = _month;
//     map['year'] = _year;
//     return map;
//   }
//
// }
//
// /// month : 0
// /// year : 0
//
// class StartDate {
//   StartDate({
//       num? month,
//       num? year,}){
//     _month = month;
//     _year = year;
// }
//
//   StartDate.fromJson(dynamic json) {
//     _month = json['month'];
//     _year = json['year'];
//   }
//   num? _month;
//   num? _year;
// StartDate copyWith({  num? month,
//   num? year,
// }) => StartDate(  month: month ?? _month,
//   year: year ?? _year,
// );
//   num? get month => _month;
//   num? get year => _year;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['month'] = _month;
//     map['year'] = _year;
//     return map;
//   }
//
// }
//
// /// name : "string"
// /// industries : [null]
// /// logo_url : "string"
// /// employee_count : {"min":0,"max":0}
//
// class Company {
//   Company({
//       String? name,
//       List<dynamic>? industries,
//       String? logoUrl,
//       EmployeeCount? employeeCount,}){
//     _name = name;
//     _industries = industries;
//     _logoUrl = logoUrl;
//     _employeeCount = employeeCount;
// }
//
//   Company.fromJson(dynamic json) {
//     _name = json['name'];
//     if (json['industries'] != null) {
//       _industries = [];
//       json['industries'].forEach((v) {
//         _industries?.add(v);
//       });
//     }
//     _logoUrl = json['logo_url'];
//     _employeeCount = json['employee_count'] != null ? EmployeeCount.fromJson(json['employee_count']) : null;
//   }
//   String? _name;
//   List<dynamic>? _industries;
//   String? _logoUrl;
//   EmployeeCount? _employeeCount;
// Company copyWith({  String? name,
//   List<dynamic>? industries,
//   String? logoUrl,
//   EmployeeCount? employeeCount,
// }) => Company(  name: name ?? _name,
//   industries: industries ?? _industries,
//   logoUrl: logoUrl ?? _logoUrl,
//   employeeCount: employeeCount ?? _employeeCount,
// );
//   String? get name => _name;
//   List<dynamic>? get industries => _industries;
//   String? get logoUrl => _logoUrl;
//   EmployeeCount? get employeeCount => _employeeCount;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['name'] = _name;
//     if (_industries != null) {
//       map['industries'] = _industries?.map((v) => v.toJson()).toList();
//     }
//     map['logo_url'] = _logoUrl;
//     if (_employeeCount != null) {
//       map['employee_count'] = _employeeCount?.toJson();
//     }
//     return map;
//   }
//
// }
//
// /// min : 0
// /// max : 0
//
// class EmployeeCount {
//   EmployeeCount({
//       num? min,
//       num? max,}){
//     _min = min;
//     _max = max;
// }
//
//   EmployeeCount.fromJson(dynamic json) {
//     _min = json['min'];
//     _max = json['max'];
//   }
//   num? _min;
//   num? _max;
// EmployeeCount copyWith({  num? min,
//   num? max,
// }) => EmployeeCount(  min: min ?? _min,
//   max: max ?? _max,
// );
//   num? get min => _min;
//   num? get max => _max;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['min'] = _min;
//     map['max'] = _max;
//     return map;
//   }
//
// }
//
// /// name : "string"
//
// class TalksAbout {
//   TalksAbout({
//       String? name,}){
//     _name = name;
// }
//
//   TalksAbout.fromJson(dynamic json) {
//     _name = json['name'];
//   }
//   String? _name;
// TalksAbout copyWith({  String? name,
// }) => TalksAbout(  name: name ?? _name,
// );
//   String? get name => _name;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['name'] = _name;
//     return map;
//   }
//
// }
//
// /// name : "string"
//
// class TopMentions {
//   TopMentions({
//       String? name,}){
//     _name = name;
// }
//
//   TopMentions.fromJson(dynamic json) {
//     _name = json['name'];
//   }
//   String? _name;
// TopMentions copyWith({  String? name,
// }) => TopMentions(  name: name ?? _name,
// );
//   String? get name => _name;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['name'] = _name;
//     return map;
//   }
//
// }
//
// /// name : "string"
//
// class TopHashtags {
//   TopHashtags({
//       String? name,}){
//     _name = name;
// }
//
//   TopHashtags.fromJson(dynamic json) {
//     _name = json['name'];
//   }
//   String? _name;
// TopHashtags copyWith({  String? name,
// }) => TopHashtags(  name: name ?? _name,
// );
//   String? get name => _name;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['name'] = _name;
//     return map;
//   }
//
// }
//
// /// type : "string"
// /// url : "string"
// /// description : "string"
// /// thumbnail_url : null
// /// engagement : {"like_count":0,"comment_count":0}
// /// published_at : "string"
//
// class RecentContents {
//   RecentContents({
//       String? type,
//       String? url,
//       String? description,
//       dynamic thumbnailUrl,
//       Engagement? engagement,
//       String? publishedAt,}){
//     _type = type;
//     _url = url;
//     _description = description;
//     _thumbnailUrl = thumbnailUrl;
//     _engagement = engagement;
//     _publishedAt = publishedAt;
// }
//
//   RecentContents.fromJson(dynamic json) {
//     _type = json['type'];
//     _url = json['url'];
//     _description = json['description'];
//     _thumbnailUrl = json['thumbnail_url'];
//     _engagement = json['engagement'] != null ? Engagement.fromJson(json['engagement']) : null;
//     _publishedAt = json['published_at'];
//   }
//   String? _type;
//   String? _url;
//   String? _description;
//   dynamic _thumbnailUrl;
//   Engagement? _engagement;
//   String? _publishedAt;
// RecentContents copyWith({  String? type,
//   String? url,
//   String? description,
//   dynamic thumbnailUrl,
//   Engagement? engagement,
//   String? publishedAt,
// }) => RecentContents(  type: type ?? _type,
//   url: url ?? _url,
//   description: description ?? _description,
//   thumbnailUrl: thumbnailUrl ?? _thumbnailUrl,
//   engagement: engagement ?? _engagement,
//   publishedAt: publishedAt ?? _publishedAt,
// );
//   String? get type => _type;
//   String? get url => _url;
//   String? get description => _description;
//   dynamic get thumbnailUrl => _thumbnailUrl;
//   Engagement? get engagement => _engagement;
//   String? get publishedAt => _publishedAt;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['type'] = _type;
//     map['url'] = _url;
//     map['description'] = _description;
//     map['thumbnail_url'] = _thumbnailUrl;
//     if (_engagement != null) {
//       map['engagement'] = _engagement?.toJson();
//     }
//     map['published_at'] = _publishedAt;
//     return map;
//   }
//
// }
//
// /// like_count : 0
// /// comment_count : 0
//
// class Engagement {
//   Engagement({
//       num? likeCount,
//       num? commentCount,}){
//     _likeCount = likeCount;
//     _commentCount = commentCount;
// }
//
//   Engagement.fromJson(dynamic json) {
//     _likeCount = json['like_count'];
//     _commentCount = json['comment_count'];
//   }
//   num? _likeCount;
//   num? _commentCount;
// Engagement copyWith({  num? likeCount,
//   num? commentCount,
// }) => Engagement(  likeCount: likeCount ?? _likeCount,
//   commentCount: commentCount ?? _commentCount,
// );
//   num? get likeCount => _likeCount;
//   num? get commentCount => _commentCount;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['like_count'] = _likeCount;
//     map['comment_count'] = _commentCount;
//     return map;
//   }
//
// }
//
// /// type : "string"
// /// url : "string"
// /// description : "string"
// /// thumbnail_url : null
// /// engagement : {"like_count":0,"comment_count":0}
// /// published_at : "string"
//
// class TopContents {
//   TopContents({
//       String? type,
//       String? url,
//       String? description,
//       dynamic thumbnailUrl,
//       Engagement? engagement,
//       String? publishedAt,}){
//     _type = type;
//     _url = url;
//     _description = description;
//     _thumbnailUrl = thumbnailUrl;
//     _engagement = engagement;
//     _publishedAt = publishedAt;
// }
//
//   TopContents.fromJson(dynamic json) {
//     _type = json['type'];
//     _url = json['url'];
//     _description = json['description'];
//     _thumbnailUrl = json['thumbnail_url'];
//     _engagement = json['engagement'] != null ? Engagement.fromJson(json['engagement']) : null;
//     _publishedAt = json['published_at'];
//   }
//   String? _type;
//   String? _url;
//   String? _description;
//   dynamic _thumbnailUrl;
//   Engagement? _engagement;
//   String? _publishedAt;
// TopContents copyWith({  String? type,
//   String? url,
//   String? description,
//   dynamic thumbnailUrl,
//   Engagement? engagement,
//   String? publishedAt,
// }) => TopContents(  type: type ?? _type,
//   url: url ?? _url,
//   description: description ?? _description,
//   thumbnailUrl: thumbnailUrl ?? _thumbnailUrl,
//   engagement: engagement ?? _engagement,
//   publishedAt: publishedAt ?? _publishedAt,
// );
//   String? get type => _type;
//   String? get url => _url;
//   String? get description => _description;
//   dynamic get thumbnailUrl => _thumbnailUrl;
//   Engagement? get engagement => _engagement;
//   String? get publishedAt => _publishedAt;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['type'] = _type;
//     map['url'] = _url;
//     map['description'] = _description;
//     map['thumbnail_url'] = _thumbnailUrl;
//     if (_engagement != null) {
//       map['engagement'] = _engagement?.toJson();
//     }
//     map['published_at'] = _publishedAt;
//     return map;
//   }
//
// }
//
// /// like_count : 0
// /// comment_count : 0
//
// class Engagement {
//   Engagement({
//       num? likeCount,
//       num? commentCount,}){
//     _likeCount = likeCount;
//     _commentCount = commentCount;
// }
//
//   Engagement.fromJson(dynamic json) {
//     _likeCount = json['like_count'];
//     _commentCount = json['comment_count'];
//   }
//   num? _likeCount;
//   num? _commentCount;
// Engagement copyWith({  num? likeCount,
//   num? commentCount,
// }) => Engagement(  likeCount: likeCount ?? _likeCount,
//   commentCount: commentCount ?? _commentCount,
// );
//   num? get likeCount => _likeCount;
//   num? get commentCount => _commentCount;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['like_count'] = _likeCount;
//     map['comment_count'] = _commentCount;
//     return map;
//   }
//
// }
//
// /// type : "string"
// /// value : "string"
//
// class ContactDetails {
//   ContactDetails({
//       String? type,
//       String? value,}){
//     _type = type;
//     _value = value;
// }
//
//   ContactDetails.fromJson(dynamic json) {
//     _type = json['type'];
//     _value = json['value'];
//   }
//   String? _type;
//   String? _value;
// ContactDetails copyWith({  String? type,
//   String? value,
// }) => ContactDetails(  type: type ?? _type,
//   value: value ?? _value,
// );
//   String? get type => _type;
//   String? get value => _value;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['type'] = _type;
//     map['value'] = _value;
//     return map;
//   }
//
// }
//
// /// name : "string"
// /// country : "string"
// /// country_name : "string"
// /// city : "string"
// /// state : "string"
//
// class Location {
//   Location({
//       String? name,
//       String? country,
//       String? countryName,
//       String? city,
//       String? state,}){
//     _name = name;
//     _country = country;
//     _countryName = countryName;
//     _city = city;
//     _state = state;
// }
//
//   Location.fromJson(dynamic json) {
//     _name = json['name'];
//     _country = json['country'];
//     _countryName = json['country_name'];
//     _city = json['city'];
//     _state = json['state'];
//   }
//   String? _name;
//   String? _country;
//   String? _countryName;
//   String? _city;
//   String? _state;
// Location copyWith({  String? name,
//   String? country,
//   String? countryName,
//   String? city,
//   String? state,
// }) => Location(  name: name ?? _name,
//   country: country ?? _country,
//   countryName: countryName ?? _countryName,
//   city: city ?? _city,
//   state: state ?? _state,
// );
//   String? get name => _name;
//   String? get country => _country;
//   String? get countryName => _countryName;
//   String? get city => _city;
//   String? get state => _state;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['name'] = _name;
//     map['country'] = _country;
//     map['country_name'] = _countryName;
//     map['city'] = _city;
//     map['state'] = _state;
//     return map;
//   }
//
// }
//
// /// follower_count : 0
// /// connection_count : 0
//
// class Reputation {
//   Reputation({
//       num? followerCount,
//       num? connectionCount,}){
//     _followerCount = followerCount;
//     _connectionCount = connectionCount;
// }
//
//   Reputation.fromJson(dynamic json) {
//     _followerCount = json['follower_count'];
//     _connectionCount = json['connection_count'];
//   }
//   num? _followerCount;
//   num? _connectionCount;
// Reputation copyWith({  num? followerCount,
//   num? connectionCount,
// }) => Reputation(  followerCount: followerCount ?? _followerCount,
//   connectionCount: connectionCount ?? _connectionCount,
// );
//   num? get followerCount => _followerCount;
//   num? get connectionCount => _connectionCount;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['follower_count'] = _followerCount;
//     map['connection_count'] = _connectionCount;
//     return map;
//   }
//
// }
//
// /// id : "string"
// /// name : "string"
// /// logo_url : "string"
//
// class WorkPlatform {
//   WorkPlatform({
//       String? id,
//       String? name,
//       String? logoUrl,}){
//     _id = id;
//     _name = name;
//     _logoUrl = logoUrl;
// }
//
//   WorkPlatform.fromJson(dynamic json) {
//     _id = json['id'];
//     _name = json['name'];
//     _logoUrl = json['logo_url'];
//   }
//   String? _id;
//   String? _name;
//   String? _logoUrl;
// WorkPlatform copyWith({  String? id,
//   String? name,
//   String? logoUrl,
// }) => WorkPlatform(  id: id ?? _id,
//   name: name ?? _name,
//   logoUrl: logoUrl ?? _logoUrl,
// );
//   String? get id => _id;
//   String? get name => _name;
//   String? get logoUrl => _logoUrl;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['id'] = _id;
//     map['name'] = _name;
//     map['logo_url'] = _logoUrl;
//     return map;
//   }
//
// }