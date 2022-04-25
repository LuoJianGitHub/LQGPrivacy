//
//  LQGPrivacy.h
//  LQGPrivacy
//
//  Created by 罗建
//  Copyright (c) 2021 罗建. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 LQGPrivacyType隐私类型
 
 - LQGPrivacyTypePhoto: 相册
 - LQGPrivacyTypeCamera: 相机
 - LQGPrivacyTypeMicrophoe: 麦克风
 - LQGPrivacyTypeContacts: 通讯录
 - LQGPrivacyTypeLocationWhenInUse: 位置（使用期间）
 - LQGPrivacyTypeLocationAlways: 位置（总是）（备注：项目中位置权限应使用同一种，或使用期间，或总是，不要同时使用）
 */
typedef NS_ENUM(NSInteger, LQGPrivacyType) {
    LQGPrivacyTypePhoto = 0,
    LQGPrivacyTypeCamera = 1,
    LQGPrivacyTypeMicrophoe = 2,
    LQGPrivacyTypeContacts = 3,
    LQGPrivacyTypeLocationWhenInUse = 4,
    LQGPrivacyTypeLocationAlways = 5,
};

/**
 LQGPrivacyAlertType提示类型
 
 - LQGPrivacyAlertTypeNone: 不提示
 - LQGPrivacyAlertTypeAlert: 提示
 - LQGPrivacyAlertTypeAlertAndJump: 提示+跳转
 */
typedef NS_ENUM(NSInteger, LQGPrivacyAlertType) {
    LQGPrivacyAlertTypeNone = 0,
    LQGPrivacyAlertTypeAlert = 1,
    LQGPrivacyAlertTypeAlertAndJump = 2,
};

/**
 LQGPrivacyCode状态码
 
 - LQGPrivacyCodeAuthorized: 已授权
 - LQGPrivacyCodeRejected: 已拒绝
 - LQGPrivacyCodeDisable: 服务不可用
 - LQGPrivacyCodeNotSuppert: 不支持的权限类型
 */
typedef NS_ENUM(NSInteger, LQGPrivacyCode) {
    LQGPrivacyCodeAuthorized = 0,
    LQGPrivacyCodeRejected = 1,
    LQGPrivacyCodeDisable = 2,
    LQGPrivacyCodeNotSuppert = 3,
};

typedef void(^LQGPrivacyCompletion)(LQGPrivacyCode code);

/// 权限管理类
@interface LQGPrivacy : NSObject

/// 获取权限
/// @param type 权限类型
/// @param completion 回调
+ (void)privacyWithType:(LQGPrivacyType)type completion:(LQGPrivacyCompletion)completion;

/// 获取权限
/// @param type 权限类型
/// @param completion 回调
/// @param alertType 提示类型
/// @param controller 当前控制器
+ (void)privacyWithType:(LQGPrivacyType)type completion:(LQGPrivacyCompletion)completion alertType:(LQGPrivacyAlertType)alertType fromController:(UIViewController *)controller;

@end

/** 系统权限
 <key>NSPhotoLibraryUsageDescription</key>
 <string>如果不允许，你将无法发送系统相册里的照片给朋友。</string>
 <key>NSPhotoLibraryAddUsageDescription</key>
 <string>如果不允许，你将无法发送系统相册里的照片给朋友。</string>
 
 <key>NSCameraUsageDescription</key>
 <string>如果不允许，你将无法在微信中拍摄照片和视频，也无法使用视频通话、扫一扫等功能。</string>
 
 <key>NSMicrophoneUsageDescription</key>
 <string>如果不允许，你将无法在微信中发送语音消息，或进行音视频听话。</string>
  
 <key>NSContactsUsageDescription</key>
 <string>如果不允许，微信将无法推荐通讯录中的朋友给你。微信仅使用特征码用于匹配识别，不会保存你的通讯录内容。</string>
 
 <key>NSLocationUsageDescription</key>
 <string>如果不允许，你将无法在聊天中分享你的位置，也无法使用摇一摇、附近的人等功能。</string>
 <key>NSLocationWhenInUseUsageDescription</key>
 <string>如果不允许，你将无法在聊天中分享你的位置，也无法使用摇一摇、附近的人等功能。</string>
 <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
 <string>如果不允许，你将无法在聊天中分享你的位置，也无法使用摇一摇、附近的人等功能。</string>
 */
