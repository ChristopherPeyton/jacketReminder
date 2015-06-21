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
    NSArray *addressFromGEO;//[0]=string address,[1]=city string
    int timer;
    int maxTimer;
    int forecast_3_time_epoch;
    int forecast_6_time_epoch;
    int forecast_9_time_epoch;
    int forecast_3_time_epochHOME;
    int forecast_6_time_epochHOME;
    int forecast_9_time_epochHOME;
    IBInspectable int xx;
    
}
@property (weak, nonatomic) IBOutlet UILabel *currentLocationWeatherTime;
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

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    TableViewController *vc = segue.destinationViewController;
    
    vc.homeInformationFromRoot = [self.homeInformation mutableCopy];
    setHomeLocationTriggered = NO;
    
}

-(int) convertKelvinToFaranheit: (int) temperatureInKelvin
{
    int temperatureInFaranheit = (temperatureInKelvin - 273.15)*1.8+32;
    return temperatureInFaranheit;
}

- (void) getWeather
{
    //RUNNING WEATHER UPDATE FOR HOME IF HOME IS DIFF FROM CURRENT LOC
    if ([self.homeInformation count]>=3 && [self.homeInformation[2] isEqualToString:addressFromGEO[1]] == NO)
    {
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
            
            [[NSUserDefaults standardUserDefaults] setObject:weatherDictionary forKey:@"homeWeatherDictionary"];
            
            //[weatherDictionary setObject: forKey:<#(id<NSCopying>)#>]
            
            NSString *weatherJSON = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            //        NSLOG_SPACER
            //        NSLog(@"%@",weatherDictionary);
            //        NSLOG_SPACER
            //NSLog(@"json string\n%@", weatherJSON);
            //        NSLOG_SPACER
            
        }];
        [datatask resume];
    }
    

//    //FINAL STRING WITH API KEY
//    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%.8f&lon=%.8f&APPID=a96ff77043a749a97158ecbaaa30f249", location.coordinate.latitude, location.coordinate.longitude];
    
    //USING DURING TESTING api.openweathermap.org/data/2.5/forecast?lat=32.986775&lon=-97.37743
    //NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%.8f&lon=%.8f", location.coordinate.latitude, location.coordinate.longitude];
    
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
       // NSLog(@"json string\n%@", weatherJSON);
//        NSLOG_SPACER
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[NSUserDefaults standardUserDefaults] setObject:weatherDictionary forKey:@"weatherDictionary"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self postWeatherToLabels];

        });
    }];
    [datatask resume];
}

- (NSURLSession *) session
{
    if (!_session)
    {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:nil];
    }
    return _session;
}

- (IBAction)setHomeLocation:(id)sender
{
    setHomeLocationTriggered = YES;
    
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
        
    }
    
    else if (!location || self.addressLabel<=0)
    {
        [[[UIAlertView alloc]initWithTitle:@"ADDR ISSUE" message:@"UNABLE TO DETECT LOC" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil]show];
        [self.locationManager startUpdatingLocation];
    }
    
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSUserDefaults standardUserDefaults] synchronize];

}

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{

    //[self.locationManager stopUpdatingLocation];

    location = locations[0];
    
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"homeInformation"])
    {
        [self setHomeLocation:self];
        
    }

    [self getWeather];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
    {
        
        NSMutableArray *tempArray = [[NSMutableArray alloc]init];
        for (CLPlacemark *placemark in placemarks)
        {
            [tempArray addObject:[NSString stringWithFormat:@"%@ %@\n%@ %@ %@\n%@",
                                  placemark.subThoroughfare,
                                  placemark.thoroughfare,
                                  placemark.locality,
                                  placemark.administrativeArea,
                                  placemark.postalCode,
                                  placemark.country]];
            
            //in case user is not in a static spot, possibly driving
            if (placemark.subThoroughfare == nil)
            {
                [tempArray replaceObjectAtIndex:0 withObject:[NSString stringWithFormat:@"%@\n%@ %@ %@\n%@",
                                                              placemark.thoroughfare,
                                                              placemark.locality,
                                                              placemark.administrativeArea,
                                                              placemark.postalCode,
                                                              placemark.country]];
            }
            
            //in case user is not in a static spot, possibly driving AND only has region info
            if (placemark.thoroughfare == nil)
            {
                [tempArray replaceObjectAtIndex:0 withObject:[NSString stringWithFormat:@"%@ %@ %@\n%@",
                                                              placemark.locality,
                                                              placemark.administrativeArea,
                                                              placemark.postalCode,
                                                              placemark.country]];
            }
            //added city to compare from home loc to current loc
            [tempArray addObject:placemark.locality];
        }
        
        addressFromGEO = [[NSArray alloc]initWithArray:tempArray];

        self.addressLabel.text = addressFromGEO[0];
        
    }];
    
    
}

