/// uid : ""
/// access_ids : [""]
/// access_id_permissions : [{"uid":"","permissions":[""]}]
/// instagram_id : ""
/// name : ""
/// username : ""
/// profile_picture_url : ""
/// access_token : ""
/// shared_media : [{"media_id":"","media_type":"","media_url":"","thumbnail_url":""},{"media_id":"","media_type":"","media_url":"","thumbnail_url":""}]

class SharedPostsModel {
  SharedPostsModel({
      String? uid, 
      List<String>? accessIds, 
      List<AccessIdPermissions>? accessIdPermissions, 
      String? instagramId, 
      String? name, 
      String? username, 
      String? profilePictureUrl, 
      String? accessToken, 
      List<SharedMedia>? sharedMedia,}){
    _uid = uid;
    _accessIds = accessIds;
    _accessIdPermissions = accessIdPermissions;
    _instagramId = instagramId;
    _name = name;
    _username = username;
    _profilePictureUrl = profilePictureUrl;
    _accessToken = accessToken;
    _sharedMedia = sharedMedia;
}

  SharedPostsModel.fromJson(dynamic json) {
    _uid = json['uid'];
    _accessIds = json['access_ids'] != null ? json['access_ids'].cast<String>() : [];
    if (json['access_id_permissions'] != null) {
      _accessIdPermissions = [];
      json['access_id_permissions'].forEach((v) {
        _accessIdPermissions?.add(AccessIdPermissions.fromJson(v));
      });
    }
    _instagramId = json['instagram_id'];
    _name = json['name'];
    _username = json['username'];
    _profilePictureUrl = json['profile_picture_url'];
    _accessToken = json['access_token'];
    if (json['shared_media'] != null) {
      _sharedMedia = [];
      json['shared_media'].forEach((v) {
        _sharedMedia?.add(SharedMedia.fromJson(v));
      });
    }
  }
  String? _uid;
  List<String>? _accessIds;
  List<AccessIdPermissions>? _accessIdPermissions;
  String? _instagramId;
  String? _name;
  String? _username;
  String? _profilePictureUrl;
  String? _accessToken;
  List<SharedMedia>? _sharedMedia;
SharedPostsModel copyWith({  String? uid,
  List<String>? accessIds,
  List<AccessIdPermissions>? accessIdPermissions,
  String? instagramId,
  String? name,
  String? username,
  String? profilePictureUrl,
  String? accessToken,
  List<SharedMedia>? sharedMedia,
}) => SharedPostsModel(  uid: uid ?? _uid,
  accessIds: accessIds ?? _accessIds,
  accessIdPermissions: accessIdPermissions ?? _accessIdPermissions,
  instagramId: instagramId ?? _instagramId,
  name: name ?? _name,
  username: username ?? _username,
  profilePictureUrl: profilePictureUrl ?? _profilePictureUrl,
  accessToken: accessToken ?? _accessToken,
  sharedMedia: sharedMedia ?? _sharedMedia,
);
  String? get uid => _uid;
  List<String>? get accessIds => _accessIds;
  List<AccessIdPermissions>? get accessIdPermissions => _accessIdPermissions;
  String? get instagramId => _instagramId;
  String? get name => _name;
  String? get username => _username;
  String? get profilePictureUrl => _profilePictureUrl;
  String? get accessToken => _accessToken;
  List<SharedMedia>? get sharedMedia => _sharedMedia;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['uid'] = _uid;
    map['access_ids'] = _accessIds;
    if (_accessIdPermissions != null) {
      map['access_id_permissions'] = _accessIdPermissions?.map((v) => v.toJson()).toList();
    }
    map['instagram_id'] = _instagramId;
    map['name'] = _name;
    map['username'] = _username;
    map['profile_picture_url'] = _profilePictureUrl;
    map['access_token'] = _accessToken;
    if (_sharedMedia != null) {
      map['shared_media'] = _sharedMedia?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// media_id : ""
/// media_type : ""
/// media_url : ""
/// thumbnail_url : ""

class SharedMedia {
  SharedMedia({
      String? mediaId, 
      String? mediaType, 
      String? mediaUrl, 
      String? thumbnailUrl,}){
    _mediaId = mediaId;
    _mediaType = mediaType;
    _mediaUrl = mediaUrl;
    _thumbnailUrl = thumbnailUrl;
}

  SharedMedia.fromJson(dynamic json) {
    _mediaId = json['media_id'];
    _mediaType = json['media_type'];
    _mediaUrl = json['media_url'];
    _thumbnailUrl = json['thumbnail_url'];
  }
  String? _mediaId;
  String? _mediaType;
  String? _mediaUrl;
  String? _thumbnailUrl;
SharedMedia copyWith({  String? mediaId,
  String? mediaType,
  String? mediaUrl,
  String? thumbnailUrl,
}) => SharedMedia(  mediaId: mediaId ?? _mediaId,
  mediaType: mediaType ?? _mediaType,
  mediaUrl: mediaUrl ?? _mediaUrl,
  thumbnailUrl: thumbnailUrl ?? _thumbnailUrl,
);
  String? get mediaId => _mediaId;
  String? get mediaType => _mediaType;
  String? get mediaUrl => _mediaUrl;
  String? get thumbnailUrl => _thumbnailUrl;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['media_id'] = _mediaId;
    map['media_type'] = _mediaType;
    map['media_url'] = _mediaUrl;
    map['thumbnail_url'] = _thumbnailUrl;
    return map;
  }

}

/// uid : ""
/// permissions : [""]

class AccessIdPermissions {
  AccessIdPermissions({
      String? uid, 
      List<String>? permissions,}){
    _uid = uid;
    _permissions = permissions;
}

  AccessIdPermissions.fromJson(dynamic json) {
    _uid = json['uid'];
    _permissions = json['permissions'] != null ? json['permissions'].cast<String>() : [];
  }
  String? _uid;
  List<String>? _permissions;
AccessIdPermissions copyWith({  String? uid,
  List<String>? permissions,
}) => AccessIdPermissions(  uid: uid ?? _uid,
  permissions: permissions ?? _permissions,
);
  String? get uid => _uid;
  List<String>? get permissions => _permissions;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['uid'] = _uid;
    map['permissions'] = _permissions;
    return map;
  }

}