//
//  ViewController.m
//  jacketReminder
//
//  Created by Christopher Peyton on 5/18/15.
//  Copyright (c) 2015 Christopher Peyton. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

{
    NSMutableDictionary *weatherDictionary;
    NSMutableDictionary *homeWeatherDictionary;
    CLLocation *location;
    NSMutableArray *addressFromGEO;//[0]=string address,[1]=city string
    int timer;
    int maxTimer;
    int weatherTimer;
    
    int forecast_3_time_epoch;
    int forecast_6_time_epoch;
    int forecast_9_time_epoch;
    int forecast_3_time_epochHOME;
    int forecast_6_time_epochHOME;
    int forecast_9_time_epochHOME;
    IBInspectable int xx;
    
    int errorCounter;
    BOOL mayNeedToRunGetBothWeather;

}
@property (weak, nonatomic) IBOutlet UITextView *gethomeWXtext;
@property (weak, nonatomic) IBOutlet UITextView *backgroundCallText;
@property (weak, nonatomic) IBOutlet UIView *loadingDarkView;
@property (weak, nonatomic) IBOutlet UIImageView *currentIcon;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *buttonMainViewEffect;
@property (weak, nonatomic) IBOutlet UIView *buttonContainer;
@property (weak, nonatomic) IBOutlet UILabel *tempSymbol;
@property (weak, nonatomic) IBOutlet UILabel *currentLocationWeatherTime;
@property (weak, nonatomic) IBOutlet UILabel *tempSymbolCurrent1;
@property (weak, nonatomic) IBOutlet UILabel *tempSymbolCurrent2;
@property (weak, nonatomic) IBOutlet UILabel *tempSymbolCurrent3;
@property (weak, nonatomic) IBOutlet UILabel *tempSymbolHome1;
@property (weak, nonatomic) IBOutlet UILabel *tempSymbolHome2;
@property (weak, nonatomic) IBOutlet UILabel *tempSymbolHome3;
@property (weak, nonatomic) IBOutlet UIImageView *forecast_3_icon_view;
@property (weak, nonatomic) IBOutlet UIImageView *forecast_6_icon_view;
@property (weak, nonatomic) IBOutlet UIImageView *forecast_9_icon_view;

//HOME LOCATION SET
@property (weak, nonatomic) IBOutlet UIImageView *forecast_3_icon_viewHOME;
@property (weak, nonatomic) IBOutlet UIImageView *forecast_6_icon_viewHOME;
@property (weak, nonatomic) IBOutlet UIImageView *forecast_9_icon_viewHOME;

@property (strong, nonatomic) IBOutlet UIVisualEffectView *midletop;
@property (strong, nonatomic) IBOutlet UIView *img;
@property (weak, nonatomic) IBOutlet UILabel *weatherDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *settingsButton;

@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
- (void) getRandomGPS;

@end

@implementation ViewController

-(BOOL)isNetworkAvailable
{
    char *hostname;
    struct hostent *hostinfo;
    hostname = "google.com";
    hostinfo = gethostbyname (hostname);
    if (hostinfo == NULL){
        NSLog(@"-> no connection!\n");
        return NO;
    }
    else{
        NSLog(@"-> connection established!\n");
        return YES;
    }
}
- (IBAction)requestRefreshButtonPressed:(id)sender
{
    NSLOG_SPACER
    NSLog(@"CALLED GETHOMEWEATHER FROM requestRefreshButtonPressed");
    [self getHomeWeather];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    TableViewController *vc = segue.destinationViewController;
    
    vc.homeInformationFromRoot = [self.homeInformation mutableCopy];
}

-(int) convertKelvinToFaranheit: (int) temperatureInKelvin
{
    int temperatureInFaranheit = (temperatureInKelvin - 273.15)*1.8+32;
    return temperatureInFaranheit;
}

- (UIBackgroundFetchResult *) getHomeWeatherOnlyForBackground
{
    
    UIBackgroundFetchResult *result;
    
    //make sure home location is available before calling, assign home loc
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"homeInformation"] != nil)
    {
        NSMutableArray *temp = [NSMutableArray arrayWithObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"homeInformation"]];
        
        self.homeInformation = [NSKeyedUnarchiver unarchiveObjectWithData:temp[0]];
    }
    else
    {
        UILocalNotification *alert = [[UILocalNotification alloc]init];
        
        alert.fireDate = [NSDate date];
        
        alert.alertTitle = @"No Home Location Detected";
        alert.alertBody = @"Please set your home address.";
        alert.applicationIconBadgeNumber = 1;
        
        [[UIApplication sharedApplication] scheduleLocalNotification:alert];
    }
    
    //load username or prompt user if missing
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"userName"] == nil || [[NSUserDefaults standardUserDefaults] stringForKey:@"userName"] == NULL || [[[NSUserDefaults standardUserDefaults] stringForKey:@"userName"] isEqualToString:@""])
    {
        
        UILocalNotification *alert = [[UILocalNotification alloc]init];
        
        alert.fireDate = [NSDate date];
        
        alert.alertTitle = @"Please enter your first name in the settings view";
        alert.alertBody = @"Your name will be used to provide a personal experience.";
        alert.applicationIconBadgeNumber = 1;
        
        [[UIApplication sharedApplication] scheduleLocalNotification:alert];
        
    }
    
    NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastBackgroundWeatherDateCalled"];
    float dateInterval =[[NSDate date] timeIntervalSinceDate:date];
    NSLog(@"SECONDS SINCE LAST CALL: %f",dateInterval);
    
    if (date == nil || dateInterval >= 14400)//3600 secs = 1hr
    {
        if ([self.homeInformation count]>=3)
        {
            
            NSMutableDictionary *oldWeatherToCompare = [[NSUserDefaults standardUserDefaults] objectForKey:@"homeWeatherDictionary"];
            homeWeatherDictionary = nil;
            
            //RETRIEVE HOME LOCATION FROM ARRAY
            CLLocation *homeLocation = self.homeInformation[0];
            
            //    //FINAL STRING WITH API KEY
            //    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%.8f&lon=%.8f&APPID=a96ff77043a749a97158ecbaaa30f249", location.coordinate.latitude, location.coordinate.longitude];
            
            //USING DURING TESTING api.openweathermap.org/data/2.5/forecast?lat=32.986775&lon=-97.37743
            //NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%.8f&lon=%.8f", location.coordinate.latitude, location.coordinate.longitude];
            
            NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast?lat=%.8f&lon=%.8f", homeLocation.coordinate.latitude, homeLocation.coordinate.longitude];
            
            NSURL *url = [NSURL URLWithString:urlString];
            NSData *data = [NSData dataWithContentsOfURL:url];
            
                homeWeatherDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            
                [[NSUserDefaults standardUserDefaults] setObject:homeWeatherDictionary forKey:@"homeWeatherDictionary"];
                
                //set date of last weather call
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastBackgroundWeatherDateCalled"];
            
            
            
            ///////////////////////////////////////////////////
            
            
            backgroundCallTextARRAY = [backgroundCallTextARRAY mutableCopy];
            [backgroundCallTextARRAY addObject:[self getStringFromDateFORTESTING:[NSDate date]]];
            [[NSUserDefaults standardUserDefaults] setObject:backgroundCallTextARRAY forKey:@"backgroundCallTextARRAY"];
            
            
            ///////////////////////////////////////////////////
            
            
            
            
            
            
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                NSString *weatherJSON = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                //        NSLOG_SPACER
                //        NSLog(@"%@",weatherDictionary);
                //        NSLOG_SPACER
                       NSLog(@"json string from getHomeWeatherBACKGROUNDonly \n%@", weatherJSON);
                //        NSLOG_SPACER
            
            if (homeWeatherDictionary != nil)
            {
                if (![oldWeatherToCompare isEqualToDictionary:homeWeatherDictionary])
                {

                    result = UIBackgroundFetchResultNewData;
                }
                else//dictionary is not nil and matches, so no new data downloaded
                {
                    result = UIBackgroundFetchResultNoData;
                }
            }
            
        }
        
    }
    if ((int)result == 0) //0 new data, 1 no data, 2 failed
    {
        result = UIBackgroundFetchResultNewData;
    }
    else if ((int) result == 1)
    {
        result = UIBackgroundFetchResultNoData;
    }
    else
    {
        result = UIBackgroundFetchResultFailed;
    }
    
        
    return result;
}