- (void) postWeatherToLabels
{
    //self.forecast_3_hr.text = weatherDictionary;
    //NSLog(@"\n%@",weatherDictionary);
    
    //assign temperature to string
    NSString *tempTempString = [NSString stringWithFormat:@"%d",[self convertKelvinToFaranheit:[[[[weatherDictionary objectForKey:@"list"][0] objectForKey:@"main"] objectForKey:@"temp"]intValue]]];
    
    self.temperatureLabel.text = [NSString stringWithFormat:@"%@\u00B0", tempTempString];
    
    NSArray *aaa = [NSArray arrayWithArray:[[weatherDictionary objectForKey:@"list"][0] objectForKey:@"weather"]];
    
    self.currentLocationWeatherTime.text = [self getStringFromDate:[NSDate date]];
    
    self.weatherDescriptionLabel.text = [aaa[0] objectForKey:@"description"];

 
    int temp = [[[[weatherDictionary objectForKey:@"list"][0] objectForKey:@"main"] objectForKey:@"temp"] intValue];
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
    
    //SET HOME LOCATION ICONS
    self.forecast_3_icon_viewHOME.image = [self getIconImage:[[[homeWeatherDictionary objectForKey:@"list"][0] objectForKey:@"weather"][0] objectForKey:@"icon"]];
    self.forecast_6_icon_viewHOME.image = [self getIconImage:[[[homeWeatherDictionary objectForKey:@"list"][1] objectForKey:@"weather"][0] objectForKey:@"icon"]];
    self.forecast_9_icon_viewHOME.image = [self getIconImage:[[[homeWeatherDictionary objectForKey:@"list"][2] objectForKey:@"weather"][0] objectForKey:@"icon"]];
    
    temp = [[[[homeWeatherDictionary objectForKey:@"list"][0] objectForKey:@"main"] objectForKey:@"temp"] intValue];
    self.forecast_3_hrHOME.text = [NSString stringWithFormat:@"%d\u00B0", [self convertKelvinToFaranheit:temp]];
    
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
    [dateFormat setDateFormat:@"EEE, h a"];
    NSString *dateString = [dateFormat stringFromDate:myDate];
    
    return dateString;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    //change settings button to wheel icon
//    self.settingsButton.title = @"\u2699";
//    UIFont *customFont = [UIFont fontWithName:@"Helvetica" size:24];
//    NSDictionary *fontDictionary = @{NSFontAttributeName : customFont};
//    [self.settingsButton setTitleTextAttributes:fontDictionary forState:UIControlStateNormal];
    
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
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"homeInformation"] && [[NSUserDefaults standardUserDefaults] objectForKey:@"homeWeatherDictionary"])
    {
        NSMutableArray *temp = [NSMutableArray arrayWithObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"homeInformation"]];
        
        self.homeInformation = [NSKeyedUnarchiver unarchiveObjectWithData:temp[0]];
        
        //NSLog(@" OBJECT TYPE = %@", [temp[0]class]);
        
        weatherDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:@"weatherDictionary"];
        
        homeWeatherDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:@"homeWeatherDictionary"];
        
        [self postWeatherToLabels];
        
        NSLog(@"CURRENT LOC INFO\n%@",weatherDictionary);
        NSLOG_SPACER
        NSLog(@"HOME LOC INFO\n%@",homeWeatherDictionary);

        
    }
    
    
    else if ([[NSUserDefaults standardUserDefaults] objectForKey:@"homeInformation"])
    {
        NSMutableArray *temp = [NSMutableArray arrayWithObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"homeInformation"]];
        
        self.homeInformation = [NSKeyedUnarchiver unarchiveObjectWithData:temp[0]];

        weatherDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:@"weatherDictionary"];
        
        
        [self postWeatherToLabels];
    }
    
    
    
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"picker"])
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"23" forKey:@"picker"];
    }
    
    //self.img = [[UIImageView alloc] initWithFrame:CGRectMake(150, 194, 100, 100)];
    
    self.midletop.bounds = self.img.bounds;
    self.midletop.layer.cornerRadius = self.img.frame.size.width/2;
    [self.midletop setClipsToBounds:YES];
    
    self.img.layer.cornerRadius = self.img.frame.size.width/2;   
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
             self.temperatureLabel.text = [NSString stringWithFormat:@"%@\u00B0", tempTempString];
             
             NSArray *locArray = [NSArray arrayWithObject:randomLocation];
             [self.locationManager.delegate locationManager:nil didUpdateLocations:locArray];
         }
         
     }];

}

@end
