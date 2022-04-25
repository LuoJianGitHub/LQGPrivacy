//
//  LQGLocationManager.h
//  LQGPrivacy
//
//  Created by 罗建
//  Copyright (c) 2021 罗建. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 位置管理类
@interface LQGLocationManager : NSObject

/// 单例
+ (instancetype)sharedManager;

/// 获取权限
/// @param isAlways 是否总是
/// @param completion 回调
- (void)requestAuthorizationWithIsAlways:(BOOL)isAlways completion:(void(^)(BOOL success))completion;

@end
