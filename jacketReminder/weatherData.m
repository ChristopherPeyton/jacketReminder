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

- (void) getWeather:(CLLocation *)location
{
    NSLog(@"NOW INSIDE WEATHER DATA OBJECT");
    NSString *urlString = @"http://api.openweathermap.org/data/2.5/weather?q=London,uk";
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *datatask = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"TEST");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"TEST 2");
        });
    }];
    [datatask resume];
    NSLog(@"weatherDICT\n%@", weatherDictionary);
}

- (NSURLSession *) session
{
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:nil];
    }
    return _session;
}

@end
