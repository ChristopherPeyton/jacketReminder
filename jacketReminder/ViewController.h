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
//#import "weatherData.h"

@interface ViewController : UIViewController <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic,strong) NSURLSession *session;


-(NSDictionary *) getWeather;

@end