//- (UIBackgroundFetchResult *) getHomeWeatherOnlyForBackground
//{
//    UIBackgroundFetchResult *result = UIBackgroundFetchResultNoData;
//    
//    //make sure home location is available before calling, assign home loc
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"homeInformation"] != nil)
//    {
//        NSMutableArray *temp = [NSMutableArray arrayWithObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"homeInformation"]];
//        
//        self.homeInformation = [NSKeyedUnarchiver unarchiveObjectWithData:temp[0]];
//    }
//    
//    NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastBackgroundWeatherDateCalled"];
//    float dateInterval =[[NSDate date] timeIntervalSinceDate:date];
//    NSLog(@"SECONDS SINCE LAST CALL: %f",dateInterval);
//    
//    if (date == nil || dateInterval > weatherTimer)
//    {
//        if ([self.homeInformation count]>=3)
//        {
//            
//            NSDictionary *oldWeatherToCompare = [[NSUserDefaults standardUserDefaults] objectForKey:@"homeWeatherDictionary"];
//            NSMutableDictionary *homeWeatherBackgroundDictionary;
//            homeWeatherDictionary = [[NSMutableDictionary alloc]init];
//    
//                //RETRIEVE HOME LOCATION FROM ARRAY
//                CLLocation *homeLocation = self.homeInformation[0];
//                
//                //    //FINAL STRING WITH API KEY
//                //    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%.8f&lon=%.8f&APPID=a96ff77043a749a97158ecbaaa30f249", location.coordinate.latitude, location.coordinate.longitude];
//                
//                //USING DURING TESTING api.openweathermap.org/data/2.5/forecast?lat=32.986775&lon=-97.37743
//                //NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%.8f&lon=%.8f", location.coordinate.latitude, location.coordinate.longitude];
//                
//                NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast?lat=%.8f&lon=%.8f", homeLocation.coordinate.latitude, homeLocation.coordinate.longitude];
//                
//                NSURL *url = [NSURL URLWithString:urlString];
//                NSURLRequest *request = [NSURLRequest requestWithURL:url];
//                
//                NSURLSessionDataTask *datatask = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//                    homeWeatherDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//                    
//                    [[NSUserDefaults standardUserDefaults] setObject:homeWeatherBackgroundDictionary forKey:@"homeWeatherDictionary"];
//                    
//                    //set date of last weather call
//                    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastBackgroundWeatherDateCalled"];
//                    [[NSUserDefaults standardUserDefaults] synchronize];
//                    
//                    NSString *weatherJSON = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//                    //        NSLOG_SPACER
//                    //        NSLog(@"%@",weatherDictionary);
//                    //        NSLOG_SPACER
//             //       NSLog(@"json string from getHomeWeatherBACKGROUNDonly \n%@", weatherJSON);
//                    //        NSLOG_SPACER
//
//                    
//                }];
//                [datatask resume];
//            
//            if (homeWeatherDictionary != nil)
//            {
//                if ([oldWeatherToCompare isEqualToDictionary:homeWeatherDictionary] == YES)
//                {
//                    NSLOG_SPACER
//                    NSLOG_SPACER
//                    NSLog(@"NEW DATA FETCHED FROM BACKGROUND!");
//                    NSLOG_SPACER
//                    result = UIBackgroundFetchResultNewData;
//                }
//                else//dictionary is not nil and matches, so no new data downloaded
//                {
//                    NSLog(@"NO NEW DATA FETCHED FROM BACKGROUND!");
//                }
//            }
//            
//        }
//        
//    }
//    return result;
//}

- (NSMutableDictionary *) getHomeWeather
{
    if ([self  isNetworkAvailable] == NO)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Unable to retrieve Weather" message:@"There may be an issue with the network connection or access to your location." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                         {
                                             [[UIApplication sharedApplication] openURL:[NSURL URLWithString:
                                                                                         UIApplicationOpenSettingsURLString]];
                                         }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:settingsAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
        // Construct URL to sound file
        SystemSoundID soundID;
        
        NSURL *fileURL = [NSURL URLWithString:@"/System/Library/Audio/UISounds/Modern/sms_alert_note.caf"];
        
        AudioServicesCreateSystemSoundID((__bridge_retained CFURLRef)fileURL , &soundID);
        
        AudioServicesPlayAlertSound (soundID);
        return nil;
    }
    
    
    
    
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"weatherDictionary"] != nil && weatherDictionary == nil)
    {
        weatherDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:@"weatherDictionary"];
        
        NSLog(@"[[NSUserDefaults standardUserDefaults] objectForKey:@'weatherDictionary'] != nil && weatherDictionary == nil)");
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"homeWeatherDictionary"] != nil && homeWeatherDictionary == nil)
        {
            homeWeatherDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:@"homeWeatherDictionary"];
            NSLog(@"[[NSUserDefaults standardUserDefaults] objectForKey:@'homeWeatherDictionary'] != nil && homeWeatherDictionary == nil)");
            
        }
    }
    
    
    
    
    
    
    NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastWeatherDateCalled"];
    float dateInterval =[[NSDate date] timeIntervalSinceDate:date];
    NSLog(@"interval in getHomeWeather: %f",dateInterval);
    
    if (setHomeLocationTriggered == YES || weatherDictionary ==nil || homeWeatherDictionary == nil || date == nil || dateInterval >= weatherTimer)
    {
        //used to delegate if we should run both wx, will be changed back to no in that method or below if we just run homewx method
        mayNeedToRunGetBothWeather = YES;
        
        setHomeLocationTriggered = NO;
        homeWeatherDictionary = nil;

    
        //RUNNING WEATHER UPDATE FOR HOME IF HOME IS DIFF FROM CURRENT LOC
        if ([self.homeInformation count]>=3)
        {
            if ([self.homeInformation[2] isEqualToString:addressFromGEO[1]] == NO)
            {
                //running this method instead
                mayNeedToRunGetBothWeather = NO;
                
                //RETRIEVE HOME LOCATION FROM ARRAY
                CLLocation *homeLocation = self.homeInformation[0];
                
                //    //FINAL STRING WITH API KEY
                //    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%.8f&lon=%.8f&APPID=a96ff77043a749a97158ecbaaa30f249", location.coordinate.latitude, location.coordinate.longitude];
                
                //USING DURING TESTING api.openweathermap.org/data/2.5/forecast?lat=32.986775&lon=-97.37743
                //NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%.8f&lon=%.8f", location.coordinate.latitude, location.coordinate.longitude];
                
                NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast?lat=%.8f&lon=%.8f", homeLocation.coordinate.latitude, homeLocation.coordinate.longitude];
                
                NSURL *url = [NSURL URLWithString:urlString];
                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                
                NSURLSessionDataTask *datatask = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    homeWeatherDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:homeWeatherDictionary forKey:@"homeWeatherDictionary"];
                   
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    NSString *weatherJSON = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                    //        NSLOG_SPACER
                    //        NSLog(@"%@",weatherDictionary);
                    //        NSLOG_SPACER
       //             NSLog(@"json string from getHomeWeather \n%@", weatherJSON);
                    //        NSLOG_SPACER
                    
                }];
                [datatask resume];
                
                //NOW GET CURRENT WEATHER DATA
                [self getWeather];
                
            }
            else if ([self.homeInformation[2] isEqualToString:addressFromGEO[1]] == YES)
            {
                [self getBothWeather];
            }
        }
        
        else
        {
            [self getWeather];
        }
        
    }
    else
    {
        [self postWeatherToLabels];
    }
    
    return homeWeatherDictionary;
}

