//
//  LQGLocationManager.m
//  LQGPrivacy
//
//  Created by 罗建
//  Copyright (c) 2021 罗建. All rights reserved.
//

#import "LQGLocationManager.h"

#import <CoreLocation/CoreLocation.h>

@interface LQGLocationManager ()
<
CLLocationManagerDelegate
>

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, copy  ) void (^authorizedCompletion)(BOOL success);

@end

@implementation LQGLocationManager


#pragma mark - 单例

+ (instancetype)sharedManager {
    static LQGLocationManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}


#pragma mark - <CLLocationManagerDelegate>

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusNotDetermined) return;
    
    if (self.authorizedCompletion) {
        self.authorizedCompletion(status >= 3);
    }
}


#pragma mark - Other Method

- (void)requestAuthorizationWithIsAlways:(BOOL)isAlways completion:(void (^)(BOOL))completion {
    self.authorizedCompletion = completion;
    if (isAlways) {
        [self.locationManager requestAlwaysAuthorization];
    } else {
        [self.locationManager requestWhenInUseAuthorization];
    }
}


#pragma mark - Lazy

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = ({
            CLLocationManager *locationManager = [[CLLocationManager alloc] init];
            locationManager.delegate = self;
            locationManager;
        });
    }
    return _locationManager;
}

@end
