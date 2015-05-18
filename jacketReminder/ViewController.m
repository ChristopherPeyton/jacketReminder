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
    weatherData *weather;
    NSDictionary *weatherDICT;
    CLLocation *location;
}
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;

@end

@implementation ViewController
- (IBAction)getWeatherButton:(id)sender {
    
    weatherDICT = [weather getWeather:location];
    int temperatureInKelvin = [[[weatherDICT objectForKey:@"main"] objectForKey:@"temp"]intValue];
    int temperatureInFaranheit = (temperatureInKelvin - 273.15)*1.8+32;
    self.temperatureLabel.text = [NSString stringWithFormat:@"%d",temperatureInFaranheit];

}

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self.locationManager stopUpdatingLocation];
    location = locations[0];
    [weather getWeather:location];
    //NSLog(@"%@", locations);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    weather = [[weatherData alloc]init];
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
    {
        [self.locationManager requestAlwaysAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    //NSLog(@"%@", self.locationManager.location);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
