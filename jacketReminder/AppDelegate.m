//
//  AppDelegate.m
//  jacketReminder
//
//  Created by Christopher Peyton on 5/18/15.
//  Copyright (c) 2015 Christopher Peyton. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

{
    int counter;
}

@end

@implementation AppDelegate

- (void) playAlertSound
{
    // Construct URL to sound file
    SystemSoundID soundID;
    
    NSURL *fileURL = [NSURL URLWithString:@"/System/Library/Audio/UISounds/Modern/sms_alert_note.caf"];
    
    AudioServicesCreateSystemSoundID((__bridge_retained CFURLRef)fileURL , &soundID);
    
    AudioServicesPlayAlertSound (soundID);
}

- (void) application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    //Error 1 - Location service denied
    if ([notification.alertTitle isEqualToString:@" Location Service "])
    {
        //LOCALIZED VERSION
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString( @"Location Service", @"" ) message:NSLocalizedString( @"Enter your message here.", @"" ) preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Cancel", @"" ) style:UIAlertActionStyleCancel handler:nil];
//        UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Settings", @"" ) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:
//                                                        UIApplicationOpenSettingsURLString]];
//        }];

        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Location access required" message:@"Phone cannot access location.\nOr\nApp was denied access to location." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:
                                                        UIApplicationOpenSettingsURLString]];
        }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:settingsAction];
        
        [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
        
        [self playAlertSound];
    }
    
    else if ([notification.alertTitle isEqualToString:@"Location Service"])
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Location access" message:notification.alertBody preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *OkAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
        
        UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                         {
                                             [[UIApplication sharedApplication] openURL:[NSURL URLWithString:
                                                                                         UIApplicationOpenSettingsURLString]];
                                         }];
        
        [alertController addAction:OkAction];
        
        //[alertController addAction:settingsAction];
        
        [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
        
        [self playAlertSound];
    }
    
    else if ([notification.alertTitle isEqualToString:@"No Home Location Detected"])
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"No Home Location Detected" message:notification.alertBody preferredStyle:UIAlertControllerStyleAlert];

        application.applicationIconBadgeNumber = 1;
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            ;
        }];
        
        [alertController addAction:okAction];
        
        [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
        
        [self playAlertSound];
        
    }
    
    else if ([notification.alertTitle isEqualToString:[NSString stringWithFormat:@"Yo %@,", [[NSUserDefaults standardUserDefaults] stringForKey:@"userName"]]])
    {
        UIAlertController *alertControllerTemp = [UIAlertController alertControllerWithTitle:notification.alertTitle message:notification.alertBody preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            ;
        }];
        
        [alertControllerTemp addAction:okAction];

        if ([self.window.rootViewController presentedViewController] != nil)
        {
            //use alertview
            [[[UIAlertView alloc]initWithTitle:notification.alertTitle message:notification.alertBody delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil]show ];
            [self playAlertSound];

        }
        
        else
        {
          [self.window.rootViewController presentViewController:alertControllerTemp animated:YES completion:nil];
            
            [self playAlertSound];

        }
        

        
    }
    
}

- (void)redirectNSLogToDocumentFolder{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *fileName =[NSString stringWithFormat:@"%@.log",[NSDate date]];
    
    NSString *logFilePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
#if TARGET_IPHONE_SIMULATOR
    NSString * const DeviceMode = @"Simulator";
    
#else
    
    NSString * const DeviceMode = @"Device";
    
    //redirect device to file
    [self redirectNSLogToDocumentFolder];
    
#endif
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)])
    {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    //fetch every 60 mins
    //[[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:3600];
        
    return YES;
}

-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    counter++;
    
    NSLog(@"########### Received Background Fetch #%d ###########",counter);
    NSLog(@"BEFORE FETCH");
    NSLOG_SPACER
 //   NSLog(@"REGULAR WX\n%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"weatherDictionary"]);
    
    NSLOG_SPACER
 //   NSLog(@"Home WX\n%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"homeWeatherDictionary"]);
    NSLOG_SPACER
    NSLOG_SPACER
    
    NSDictionary *oldWeatherToCompare = [[NSUserDefaults standardUserDefaults] objectForKey:@"homeWeatherDictionary"];
    //Download  the Content .
    if ([self.window.rootViewController.childViewControllers[0] isKindOfClass:[ViewController class]])
    {
        [self.window.rootViewController.childViewControllers[0] getHomeWeatherOnlyForBackground];
    }
    else
    {
        NSLog(@"HAD TO CREATE NEW VIEW TO CALL WEATHER FROM BACKGROUND FETCH");
        ViewController *view = [[ViewController alloc]init];
        [view getHomeWeatherOnlyForBackground];
    }
    
    // Set up Local Notifications
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    NSDate *now = [NSDate date];
    localNotification.fireDate = now;
    localNotification.alertBody = [NSString stringWithFormat:@"fetch #%d in background",counter];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
    //Cleanup
    NSLog(@"Fetch completed");
    NSLog(@"AFTER FETCH");
    NSLOG_SPACER
 //   NSLog(@"REGULAR WX\n%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"weatherDictionary"]);
    
    NSLOG_SPACER
//    NSLog(@"Home WX\n%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"homeWeatherDictionary"]);
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"homeWeatherDictionary"] != nil)
    {
        if ([oldWeatherToCompare isEqualToDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"homeWeatherDictionary"]] == NO)
        {
            NSLOG_SPACER
            NSLOG_SPACER
            NSLog(@"NEW DATA FETCHED FROM BACKGROUND!");
            NSLog(@"\nNEW\n%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"homeWeatherDictionary"]);
            NSLOG_SPACER
            NSLog(@"\nOLD\n%@", oldWeatherToCompare);
            completionHandler(UIBackgroundFetchResultNewData);
        }
        else//dictionary is not nil and matches, so no new data downloaded
        {
            NSLog(@"NO NEW DATA FETCHED FROM BACKGROUND!");
            completionHandler(UIBackgroundFetchResultNoData);
        }
    }
    
    //something went wrong and the homewx_dictionary is nil
    else
    {
        NSLog(@"DATA FETCHED FROM BACKGROUND FAILED!");
        completionHandler(UIBackgroundFetchResultFailed);
    }
    
}




- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSLog(@"\n\n\napplicationWillResignActive\n\n\n");
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"\n\n\nDID ENTER BACKGROUND\n\n\n");
    [[NSUserDefaults standardUserDefaults] synchronize];
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     NSLog(@"\n\n\napplicationWillEnterForeground\n\n\n");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     NSLog(@"\n\n\napplicationDidBecomeActive\n\n\n");
    application.applicationIconBadgeNumber = 0;
    
    //alert user if no home loc is assigned
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"homeInformation"] == nil)
    {
        UILocalNotification *alert = [[UILocalNotification alloc]init];
        
        alert.fireDate = [NSDate date];
        
        alert.alertTitle = @"No Home Location Detected";
        alert.alertBody = @"Please set your home address.";
        alert.applicationIconBadgeNumber = 1;
        
        [[UIApplication sharedApplication] scheduleLocalNotification:alert];
    }
    
    //check that view is main viewcontroller class
    if ([self.window.rootViewController.childViewControllers[0] isKindOfClass:[ViewController class]])
    {
        NSLog(@"calling weather from applicationDidBecomeActive");
        [self.window.rootViewController.childViewControllers[0] getHomeWeather];

    }

}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
     NSLog(@"\n\n\napplicationWillTerminate\n\n\n");
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    NSLog(@"\n\n\napplicationDidReceiveMemoryWarning\n\n\n");

    
}


@end
