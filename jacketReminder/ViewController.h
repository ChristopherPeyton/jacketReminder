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
IB_DESIGNABLE
@interface ViewController : UIViewController <CLLocationManagerDelegate>

{
    int LocationEnabledStatus;
    BOOL setHomeLocationTriggered;
    BOOL atHome;
}

@property (weak, nonatomic) IBOutlet UIView *loadingActivityView;
@property (strong, nonatomic) NSString *userName;
@property (weak, nonatomic) IBOutlet UILabel *forecast_3_hr;
@property (weak, nonatomic) IBOutlet UILabel *forecast_6_hr;
@property (weak, nonatomic) IBOutlet UILabel *forecast_9_hr;

@property (weak, nonatomic) IBOutlet UILabel *forecast_3_time;
@property (weak, nonatomic) IBOutlet UILabel *forecast_6_time;
@property (weak, nonatomic) IBOutlet UILabel *forecast_9_time;

//HOME LOCATION SET
@property (weak, nonatomic) IBOutlet UILabel *forecast_3_hrHOME;
@property (weak, nonatomic) IBOutlet UILabel *forecast_6_hrHOME;
@property (weak, nonatomic) IBOutlet UILabel *forecast_9_hrHOME;

@property (weak, nonatomic) IBOutlet UILabel *forecast_3_timeHOME;
@property (weak, nonatomic) IBOutlet UILabel *forecast_6_timeHOME;
@property (weak, nonatomic) IBOutlet UILabel *forecast_9_timeHOME;

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic,strong) NSURLSession *session;

@property (strong, nonatomic) NSMutableArray *homeInformation;//will contain 3 items: cllocation, address string and city name

-(NSMutableDictionary *) getWeather;
-(NSMutableDictionary *) getHomeWeather;
-(NSMutableDictionary *) getBothWeather;
-(NSMutableDictionary *) getHomeWeatherOnlyForBackground;

@end

