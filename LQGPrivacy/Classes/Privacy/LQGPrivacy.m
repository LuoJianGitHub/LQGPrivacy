//
//  LQGPrivacy.m
//  LQGPrivacy
//
//  Created by 罗建
//  Copyright (c) 2021 罗建. All rights reserved.
//

#import "LQGPrivacy.h"

#import "LQGLocationManager.h"

#import <Photos/Photos.h>
#import <Contacts/Contacts.h>
#import <CoreLocation/CoreLocation.h>

#import <LQGMacro/LQGMacro.h>
#import <LQGTip/LQGTip.h>

@implementation LQGPrivacy

+ (void)privacyWithType:(LQGPrivacyType)type completion:(LQGPrivacyCompletion)completion {
    [self privacyWithType:type completion:completion alertType:LQGPrivacyAlertTypeNone fromController:nil];
}

+ (void)privacyWithType:(LQGPrivacyType)type completion:(LQGPrivacyCompletion)completion alertType:(LQGPrivacyAlertType)alertType fromController:(UIViewController *)controller {
    if (type != LQGPrivacyTypePhoto &&
        type != LQGPrivacyTypeCamera &&
        type != LQGPrivacyTypeMicrophoe &&
        type != LQGPrivacyTypeContacts &&
        type != LQGPrivacyTypeLocationWhenInUse &&
        type != LQGPrivacyTypeLocationAlways) {
        LQG_DebugLog(@"暂不支持的权限类型");
        if (completion) {
            completion(LQGPrivacyCodeNotSuppert);
        }
        return;
    }
    if (type == LQGPrivacyTypeCamera &&
        TARGET_IPHONE_SIMULATOR) {
        LQG_DebugLog(@"模拟器中无法打开照相机，请在真机中使用");
        if (completion) {
            completion(LQGPrivacyCodeDisable);
        }
        return;
    }
    if ((type == LQGPrivacyTypeLocationWhenInUse || type == LQGPrivacyTypeLocationAlways) &&
        ![CLLocationManager locationServicesEnabled]) {
        LQG_DebugLog(@"定位服务不可用");
        if (completion) {
            completion(LQGPrivacyCodeDisable);
        }
        return;
    }
    
    NSInteger status = [self checkPrivacyStatusWithType:type];
    if (status == 0) {
        // AuthorizationStatusNotDetermined 用户未选择
        [self requestPrivacyAuthorizationWithType:type completion:^(BOOL success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    if (completion) {
                        completion(LQGPrivacyCodeAuthorized);
                    }
                } else {
                    [self alertWithType:type completion:completion alertType:alertType fromController:controller];
                }
            });
        }];
    } else if (status == 1 || status == 2) {
        // AuthorizationStatusRestricted    家长控制,不允许访问
        // AuthorizationStatusDenied        用户已拒绝
        [self alertWithType:type completion:completion alertType:alertType fromController:controller];
    } else {
        // AuthorizationStatusAuthorized    用户已允许
        if (completion) {
            completion(LQGPrivacyCodeAuthorized);
        }
    }
}

+ (NSInteger)checkPrivacyStatusWithType:(LQGPrivacyType)type {
    NSInteger status;
    switch (type) {
        case LQGPrivacyTypePhoto:
            status = [PHPhotoLibrary authorizationStatus];
            break;
        case LQGPrivacyTypeCamera:
            status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            break;
        case LQGPrivacyTypeMicrophoe:
            status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
            break;
        case LQGPrivacyTypeContacts:
            status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
            break;
        case LQGPrivacyTypeLocationWhenInUse:
        case LQGPrivacyTypeLocationAlways:
            status = [CLLocationManager authorizationStatus];
            break;
        default:
            break;
    }
    return status;
}

+ (void)requestPrivacyAuthorizationWithType:(LQGPrivacyType)type completion:(void(^)(BOOL success))completion {
    switch (type) {
        case LQGPrivacyTypePhoto:
        {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (completion) {
                    completion(status == 3);
                }
            }];
        }
            break;
        case LQGPrivacyTypeCamera:
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (completion) {
                    completion(granted);
                }
            }];
        }
            break;
        case LQGPrivacyTypeMicrophoe:
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                if (completion) {
                    completion(granted);
                }
            }];
        }
            break;
        case LQGPrivacyTypeContacts:
        {
            CNContactStore *contactStore = [[CNContactStore alloc] init];
            [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                if (completion) {
                    completion(granted);
                }
            }];
        }
            break;
        case LQGPrivacyTypeLocationWhenInUse:
        case LQGPrivacyTypeLocationAlways:
            [[LQGLocationManager sharedManager] requestAuthorizationWithIsAlways:type == LQGPrivacyTypeLocationAlways completion:completion];
            break;
        default:
            break;
    }
}

+ (void)alertWithType:(LQGPrivacyType)type completion:(LQGPrivacyCompletion)completion alertType:(LQGPrivacyAlertType)alertType fromController:(UIViewController *)controller {
    if (alertType == LQGPrivacyAlertTypeNone) {
        if (completion) {
            completion(LQGPrivacyCodeRejected);
        }
    } else {
        [LQGAlertController showWithModel:({
            LQGAlertModel *model = [[LQGAlertModel alloc] init];
            model.title = @"提示";
            model.message = [self messageWithType:type];
            if (alertType == LQGPrivacyAlertTypeAlert) {
                model.normalActionTitles = @[@"确定"];
                model.normalActionTapBlock = ^(NSInteger index) {
                    if (completion) {
                        completion(LQGPrivacyCodeRejected);
                    }
                };
            } else {
                model.normalActionTitles = @[@"立即前往"];
                model.normalActionTapBlock = ^(NSInteger index) {
                    NSString *url = UIApplicationOpenSettingsURLString;
                    if (LQG_SI_iOS10Later) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:@{} completionHandler:nil];
                    } else {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
                    }
                    [self alertWithType:type completion:completion alertType:alertType fromController:controller];
                };
                model.cancelActionTitle = @"下次再说";
                model.cancelActionTapBlock = ^{
                    if (completion) {
                        completion(LQGPrivacyCodeRejected);
                    }
                };
            }
            
            model;
        }) fromController:controller];
    }
}

+ (NSString *)messageWithType:(LQGPrivacyType)type {
    if (type == LQGPrivacyTypeLocationAlways) {
        type = LQGPrivacyTypeLocationWhenInUse;
    }
    return [@{
        @(LQGPrivacyTypePhoto): @"请在iPhone的“设置-隐私-照片”选项中，允许[项目名称]访问你的手机相册。",
        @(LQGPrivacyTypeCamera): @"请在iPhone的“设置-隐私-相机”选项中，允许[项目名称]访问你的相机。",
        @(LQGPrivacyTypeMicrophoe): @"请在iPhone的“设置-隐私-麦克风”选项中，允许[项目名称]访问你的手机麦克风。",
        @(LQGPrivacyTypeContacts): @"请在iPhone的“设置-隐私-通讯录”选项中，允许[项目名称]访问你的通讯录。",
        @(LQGPrivacyTypeLocationWhenInUse): @"请在iPhone的“设置-隐私-定位服务“选项中，打开定位服务并允许[项目名称]使用定位服务。"
    }[@(type)] stringByReplacingOccurrencesOfString:@"[项目名称]" withString:LQG_PI_NAME];
}

@end