- (NSMutableDictionary *) getWeather
{
//    //FINAL STRING WITH API KEY
//    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%.8f&lon=%.8f&APPID=a96ff77043a749a97158ecbaaa30f249", location.coordinate.latitude, location.coordinate.longitude];
    
    //USING DURING TESTING api.openweathermap.org/data/2.5/forecast?lat=32.986775&lon=-97.37743
    //NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%.8f&lon=%.8f", location.coordinate.latitude, location.coordinate.longitude];
    
    //running this method instead
    mayNeedToRunGetBothWeather = NO;
    
    if (location == nil || location == NULL)
    {
        NSLog(@"WRONG: LOCATION WAS NIL/NULL IN GETWEATHER!");
        [[NSUserDefaults standardUserDefaults] synchronize];
        return nil;
    }
    
    NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastWeatherDateCalled"];
    float dateInterval =[[NSDate date] timeIntervalSinceDate:date];
    NSLog(@"interval in getHomeWeather: %f",dateInterval);
    
    
    if (weatherDictionary == nil || date == nil || dateInterval >= weatherTimer)
    {
    
        
            weatherDictionary = nil;

        
    
        NSLog(@"location from getweather: %@",location);
        NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast?lat=%.8f&lon=%.8f", location.coordinate.latitude, location.coordinate.longitude];
        
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSURLSessionDataTask *datatask = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            weatherDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            //[weatherDictionary setObject: forKey:<#(id<NSCopying>)#>]
                
            NSString *weatherJSON = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    //        NSLOG_SPACER
    //        NSLog(@"%@",weatherDictionary);
    //        NSLOG_SPACER
          //    NSLog(@"json string from getWeather\n%@", weatherJSON);
    //        NSLOG_SPACER
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[NSUserDefaults standardUserDefaults] setObject:weatherDictionary forKey:@"weatherDictionary"];

                //set date of last weather call
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastWeatherDateCalled"];
                
                
                
                ///////////////////////////////////////////////////
                
                
                gethomeWXtextARRAY = [gethomeWXtextARRAY mutableCopy];
                [gethomeWXtextARRAY addObject:[self getStringFromDateFORTESTING:[NSDate date]]];
                [[NSUserDefaults standardUserDefaults] setObject:gethomeWXtextARRAY forKey:@"gethomeWXtextARRAY"];
                
                
                ///////////////////////////////////////////////////
                
                
                
                
                
                
                
                
                
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self postWeatherToLabels];

            });
        }];
        [datatask resume];
    }
    else
    {
        [self postWeatherToLabels];
    }
    
    return weatherDictionary;
}

- (NSMutableDictionary *) getBothWeather
{
    //make sure home location is available before calling, assign home loc
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"homeInformation"] != nil)
    {
        NSMutableArray *temp = [NSMutableArray arrayWithObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"homeInformation"]];
        
        self.homeInformation = [NSKeyedUnarchiver unarchiveObjectWithData:temp[0]];
    }
    
    NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastWeatherDateCalled"];
    float dateInterval =[[NSDate date] timeIntervalSinceDate:date];
    NSLog(@"interval in getHomeWeather: %f",dateInterval);
    
    if ([self.homeInformation count]>=3 && dateInterval >= weatherTimer)
    {
        mayNeedToRunGetBothWeather = NO;
        weatherDictionary = nil;

        
            //RETRIEVE HOME LOCATION FROM ARRAY
            CLLocation *homeLocation = self.homeInformation[0];
        
        //    //FINAL STRING WITH API KEY
        //    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%.8f&lon=%.8f&APPID=a96ff77043a749a97158ecbaaa30f249", location.coordinate.latitude, location.coordinate.longitude];
        
        //USING DURING TESTING api.openweathermap.org/data/2.5/forecast?lat=32.986775&lon=-97.37743
        //NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%.8f&lon=%.8f", location.coordinate.latitude, location.coordinate.longitude];
        
        NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast?lat=%.8f&lon=%.8f", homeLocation.coordinate.latitude, homeLocation.coordinate.longitude];
        
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSURLSessionDataTask *datatask = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            weatherDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                        
            NSString *weatherJSON = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            //        NSLOG_SPACER
            //        NSLog(@"%@",weatherDictionary);
            //        NSLOG_SPACER
       //               NSLog(@"json string from getBothWeather\n%@", weatherJSON);
            //        NSLOG_SPACER
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[NSUserDefaults standardUserDefaults] setObject:weatherDictionary forKey:@"weatherDictionary"];
                [[NSUserDefaults standardUserDefaults] setObject:weatherDictionary forKey:@"homeWeatherDictionary"];
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastWeatherDateCalled"];
                
                
                
                
                
                
                ///////////////////////////////////////////////////
                
                
                gethomeWXtextARRAY = [gethomeWXtextARRAY mutableCopy];
                [gethomeWXtextARRAY addObject:[self getStringFromDateFORTESTING:[NSDate date]]];
                [[NSUserDefaults standardUserDefaults] setObject:gethomeWXtextARRAY forKey:@"gethomeWXtextARRAY"];
                
                
                ///////////////////////////////////////////////////
                
                
                
                
                
                
                
                
                
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self postWeatherToLabels];
                
            });
        }];
        [datatask resume];
    }
    else if (mayNeedToRunGetBothWeather)
    {
        mayNeedToRunGetBothWeather = NO;
        
        weatherDictionary = nil;
        
        
        //RETRIEVE HOME LOCATION FROM ARRAY
        CLLocation *homeLocation = self.homeInformation[0];
        
        //    //FINAL STRING WITH API KEY
        //    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%.8f&lon=%.8f&APPID=a96ff77043a749a97158ecbaaa30f249", location.coordinate.latitude, location.coordinate.longitude];
        
        //USING DURING TESTING api.openweathermap.org/data/2.5/forecast?lat=32.986775&lon=-97.37743
        //NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%.8f&lon=%.8f", location.coordinate.latitude, location.coordinate.longitude];
        
        NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast?lat=%.8f&lon=%.8f", homeLocation.coordinate.latitude, homeLocation.coordinate.longitude];
        
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSURLSessionDataTask *datatask = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            weatherDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            NSString *weatherJSON = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            //        NSLOG_SPACER
            //        NSLog(@"%@",weatherDictionary);
            //        NSLOG_SPACER
         //         NSLog(@"json string from getBothWeather\n%@", weatherJSON);
            //        NSLOG_SPACER
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[NSUserDefaults standardUserDefaults] setObject:weatherDictionary forKey:@"weatherDictionary"];
                [[NSUserDefaults standardUserDefaults] setObject:weatherDictionary forKey:@"homeWeatherDictionary"];
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastWeatherDateCalled"];
                
                
                
                
                
                
                ///////////////////////////////////////////////////
                
                
                gethomeWXtextARRAY = [gethomeWXtextARRAY mutableCopy];
                [gethomeWXtextARRAY addObject:[self getStringFromDateFORTESTING:[NSDate date]]];
                [[NSUserDefaults standardUserDefaults] setObject:gethomeWXtextARRAY forKey:@"gethomeWXtextARRAY"];
                
                
                ///////////////////////////////////////////////////
                
                
                
                
                
                
                
                
                
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self postWeatherToLabels];
                
            });
        }];
        [datatask resume];

    }
    
    else if(weatherDictionary != nil)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[NSUserDefaults standardUserDefaults] setObject:weatherDictionary forKey:@"weatherDictionary"];
            [[NSUserDefaults standardUserDefaults] setObject:weatherDictionary forKey:@"homeWeatherDictionary"];
            
            
            
            
            
            ///////////////////////////////////////////////////
            

            
            ///////////////////////////////////////////////////
            
            
            
            
            
            
            
            
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self postWeatherToLabels];
            
        });
    }
    
    if (self.loadingActivityView.hidden == NO)
    {
        self.loadingActivityView.hidden = YES;
        
    }
    
    return weatherDictionary;
}


