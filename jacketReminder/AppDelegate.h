//
//  AppDelegate.h
//  jacketReminder
//
//  Created by Christopher Peyton on 5/18/15.
//  Copyright (c) 2015 Christopher Peyton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <OneSignal/OneSignal.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) OneSignal *oneSignal;

- (void) playAlertSound;
- (void) fetchWeatherFromPush;

@end

