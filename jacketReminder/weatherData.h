//
//  weatherData.h
//  jacketReminder
//
//  Created by Christopher Peyton on 5/18/15.
//  Copyright (c) 2015 Christopher Peyton. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

@interface weatherData : NSObject

@property (nonatomic) float temperature;

@property (nonatomic,weak) NSString *address;

@property (nonatomic,strong)NSURLSession *session;

-(NSDictionary *) getWeather: (CLLocation *) location;

@end