- (NSURLSession *) session
{
    if (!_session)
    {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:nil];
    }
    return _session;
}

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"Welcome to %@", region.identifier);
    [[[UIAlertView alloc]initWithTitle:@"ENTERED REGION" message:@"WELCOME HOME" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil]show];
}


-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"Bye bye");
    [[[UIAlertView alloc]initWithTitle:@"didExitRegion" message:@"Bye bye" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil]show];
    
    int wxTEMP0 = [self convertKelvinToFaranheit:[[[[homeWeatherDictionary objectForKey:@"list"][0] objectForKey:@"main"] objectForKey:@"temp"] intValue]];
    int wxTEMP1 = [self convertKelvinToFaranheit:[[[[homeWeatherDictionary objectForKey:@"list"][1] objectForKey:@"main"] objectForKey:@"temp"] intValue]];
    int wxTEMP2 = [self convertKelvinToFaranheit:[[[[homeWeatherDictionary objectForKey:@"list"][2] objectForKey:@"main"] objectForKey:@"temp"] intValue]];
    
    NSString *wxTEMP0Rain = [[[homeWeatherDictionary objectForKey:@"list"][0] objectForKey:@"weather"][0] objectForKey:@"description"];
    NSString *city = [[homeWeatherDictionary objectForKey:@"city"] objectForKey:@"name"];

    NSString *wxTEMP1Rain = [[[homeWeatherDictionary objectForKey:@"list"][0] objectForKey:@"weather"][0] objectForKey:@"description"];
    NSLog(@"TESTING: %@",wxTEMP0Rain);
    NSString *wxTEMP2Rain = [[[homeWeatherDictionary objectForKey:@"list"][0] objectForKey:@"weather"][0] objectForKey:@"description"];
    
    int watchertemp =[[NSUserDefaults standardUserDefaults] integerForKey:@"monitoredTemp"];
    
    if (wxTEMP0 < watchertemp || wxTEMP1 < watchertemp || wxTEMP2 < watchertemp)
    
    {
        if ([wxTEMP0Rain containsString:@"rain"] || [wxTEMP1Rain containsString:@"rain"] || [wxTEMP2Rain containsString:@"rain"])
        {
            UILocalNotification *alert = [[UILocalNotification alloc]init];
            
            alert.fireDate = [NSDate date];
            
            alert.alertTitle = [NSString stringWithFormat:@"Yo %@,", self.userName];
            NSLog(@"username to call is=%@",self.userName);
            alert.alertBody = [NSString stringWithFormat:@"Don't forget your jacket!\nAnd you may get a little wet..."];
            alert.soundName = UILocalNotificationDefaultSoundName;
            
            [[UIApplication sharedApplication] scheduleLocalNotification:alert];
            NSLog(@"it'll rain!");
        }
        
        else
        {
            UILocalNotification *alert = [[UILocalNotification alloc]init];

            alert.fireDate = [NSDate date];

            alert.alertTitle = [NSString stringWithFormat:@"Yo %@,", self.userName];
            NSLog(@"username to call is=%@",self.userName);
            alert.alertBody = [NSString stringWithFormat:@"Don't forget your jacket!"];
            alert.soundName = UILocalNotificationDefaultSoundName;
            alert.applicationIconBadgeNumber = 1;

            [[UIApplication sharedApplication] scheduleLocalNotification:alert];
        }
    
    }
    
    //not cold enough, but it'll rain
    else if ([wxTEMP0Rain containsString:@"rain"] || [wxTEMP1Rain containsString:@"rain"] || [wxTEMP2Rain containsString:@"rain"])
    {
        UILocalNotification *alert = [[UILocalNotification alloc]init];
        
        alert.fireDate = [NSDate date];
        
        alert.alertTitle = [NSString stringWithFormat:@"Yo %@,", self.userName];
        NSLog(@"username to call is=%@",self.userName);
        alert.alertBody = [NSString stringWithFormat:@"You may get a little wet..."];
        alert.soundName = UILocalNotificationDefaultSoundName;
        
        [[UIApplication sharedApplication] scheduleLocalNotification:alert];
        NSLog(@"it'll rain!");
    }
    
                
    
}

-(void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    NSLog(@"Now monitoring for %@", region.identifier);
}

- (IBAction)setHomeLocation:(id)sender
{
    if (self.loadingActivityView.hidden == YES)
    {
        self.loadingActivityView.hidden = NO;

    }
    
    //if new home loc city is differnt, we need to get weather
    if (![self.homeInformation[2] isEqualToString:addressFromGEO[1]])
    {
        setHomeLocationTriggered = YES;
    }

    
    CLCircularRegion *regionCirc = [[CLCircularRegion alloc]initWithCenter:location.coordinate radius:100 identifier:@"Home"];
    [self.locationManager startMonitoringForRegion:regionCirc];
    
    ////////////////////////
    //GET GPS AT RANDOM
    //[self getRandomGPS];
    ////////////////////////
    
    if (location && self.addressLabel.text.length>0)
    {
        self.homeInformation = [NSMutableArray array];
        [self.homeInformation addObject:location];
        [self.homeInformation addObject:self.addressLabel.text];
        [self.homeInformation addObject:addressFromGEO[1]];
        
        
        //wrapped mutable array to store it in defaults
        NSData *arrayWrapper = [NSKeyedArchiver archivedDataWithRootObject:self.homeInformation];
        
        [[NSUserDefaults standardUserDefaults] setObject:arrayWrapper forKey:@"homeInformation"];
        
        homeWeatherDictionary = weatherDictionary;
        
        [[NSUserDefaults standardUserDefaults] setObject:homeWeatherDictionary forKey:@"homeWeatherDictionary"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        atHome = YES;
        NSLog(@"JUST SET HOME, athome = %d",atHome);

        if ([self  isNetworkAvailable] == NO)
        {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Unable to retrieve Weather" message:@"There may be an issue with the network connection or access to your location." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                             {
                                                 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:
                                                                                             UIApplicationOpenSettingsURLString]];
                                             }];
            
            [alertController addAction:cancelAction];
            [alertController addAction:settingsAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
            
            // Construct URL to sound file
            SystemSoundID soundID;
            
            NSURL *fileURL = [NSURL URLWithString:@"/System/Library/Audio/UISounds/Modern/sms_alert_note.caf"];
            
            AudioServicesCreateSystemSoundID((__bridge_retained CFURLRef)fileURL , &soundID);
            
            AudioServicesPlayAlertSound (soundID);
        }
        else
        {
        
        //call on background to improve button performance and allow action to unhide loading view
            NSLOG_SPACER
            NSLog(@"CALLED GETHOMEWEATHER FROM SETHOMELOCATION");
        [self performSelectorInBackground:@selector(getHomeWeather) withObject:nil];
        
        }
        
    }
    
    else if (!location || self.addressLabel<=0)
    {
        if (self.loadingActivityView.hidden == NO)
        {
            self.loadingActivityView.hidden = YES;
            
        }
        
        //[[[UIAlertView alloc]initWithTitle:@"ADDR ISSUE" message:@"UNABLE TO DETECT LOC" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil]show];
        [self.locationManager startUpdatingLocation];
    }
    
    if (self.loadingActivityView.hidden == NO)
    {
        self.loadingActivityView.hidden = YES;
        
    }
    
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //load username or prompt user if missing
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"userName"] == nil || [[NSUserDefaults standardUserDefaults] stringForKey:@"userName"] == NULL || [[[NSUserDefaults standardUserDefaults] stringForKey:@"userName"] isEqualToString:@""])
    {
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Please enter your first name" message:@"Your name will be used to provide a personal experience." preferredStyle:UIAlertControllerStyleAlert];
//        
//        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//            self.userName = ((UITextField *) alertController.textFields[0]).text;
//            [[NSUserDefaults standardUserDefaults] setObject:self.userName forKey:@"userName"];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//            NSLog(@"JUST SAVED USER: %@",self.userName);
//        }];
//        
//        [alertController addAction:okAction];
//        
//        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
//            textField.placeholder = @"First Name";
//        }];
//        
//        [self presentViewController:alertController animated:YES completion:nil];
        
    }
    
    else
    {
        self.userName = [[NSUserDefaults standardUserDefaults] stringForKey:@"userName"];
    }

}



