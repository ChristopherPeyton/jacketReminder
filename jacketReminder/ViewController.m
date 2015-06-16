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
    NSDictionary *weatherDictionary;
    CLLocation *location; 
    NSArray *addressFromGEO;
    int timer;
    int maxTimer;
    
}
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
    NSLog(@"COPIED ARRAY\nwith %lu objects",(unsigned long)[self.homeInformation count]);
    
}

-(int) convertKelvinToFaranheit: (int) temperatureInKelvin
{
    int temperatureInFaranheit = (temperatureInKelvin - 273.15)*1.8+32;
    return temperatureInFaranheit;
}

- (NSDictionary *) getWeather
{
//    //FINAL STRING WITH API KEY
//    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%.8f&lon=%.8f&APPID=a96ff77043a749a97158ecbaaa30f249", location.coordinate.latitude, location.coordinate.longitude];
    
    //USING DURING TESTING
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%.8f&lon=%.8f", location.coordinate.latitude, location.coordinate.longitude];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *datatask = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        weatherDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSString *weatherJSON = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//        NSLOG_SPACER
//        NSLog(@"%@",weatherDictionary);
//        NSLOG_SPACER
        //NSLog(@"json string\n%@", weatherJSON);
//        NSLOG_SPACER
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //assign temperature to string
            NSString *tempTempString = [NSString stringWithFormat:@"%d",[self convertKelvinToFaranheit:[[[weatherDictionary objectForKey:@"main"] objectForKey:@"temp"]intValue]]];
            self.temperatureLabel.text = [NSString stringWithFormat:@"%@\u00B0", tempTempString];
            
            NSArray *aaa = [NSArray arrayWithArray:[weatherDictionary objectForKey:@"weather"]];
            self.weatherDescriptionLabel.text = [aaa[0] objectForKey:@"description"];

        });
    }];
    [datatask resume];
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
    [[NSUserDefaults standardUserDefaults] synchronize];

}

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    
    NSLOG_SPACER
    NSLog(@"\ndidUpdateLocations");
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
                                                              placemark.country]];}
        }
        
        
        addressFromGEO = [[NSArray alloc]initWithArray:tempArray];

        self.addressLabel.text = addressFromGEO[0];
    }];
    
    
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
    self.locationManager.distanceFilter = 1; //filter for x meters
    self.locationManager.delegate = self;
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
    {
        [self.locationManager requestAlwaysAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    //NSLog(@"%@", self.locationManager.location);
    
    //if addr is saved, load it
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"homeInformation"])
    {
        NSMutableArray *temp = [NSMutableArray arrayWithObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"homeInformation"]];
        
        self.homeInformation = [NSKeyedUnarchiver unarchiveObjectWithData:temp[0]];
        
        NSLog(@"CREATED ARRAY\nwith %lu objects",(unsigned long)[temp count]);
        NSLog(@" OBJECT TYPE = %@", [temp[0]class]);
    }
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"picker"])
    {
        NSLog(@"nope");
        [[NSUserDefaults standardUserDefaults] setObject:@"23" forKey:@"picker"];
    }

}

-(void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    //assign status to public int, 3 is the good value
    LocationEnabledStatus = status;
    
    NSLog(@"STATUS IS\n%d", LocationEnabledStatus);
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    UILocalNotification *alert = [[UILocalNotification alloc]init];
    NSLog(@"\n\n%ld", (long)error.code);
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
             NSLOG_SPACER
             NSLog(@"\nHAD TO RESET COORDINATES");
             CLLocation *newLoc = [[CLLocation alloc]initWithLatitude:randomLocation.coordinate.latitude+7 longitude:randomLocation.coordinate.longitude+7];
             
             location = newLoc;
             NSLog(@"\nTIMER %d\nMAX TIMER %d", timer, maxTimer);
             NSLog(@"\nLAT%.8f\nLONG%.8f", location.coordinate.latitude,location.coordinate.longitude);
             //[self getWeatherButton:self];
             
         }
         
         else
         {
             timer=0;
             maxTimer=0;
             NSString *tempTempString = self.temperatureLabel.text = [NSString stringWithFormat:@"%d",[self convertKelvinToFaranheit:[[[weatherDictionary objectForKey:@"main"] objectForKey:@"temp"]intValue]]];
             self.temperatureLabel.text = [NSString stringWithFormat:@"%@\u00B0", tempTempString];
             NSLog(@"\nADDED %d TO LATITUDATE\n\n%@", temp1,location);
             
             NSArray *locArray = [NSArray arrayWithObject:randomLocation];
             [self.locationManager.delegate locationManager:nil didUpdateLocations:locArray];
         }
         
     }];

}

@end
