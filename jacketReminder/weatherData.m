//
//  weatherData.m
//  jacketReminder
//
//  Created by Christopher Peyton on 5/18/15.
//  Copyright (c) 2015 Christopher Peyton. All rights reserved.
//

#import "weatherData.h"

@implementation weatherData

{
    NSDictionary *weatherDictionary;
}

- (NSDictionary *) getWeather:(CLLocation *)location
{
    NSLog(@"NOW INSIDE WEATHER DATA OBJECT");
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%.8f&lon=%.8f", location.coordinate.latitude, location.coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *datatask = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        weatherDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSString *weatherJSON = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        //NSLog(@"%@",weatherDictionary);
        NSLog(@"json string\n%@", weatherJSON);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"TEST async");
        });
    }];
    [datatask resume];
    return weatherDictionary;
}

- (NSURLSession *) session
{
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:nil];
    }
    return _session;
}

@end