-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if (self.loadingActivityView.hidden == YES)
    {
        self.loadingActivityView.hidden = NO;
        
    }
    
    
    
    
    
        //load username or prompt user if missing
        if ([[NSUserDefaults standardUserDefaults] stringForKey:@"userName"] == nil || [[NSUserDefaults standardUserDefaults] stringForKey:@"userName"] == NULL || [[[NSUserDefaults standardUserDefaults] stringForKey:@"userName"] isEqualToString:@""])
        {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Please enter your first name" message:@"Your name will be used to provide a personal experience." preferredStyle:UIAlertControllerStyleAlert];
    
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                self.userName = ((UITextField *) alertController.textFields[0]).text;
                [[NSUserDefaults standardUserDefaults] setObject:self.userName forKey:@"userName"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                NSLog(@"JUST SAVED USER: %@",self.userName);
            }];
    
            [alertController addAction:okAction];
    
            [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.placeholder = @"First Name";
            }];
    
            [self presentViewController:alertController animated:YES completion:nil];
    
        }
    
        else
        {
            self.userName = [[NSUserDefaults standardUserDefaults] stringForKey:@"userName"];
        }

    
    //wrapped mutable array to store it in defaults
    NSData *arrayWrapperLocations = [NSKeyedArchiver archivedDataWithRootObject:self.homeInformation];
    
    [[NSUserDefaults standardUserDefaults] setObject:arrayWrapperLocations forKey:@"locationsFromLocationManager"];
    //[[NSUserDefaults standardUserDefaults] synchronize];

    //[self.locationManager stopUpdatingLocation];

    location = locations[0];

    //DISTANCE FROM HOUSE TO NEXT DOOR = 16.606390
 //   CLLocationDistance distance = [location distanceFromLocation: self.homeInformation[0]];
    
    NSLog(@"CURRENT LOCATION: %@",location);
    NSLog(@"\natHome BOOL = %d",atHome);

    
//    if (location && [self.homeInformation count] >= 3 && distance <=18)
//    {
//        if (atHome == YES)
//        {
//            NSLog(@"ALREADY AT HOME");
//        }
//        
//        else//just got home
//        {
//            atHome = YES;
//            
//            NSLog(@"JUST GOT HOME");
//            NSLog(@"\n\nDISTANCE =%f",distance);
//        }
//    }
//    
//    else if (location && [self.homeInformation count] >= 3 && distance >18)
//    {
//        if (atHome == YES)
//        {
//            atHome = NO;
//            NSLog(@"JUST LEFT HOME");
//            
//            int wxTEMP = [self convertKelvinToFaranheit:[[[[homeWeatherDictionary objectForKey:@"list"][0] objectForKey:@"main"] objectForKey:@"temp"] intValue]];
//            int watchertemp =[[NSUserDefaults standardUserDefaults] integerForKey:@"monitoredTemp"];
//            NSLog(@"\nwxtemp=%d\nwatchertemp=%d",wxTEMP,watchertemp);
//
//            if (wxTEMP < watchertemp)
//            {
//                UILocalNotification *alert = [[UILocalNotification alloc]init];
//                
//                alert.fireDate = [NSDate date];
//                
//                alert.alertTitle = [NSString stringWithFormat:@"Yo %@,", self.userName];
//                NSLog(@"username to call is=%@",self.userName);
//                alert.alertBody = [NSString stringWithFormat:@"Don't forget your jacket!"];
//                alert.soundName = UILocalNotificationDefaultSoundName;
//                
//                [[UIApplication sharedApplication] scheduleLocalNotification:alert];
//            }
//            
//        }
//        
//        else//BEEN OUT AND ABOUT
//        {
//            NSLog(@"STILL OUT AND ABOUT");
//            NSLog(@"\n\nDISTANCE =%f",distance);
//        }
//    }
//    
//    //SAVE atHome BOOL
//    [[NSUserDefaults standardUserDefaults] setBool:atHome forKey:@"atHome"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    NSLog(@"AT HOME NOW = %d",[[NSUserDefaults standardUserDefaults] boolForKey:@"atHome"]);
    
    
//    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"homeInformation"])
//    {
//        [self setHomeLocation:self];
//        
//    }

  //  [self getHomeWeather];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
    {
        
        //NSMutableArray *tempArray = [[NSMutableArray alloc]init];
        for (CLPlacemark *placemark in placemarks)
        {
            [addressFromGEO replaceObjectAtIndex:0 withObject:[NSString stringWithFormat:@"%@ %@\n%@ %@ %@\n%@",
                                  placemark.subThoroughfare,
                                  placemark.thoroughfare,
                                  placemark.locality,
                                  placemark.administrativeArea,
                                  placemark.postalCode,
                                  placemark.country]];
            
            //in case user is not in a static spot, possibly driving
            if (placemark.subThoroughfare == nil)
            {
                [addressFromGEO replaceObjectAtIndex:0 withObject:[NSString stringWithFormat:@"%@\n%@ %@ %@\n%@",
                                                              placemark.thoroughfare,
                                                              placemark.locality,
                                                              placemark.administrativeArea,
                                                              placemark.postalCode,
                                                              placemark.country]];
            }
            
            //in case user is not in a static spot, possibly driving AND only has region info
            if (placemark.thoroughfare == nil)
            {
                [addressFromGEO replaceObjectAtIndex:0 withObject:[NSString stringWithFormat:@"%@ %@ %@\n%@",
                                                              placemark.locality,
                                                              placemark.administrativeArea,
                                                              placemark.postalCode,
                                                              placemark.country]];
            }
            //added city to compare from home loc to current loc
            [addressFromGEO replaceObjectAtIndex:1 withObject:placemark.locality];
        }

        self.addressLabel.text = addressFromGEO[0];
        
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"homeInformation"] == nil)
        {
            [self setHomeLocation:self];
        }
        else
        {
            
            
            ///////////////////////
            NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastWeatherDateCalled"];
            float dateInterval =[[NSDate date] timeIntervalSinceDate:date];
            if (dateInterval >= weatherTimer || setHomeLocationTriggered == YES)
            {
                            NSLOG_SPACER
                            NSLog(@"CALLED GETHOMEWEATHER FROM DIDUPDATELOC DEL");
                            [self getHomeWeather];
            }
            /////////////////////
            
            
//            NSLOG_SPACER
//            NSLog(@"CALLED GETHOMEWEATHER FROM DIDUPDATELOC DEL");
//            [self getHomeWeather];
            
        }
        
    }];
    

    
    if (self.loadingActivityView.hidden == NO)
    {
        self.loadingActivityView.hidden = YES;
        
    }
    
}

-(void) unhideLoaderView
{
    if (self.loadingActivityView.hidden == YES)
    {
        self.loadingActivityView.hidden = NO;
        
    }
}

