//
//  ViewController.h
//  jacketReminder
//
//  Created by Christopher Peyton on 5/18/15.
//  Copyright (c) 2015 Christopher Peyton. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreLocation;
#import "NSLOG__SPACER.h"
#import "TableViewController.h"

@interface ViewController : UIViewController <CLLocationManagerDelegate>

{
    int LocationEnabledStatus;
    BOOL setHomeLocationTriggered;
}

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic,strong) NSURLSession *session;

@property (strong, nonatomic) NSMutableArray *homeInformation;//will contain 2 items: cllocation and address string

-(NSDictionary *) getWeather;

@end