- (int) postWeatherToLabels
{
    [self performSelectorInBackground:@selector(unhideLoaderView) withObject:nil];
    
    
    
    
    
    
    ///////////////////////////////////////////////////
    
    
    [self gethomeWXtextARRAYMETHOD];
    [self backgroundCallTextARRAYMETHOD];
    
    
    ///////////////////////////////////////////////////
    
    
    
    
    
    
    
    if ([addressFromGEO count] > 1 && ![self.addressLabel.text isEqualToString:addressFromGEO[0]])
    {
        if (![addressFromGEO[0] isEqualToString:@""])
        {
            self.addressLabel.text = addressFromGEO[0];
        }
        
        else if ([[NSUserDefaults standardUserDefaults] objectForKey:@"locationsFromLocationManager"] != nil)
        {
            NSMutableArray *temp = [NSMutableArray arrayWithObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"locationsFromLocationManager"]];

            NSArray *arrayLocations = [NSKeyedUnarchiver unarchiveObjectWithData:temp[0]];
            [self.locationManager.delegate locationManager:self.locationManager didUpdateLocations:arrayLocations];
        }

    }
    else if ([addressFromGEO count] > 1 && [addressFromGEO[0] isEqualToString:@""])
    {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"locationsFromLocationManager"] != nil)
        {
            NSMutableArray *temp = [NSMutableArray arrayWithObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"locationsFromLocationManager"]];
            
            NSArray *arrayLocations = [NSKeyedUnarchiver unarchiveObjectWithData:temp[0]];
            [self.locationManager.delegate locationManager:self.locationManager didUpdateLocations:arrayLocations];
        }

    }
    

    if ([addressFromGEO[1] isEqualToString:self.homeInformation[2]])
    {
        homeWeatherDictionary = weatherDictionary;
        [[NSUserDefaults standardUserDefaults] setObject:weatherDictionary forKey:@"homeWeatherDictionary"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if (location)
    {
        if (self.homeInformation != nil)
        {
            if (homeWeatherDictionary == nil || weatherDictionary == nil)
            {
                NSLOG_SPACER
                NSLog(@"CALLED GETHOMEWEATHER FROM POSTWEATHERTOLABELS : LOCATION IS AVAIL AND self.homeInformation != nil AND homeWeatherDictionary == nil || weatherDictionary == nil");
                [self getHomeWeather];
                
            }
        }
        
        else if (weatherDictionary == nil)
        {
            NSLOG_SPACER
            NSLog(@"CALLED GETHOMEWEATHER FROM POSTWEATHERTOLABELS : LOCATION IS AVAIL AND self.homeInformation == nil AND weatherDictionary == nil");
            
                [self getHomeWeather];
 
        }
    }
    else
    {
        return 0;
    }
    
    if ([addressFromGEO[1] isEqualToString:self.homeInformation[2]])
    {
        homeWeatherDictionary = weatherDictionary;
        [[NSUserDefaults standardUserDefaults] setObject:weatherDictionary forKey:@"homeWeatherDictionary"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    //assign symbols
//    self.tempSymbolCurrent1.text = @"\u00B0";
//    self.tempSymbolCurrent2.text = @"\u00B0";
//    self.tempSymbolCurrent3.text = @"\u00B0";
//    self.tempSymbolHome1.text = @"\u00B0";
//    self.tempSymbolHome2.text = @"\u00B0";
//    self.tempSymbolHome3.text = @"\u00B0";

    //self.forecast_3_hr.text = weatherDictionary;
    //NSLog(@"\n%@",weatherDictionary);
    
    //assign temperature to string
    NSString *tempTempString = [NSString stringWithFormat:@"%d",[self convertKelvinToFaranheit:[[[[weatherDictionary objectForKey:@"list"][0] objectForKey:@"main"] objectForKey:@"temp"]intValue]]];
    
    self.temperatureLabel.text = [NSString stringWithFormat:@"%@", tempTempString];
    
    NSArray *aaa = [NSArray arrayWithArray:[[weatherDictionary objectForKey:@"list"][0] objectForKey:@"weather"]];
    if (aaa == nil || [aaa count] == 0)
    {
        aaa = [NSArray arrayWithObject:[NSMutableDictionary dictionary]];
    }
    
    self.currentLocationWeatherTime.text = [self getStringFromDate:[NSDate date]];

    self.weatherDescriptionLabel.text = [[aaa[0] objectForKey:@"description"] capitalizedString];
    
    self.currentIcon.image = [self getIconImage:[aaa[0]  objectForKey:@"icon"]];

 
    int temp = [[[[weatherDictionary objectForKey:@"list"][0] objectForKey:@"main"] objectForKey:@"temp"] intValue];
    //self.forecast_3_hr.text = [NSString stringWithFormat:@"%d", [self convertKelvinToFaranheit:temp]];
    self.forecast_3_hr.text = [NSString stringWithFormat:@"%d\u00B0", [self convertKelvinToFaranheit:temp]];
    
    temp = [[[[weatherDictionary objectForKey:@"list"][1] objectForKey:@"main"] objectForKey:@"temp"] intValue];
    self.forecast_6_hr.text = [NSString stringWithFormat:@"%d\u00B0", [self convertKelvinToFaranheit:temp]];
    
    temp = [[[[weatherDictionary objectForKey:@"list"][2] objectForKey:@"main"] objectForKey:@"temp"] intValue];
    self.forecast_9_hr.text = [NSString stringWithFormat:@"%d\u00B0", [self convertKelvinToFaranheit:temp]];
    
 
    NSString *aa = [[weatherDictionary objectForKey:@"list"][0] objectForKey:@"dt"];
    
    // Convert NSString to NSTimeInterval
    NSTimeInterval seconds = [aa doubleValue];
    
    // (Step 1) Create NSDate object
    NSDate *epochNSDate = [[NSDate alloc] initWithTimeIntervalSince1970:seconds];
    
    // (Step 2) Use NSDateFormatter to display epochNSDate in local time zone
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    
    // (Just for interest) Display your current time zone
    NSString *currentTimeZone = [[dateFormatter timeZone] abbreviation];
    
    forecast_3_time_epoch = [[[weatherDictionary objectForKey:@"list"] [0] objectForKey:@"dt"] intValue];
    forecast_6_time_epoch = [[[weatherDictionary objectForKey:@"list"] [1] objectForKey:@"dt"] intValue];
    forecast_9_time_epoch = [[[weatherDictionary objectForKey:@"list"] [2] objectForKey:@"dt"] intValue];
    

    //NSLog(@"BLAH%@", [[NSDate date] timeIntervalSince1970]);

    //CONVERT EPOCH TO UTC/GMT
    NSDate *date3 = [NSDate dateWithTimeIntervalSince1970:forecast_3_time_epoch];
    NSDate *date6 = [NSDate dateWithTimeIntervalSince1970:forecast_6_time_epoch];
    NSDate *date9 = [NSDate dateWithTimeIntervalSince1970:forecast_9_time_epoch];
    
    self.forecast_3_time.text = [self getStringFromDate:date3];
    self.forecast_6_time.text = [self getStringFromDate:date6];
    self.forecast_9_time.text = [self getStringFromDate:date9];
    
    //CONVERT TO EPOCH SUCH AS 1434505973

    //SET CURRENT LOCATION ICONS
    self.forecast_3_icon_view.image = [self getIconImage:[[[weatherDictionary objectForKey:@"list"][0] objectForKey:@"weather"][0] objectForKey:@"icon"]];
    self.forecast_6_icon_view.image = [self getIconImage:[[[weatherDictionary objectForKey:@"list"][1] objectForKey:@"weather"][0] objectForKey:@"icon"]];
    self.forecast_9_icon_view.image = [self getIconImage:[[[weatherDictionary objectForKey:@"list"][2] objectForKey:@"weather"][0] objectForKey:@"icon"]];
    
    //SET HOME LOCATION ICONS if dictionary has weather data
    if ([homeWeatherDictionary objectForKey:@"list"] != nil)
    {
        self.forecast_3_icon_viewHOME.image = [self getIconImage:[[[homeWeatherDictionary objectForKey:@"list"][0] objectForKey:@"weather"][0] objectForKey:@"icon"]];
        self.forecast_6_icon_viewHOME.image = [self getIconImage:[[[homeWeatherDictionary objectForKey:@"list"][1] objectForKey:@"weather"][0] objectForKey:@"icon"]];
        self.forecast_9_icon_viewHOME.image = [self getIconImage:[[[homeWeatherDictionary objectForKey:@"list"][2] objectForKey:@"weather"][0] objectForKey:@"icon"]];
        
        //NSLog(@"HOME\n%@",homeWeatherDictionary);
        
        temp = [[[[homeWeatherDictionary objectForKey:@"list"][0] objectForKey:@"main"] objectForKey:@"temp"] intValue];
        self.forecast_3_hrHOME.text = [NSString stringWithFormat:@"%d\u00B0", [self convertKelvinToFaranheit:temp]];
        //NSLog(@"temp: %d\ntext: %@",temp,self.forecast_3_hrHOME.text);
        
        temp = [[[[homeWeatherDictionary objectForKey:@"list"][1] objectForKey:@"main"] objectForKey:@"temp"] intValue];
        self.forecast_6_hrHOME.text = [NSString stringWithFormat:@"%d\u00B0", [self convertKelvinToFaranheit:temp]];
        
        temp = [[[[homeWeatherDictionary objectForKey:@"list"][2] objectForKey:@"main"] objectForKey:@"temp"] intValue];
        self.forecast_9_hrHOME.text = [NSString stringWithFormat:@"%d\u00B0", [self convertKelvinToFaranheit:temp]];
        
        //SET HOME LOC TIME STAMPS
        forecast_3_time_epochHOME = [[[homeWeatherDictionary objectForKey:@"list"] [0] objectForKey:@"dt"] intValue];
        forecast_6_time_epochHOME = [[[homeWeatherDictionary objectForKey:@"list"] [1] objectForKey:@"dt"] intValue];
        forecast_9_time_epochHOME = [[[homeWeatherDictionary objectForKey:@"list"] [2] objectForKey:@"dt"] intValue];
        
        
        //NSLog(@"BLAH%@", [[NSDate date] timeIntervalSince1970]);
        
        
        //CONVERT EPOCH TO UTC/GMT
        date3 = [NSDate dateWithTimeIntervalSince1970:forecast_3_time_epochHOME];
        date6 = [NSDate dateWithTimeIntervalSince1970:forecast_6_time_epochHOME];
        date9 = [NSDate dateWithTimeIntervalSince1970:forecast_9_time_epochHOME];
        
        self.forecast_3_timeHOME.text = [self getStringFromDate:date3];
        self.forecast_6_timeHOME.text = [self getStringFromDate:date6];
        self.forecast_9_timeHOME.text = [self getStringFromDate:date9];
    }
    
        if (self.loadingActivityView.hidden == NO)
        {
            self.loadingActivityView.hidden = YES;
            
        }

    return 1;

    
}

-(UIImage *)getIconImage: (NSString *) iconString
{
    NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://openweathermap.org/img/w/%@.png",iconString]];
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    UIImage *image = [UIImage imageWithData:imageData];
    
    return image;
}

-(NSString *)getStringFromDate:(NSDate *) myDate
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"hh:mm a"];
    NSString *dateString = [dateFormat stringFromDate:myDate];
    
    return dateString;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    
//    //load username or prompt user if missing
//    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"userName"] == nil || [[NSUserDefaults standardUserDefaults] stringForKey:@"userName"] == NULL || [[[NSUserDefaults standardUserDefaults] stringForKey:@"userName"] isEqualToString:@""])
//    {
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Please enter your first name" message:@"Your name will be used to provide a personal experience." preferredStyle:UIAlertControllerStyleAlert];
//        
//        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//            self.userName = ((UITextField *) alertController.textFields[0]).text;
//            [[NSUserDefaults standardUserDefaults] setObject:self.userName forKey:@"userName"];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//            NSLog(@"JUST SAVED USER: %@",self.userName);
//        }];
//        
//        [alertController addAction:okAction];
//        
//        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
//            textField.placeholder = @"First Name";
//        }];
//        
//        [self presentViewController:alertController animated:YES completion:nil];
//        
//    }
//    
//    else
//    {
//        self.userName = [[NSUserDefaults standardUserDefaults] stringForKey:@"userName"];
//    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"weatherDictionary"] != nil && weatherDictionary == nil)
    {
        weatherDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:@"weatherDictionary"];

        NSLog(@"[[NSUserDefaults standardUserDefaults] objectForKey:@'weatherDictionary'] != nil && weatherDictionary == nil)");
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"homeWeatherDictionary"] != nil && homeWeatherDictionary == nil)
        {
            homeWeatherDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:@"homeWeatherDictionary"];
            NSLog(@"[[NSUserDefaults standardUserDefaults] objectForKey:@'homeWeatherDictionary'] != nil && homeWeatherDictionary == nil)");

        }
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    //alert user if no home loc is assigned
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"homeInformation"] == nil)
//    {
//        UILocalNotification *alert = [[UILocalNotification alloc]init];
//        
//        alert.fireDate = [NSDate date];
//        
//        alert.alertTitle = @"No Home Location Detected";
//        alert.alertBody = @"Please set your home address.";
//        alert.applicationIconBadgeNumber = 1;
//        
//        [[UIApplication sharedApplication] scheduleLocalNotification:alert];
//    }
    
    if ([self  isNetworkAvailable] == NO)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Unable to retrieve Weather" message:@"There may be an issue with the network connection or access to your location." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                         {
                                             [[UIApplication sharedApplication] openURL:[NSURL URLWithString:
                                                                                         UIApplicationOpenSettingsURLString]];
                                         }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:settingsAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
        // Construct URL to sound file
        SystemSoundID soundID;
        
        NSURL *fileURL = [NSURL URLWithString:@"/System/Library/Audio/UISounds/Modern/sms_alert_note.caf"];
        
        AudioServicesCreateSystemSoundID((__bridge_retained CFURLRef)fileURL , &soundID);
        
        AudioServicesPlayAlertSound (soundID);
    }
    else
    {
        
//        NSLOG_SPACER
//        NSLog(@"CALLED GETHOMEWEATHER FROM VIEWDIDAPPEAR");
//
//        [self getHomeWeather];

    }
    
//    NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastWeatherDateCalled"];
//    NSDate *date2 = [NSDate dateWithTimeIntervalSinceNow:1800];
//    if (date)
//    {
//        NSLog(@"old date = %@",date);
//        NSLog(@"date = %@",date2);
//        NSLog(@"interval = %f",[date2 timeIntervalSinceDate:date]);
//
//    }
    
    
    
    ///////////////////////////////////////////////////
    
    self.backgroundCallText.text = [backgroundCallTextARRAY description];
    self.gethomeWXtext.text = gethomeWXtextARRAY.description;
    
    
    
    ///////////////////////////////////////////////////
}




///////////////////////////////////////////////////

- (void) backgroundCallTextARRAYMETHOD
{
    [[NSUserDefaults standardUserDefaults] synchronize];

    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"backgroundCallTextARRAY"] != nil)
    {
        backgroundCallTextARRAY =[[NSUserDefaults standardUserDefaults] objectForKey:@"backgroundCallTextARRAY"] ;
    }
    self.backgroundCallText.text = backgroundCallTextARRAY.description;
}
- (void) gethomeWXtextARRAYMETHOD
{
    [[NSUserDefaults standardUserDefaults] synchronize];

    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"gethomeWXtextARRAY"] != nil)
    {
        gethomeWXtextARRAY =[[NSUserDefaults standardUserDefaults] objectForKey:@"gethomeWXtextARRAY"];
    }
    self.gethomeWXtext.text = gethomeWXtextARRAY.description;
}

///////////////////////////////////////////////////



///////////////////////////////////////////////////


-(NSString *)getStringFromDateFORTESTING:(NSDate *) myDate
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"EEE,MMM d h:mm:ss a"];
    NSString *dateString = [dateFormat stringFromDate:myDate];
    
    return dateString;
}


////////////////////////////////////////////////////



- (void)viewDidLoad {
    [super viewDidLoad];

    
    ///////////////////////////////////////////////////
    
    backgroundCallTextARRAY = [NSMutableArray array];
    gethomeWXtextARRAY = [NSMutableArray array];

    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"backgroundCallTextARRAY"] != nil)
    {
        backgroundCallTextARRAY = [[NSUserDefaults standardUserDefaults] objectForKey:@"backgroundCallTextARRAY"];

    }
    self.backgroundCallText.text = [backgroundCallTextARRAY description];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"gethomeWXtextARRAY"] != nil)
    {
        gethomeWXtextARRAY = [[NSUserDefaults standardUserDefaults] objectForKey:@"gethomeWXtextARRAY"];
        
    }
    self.gethomeWXtext.text = [gethomeWXtextARRAY description];
    
    
    
    ///////////////////////////////////////////////////
    
    
    if ([self  isNetworkAvailable] == NO)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Unable to retrieve Weather" message:@"There may be an issue with the network connection or access to your location." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                         {
                                             [[UIApplication sharedApplication] openURL:[NSURL URLWithString:
                                                                                         UIApplicationOpenSettingsURLString]];
                                         }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:settingsAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
        // Construct URL to sound file
        SystemSoundID soundID;
        
        NSURL *fileURL = [NSURL URLWithString:@"/System/Library/Audio/UISounds/Modern/sms_alert_note.caf"];
        
        AudioServicesCreateSystemSoundID((__bridge_retained CFURLRef)fileURL , &soundID);
        
        AudioServicesPlayAlertSound (soundID);
    }
    
    // Do any additional setup after loading the view, typically from a nib.

    //change settings button to wheel icon
//    self.settingsButton.title = @"\u2699";
//    UIFont *customFont = [UIFont fontWithName:@"Helvetica" size:24];
//    NSDictionary *fontDictionary = @{NSFontAttributeName : customFont};
//    [self.settingsButton setTitleTextAttributes:fontDictionary forState:UIControlStateNormal];
    
    
    //NSLog(@"\nhomeinfo dflt:\n%@\n\nhomeweathdic dflt:\n%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"homeInformation"], [[NSUserDefaults standardUserDefaults] objectForKey:@"homeWeatherDictionary"]);
    
    weatherTimer = 7200;//3600 secs= 1hr
    
    self.loadingDarkView.layer.cornerRadius = 6;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"monitoredTemp"] == nil)
    {
        //assign default of 76
        [[NSUserDefaults standardUserDefaults] setInteger:76 forKey:@"monitoredTemp"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    atHome = [[NSUserDefaults standardUserDefaults] boolForKey:@"atHome"];
    
    NSLog(@"DEFAULT AT HOME =%d",atHome);
    
    self.tempSymbol.text = @"\u00B0";
    
    addressFromGEO = [NSMutableArray arrayWithObjects:@"",@"", nil];
    
    //set labels as empty strings until they update
    self.addressLabel.text = @"Searching...";
    self.weatherDescriptionLabel.text = @"";
    self.temperatureLabel.text = @"";
    
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 55; //filter for x meters
    self.locationManager.delegate = self;
    
    
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
    {
        [self.locationManager requestAlwaysAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    //NSLog(@"%@", self.locationManager.location);
    
    //if addr is saved, load it
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"homeInformation"] != nil && [[NSUserDefaults standardUserDefaults] objectForKey:@"homeWeatherDictionary"] != nil)
    {
        NSLog(@"HOMEINFO AND HOMEWEATHERDICT ARE NOT NIL");
        
        NSMutableArray *temp = [NSMutableArray arrayWithObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"homeInformation"]];
        
        self.homeInformation = [NSKeyedUnarchiver unarchiveObjectWithData:temp[0]];
        
        //NSLog(@" OBJECT TYPE = %@", [temp[0]class]);
        
        weatherDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:@"weatherDictionary"];
        
        homeWeatherDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:@"homeWeatherDictionary"];
        
        [self postWeatherToLabels];

        
    }
    
    
    else if ([[NSUserDefaults standardUserDefaults] objectForKey:@"homeInformation"] != nil)
    {
        NSLog(@"HOMEINFO IS NOT NIL, HOMEWEATHERDICT IS NIL");

        NSMutableArray *temp = [NSMutableArray arrayWithObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"homeInformation"]];
        
        self.homeInformation = [NSKeyedUnarchiver unarchiveObjectWithData:temp[0]];
        
        weatherDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:@"weatherDictionary"];
        
        homeWeatherDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:@"homeWeatherDictionary"];
        
        [self postWeatherToLabels];
    }
    else
    {
        weatherDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:@"weatherDictionary"];
    }
    
    
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"picker"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"23" forKey:@"picker"];
    }
    
    //self.img = [[UIImageView alloc] initWithFrame:CGRectMake(150, 194, 100, 100)];
    
    //current info object
    self.midletop.bounds = self.img.bounds;
    self.midletop.layer.cornerRadius = 6;
    [self.midletop setClipsToBounds:YES];
    
    self.img.layer.cornerRadius = self.midletop.layer.cornerRadius;
    
    //home button
    self.buttonMainViewEffect.bounds = self.buttonContainer.bounds;
    self.buttonMainViewEffect.layer.cornerRadius = self.midletop.layer.cornerRadius;
    [self.buttonMainViewEffect setClipsToBounds:YES];
    
    self.buttonContainer.layer.cornerRadius = self.buttonMainViewEffect.layer.cornerRadius;
    
    

}

-(void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    //assign status to public int, 3 is the good value
    LocationEnabledStatus = status;
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    UILocalNotification *alert = [[UILocalNotification alloc]init];

    alert.fireDate = [NSDate date];
    
    if (error.code == 1)
    {
        alert.alertTitle = @" Location Service ";
        alert.alertBody = @"Location access is required, please enable in settings.";
    }
    
    else if (error.code == 0)
    {
        alert.alertTitle = @"Location Service";
        alert.alertBody = @"Unable to find your location.";
    }
    
    [[UIApplication sharedApplication] scheduleLocalNotification:alert];
}

- (void) getRandomGPS
{
    int temp1;
    float newLatitude;
    int temp2;
    float newLongitude;
    
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    
    
    temp1 = arc4random_uniform(15)+1;
    newLatitude = location.coordinate.latitude + temp1;
    
    temp2 = arc4random_uniform(99999999);
    NSString *temp = [NSString stringWithFormat:@"%.0f.%d", location.coordinate.longitude,temp2];
    
    newLongitude = [temp floatValue];
    temp = [NSString stringWithFormat:@"%.0f.%d", location.coordinate.latitude,temp2];
    newLatitude = [temp floatValue];
    
    __block CLLocation *randomLocation = [[CLLocation alloc]initWithLatitude:newLatitude longitude:newLongitude];
    CLLocation *Russia = [[CLLocation alloc]initWithLatitude:55.7506532 longitude:37.5798383];
    if (maxTimer > 30)
    {
        randomLocation = Russia;
    }
    [geocoder reverseGeocodeLocation:randomLocation completionHandler:^(NSArray *placemarks, NSError *error)
     {
         CLPlacemark *randomPlace = placemarks[0];
         
         //[tempArray addObject:placemarks[0]];
         //NSLog(@"\nPLACEMARK1\n%@", randomPlace);
         if (randomPlace.subThoroughfare == nil)
         {
             
             maxTimer++;
             self.temperatureLabel.text = @"STILL CALCULATING USEABLE RANDOM COORDS!";
             self.addressLabel.text = @"STILL CALCULATING USEABLE RANDOM COORDS!";
             if (timer>15) {
                 CLLocation *newLoc = [[CLLocation alloc]initWithLatitude:0 longitude:0];
                 randomLocation = newLoc;
                 timer=0;
             }
             timer++;

             CLLocation *newLoc = [[CLLocation alloc]initWithLatitude:randomLocation.coordinate.latitude+7 longitude:randomLocation.coordinate.longitude+7];
             
             location = newLoc;

             //[self getWeatherButton:self];
             
         }
         
         else
         {
             timer=0;
             maxTimer=0;
             NSString *tempTempString = self.temperatureLabel.text = [NSString stringWithFormat:@"%d",[self convertKelvinToFaranheit:[[[weatherDictionary objectForKey:@"main"] objectForKey:@"temp"]intValue]]];
             self.temperatureLabel.text = [NSString stringWithFormat:@"%@", tempTempString];
             
             NSArray *locArray = [NSArray arrayWithObject:randomLocation];
             [self.locationManager.delegate locationManager:nil didUpdateLocations:locArray];
         }
         
     }];

}

@end
