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

- (void) fetchWeatherFromPush
{
    counter++;
    
    
    UIBackgroundFetchResult *result;
    //Download  the Content .
    if ([self.window.rootViewController.childViewControllers[0] isKindOfClass:[ViewController class]])
    {
        result = [self.window.rootViewController.childViewControllers[0] getHomeWeatherOnlyForBackground];
    }
    else
    {
        NSLog(@"HAD TO CREATE NEW VIEW TO CALL WEATHER FROM BACKGROUND FETCH");
        ViewController *view = [[ViewController alloc]init];
        result = [view getHomeWeatherOnlyForBackground];
    }
    
    //Cleanup
    
    //something went wrong and the homewx_dictionary is nil

    NSLog(@"CALLED WEATHER FROM ONESIGNALPUSH");
    
    NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastBackgroundWeatherDateCalled"];
    float dateInterval =[[NSDate date] timeIntervalSinceDate:date];
    NSLog(@"SECONDS SINCE LAST CALL: %f",dateInterval);
    
    NSLog(@"BACKGROUND RESULT = %d ------ //0 new data, 1 no data, 2 failed",result);//0 new data, 1 no data, 2 failed
    if ((int)result == 0)        //new data
    {
        NSLog(@"BACKGROUND FETCH HAS NEW DATA");
        
        
        
    }
    else if ((int) result == 1)
    {
        NSLog(@"BACKGROUND FETCH HAS NO NEW DATA");
        
        
    }
    else
    {
        NSLog(@"BACKGROUND FETCH HAS FAILED");
        
    }

}

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
    
    else if ([notification.alertTitle isEqualToString:@"Please enter your first name"])
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Please enter your first name" message:notification.alertBody preferredStyle:UIAlertControllerStyleAlert];
        
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

//        if ([self.window.rootViewController presentedViewController] != nil)
//        {
//            //use alertview
//            [[[UIAlertView alloc]initWithTitle:notification.alertTitle message:notification.alertBody delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil]show ];
//            
//            [self playAlertSound];
//
//        }
        
        
        //was a else statement
          [self.window.rootViewController presentViewController:alertControllerTemp animated:YES completion:nil];
            
            [self playAlertSound];


        

        
    }
    
}

- (void)redirectNSLogToDocumentFolder{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *fileName =[NSString stringWithFormat:@"%@.log",[NSDate date]];
    
    NSString *logFilePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    counter++;
    
    
    UIBackgroundFetchResult *result;
    //Download  the Content .
    if ([self.window.rootViewController.childViewControllers[0] isKindOfClass:[ViewController class]])
    {
        result = [self.window.rootViewController.childViewControllers[0] getHomeWeatherOnlyForBackground];
    }
    else
    {
        NSLog(@"HAD TO CREATE NEW VIEW TO CALL WEATHER FROM REMOTE PUSH BACKGROUND FETCH");
        ViewController *view = [[ViewController alloc]init];
        result = [view getHomeWeatherOnlyForBackground];
    }
    
    //Cleanup
    
    //something went wrong and the homewx_dictionary is nil

    NSLog(@"CALLED WEATHER FROM REMOTE PUSH");
    
    NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastBackgroundWeatherDateCalled"];
    float dateInterval =[[NSDate date] timeIntervalSinceDate:date];
    NSLog(@"SECONDS SINCE LAST CALL: %f",dateInterval);
    
    NSLog(@"REMOTE PUSH BACKGROUND RESULT = %d ------ //0 new data, 1 no data, 2 failed",result);//0 new data, 1 no data, 2 failed
    if ((int)result == 0)        //new data
    {
        NSLog(@"REMOTE PUSH BACKGROUND FETCH HAS NEW DATA");
        
        completionHandler(UIBackgroundFetchResultNewData);
    }
    else if ((int) result == 1)
    {
        NSLog(@"REMOTE PUSH BACKGROUND FETCH HAS NO NEW DATA");
        
        completionHandler(UIBackgroundFetchResultNoData);
    }
    else
    {
        NSLog(@"REMOTE PUSH BACKGROUND FETCH HAS FAILED");
        
        completionHandler(UIBackgroundFetchResultFailed);
    }
    
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
    
    self.oneSignal = [[OneSignal alloc] initWithLaunchOptions:launchOptions
                                                        appId:@"0781fdaa-3d23-11e5-a9f4-eb679716ed36"
                                           handleNotification:^(NSString* message, NSDictionary* additionalData, BOOL isActive) {
                                               // This function gets call when a notification is tapped on
                                               // or one is received while the app is in focus.
                                               NSString* messageTitle = @"OneSignal Example";
                                               NSString* fullMessage = [message copy];
                                               
                                               if (additionalData) {
                                                   if (additionalData[@"inAppTitle"])
                                                       messageTitle = additionalData[@"inAppTitle"];
                                                   
                                                   if (additionalData[@"actionSelected"])
                                                       fullMessage = [fullMessage stringByAppendingString:[NSString stringWithFormat:@"\nPressed ButtonId:%@", additionalData[@"actionSelected"]]];
                                               }
                                               

                                               
                                           }];
    
    
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)])
    {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    //fetch every 3 hrs----3600 secs = 1hr
    //[[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:10800];
        
    return YES;
}

-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    counter++;
    
    
    UIBackgroundFetchResult *result;
    //Download  the Content .
    if ([self.window.rootViewController.childViewControllers[0] isKindOfClass:[ViewController class]])
    {
        result = [self.window.rootViewController.childViewControllers[0] getHomeWeatherOnlyForBackground];
    }
    else
    {
        NSLog(@"HAD TO CREATE NEW VIEW TO CALL WEATHER FROM BACKGROUND FETCH");
        ViewController *view = [[ViewController alloc]init];
        result = [view getHomeWeatherOnlyForBackground];
    }
    
    //Cleanup

    //something went wrong and the homewx_dictionary is nil
    
    NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastBackgroundWeatherDateCalled"];
    float dateInterval =[[NSDate date] timeIntervalSinceDate:date];
    NSLog(@"SECONDS SINCE LAST CALL: %f",dateInterval);

    NSLog(@"BACKGROUND RESULT = %d ------ //0 new data, 1 no data, 2 failed",result);//0 new data, 1 no data, 2 failed
    if ((int)result == 0)        //new data
    {
        
        [self.oneSignal IdsAvailable:^(NSString *userId, NSString *pushToken) {
            
        }];

        
        NSLog(@"BACKGROUND FETCH HAS NEW DATA");
        
        
        completionHandler(UIBackgroundFetchResultNewData);
    }
    else if ((int) result == 1)
    {
        [self.oneSignal IdsAvailable:^(NSString *userId, NSString *pushToken) {
            
        }];

        
        NSLog(@"BACKGROUND FETCH HAS NO NEW DATA");
        

        completionHandler(UIBackgroundFetchResultNoData);
    }
    else
    {
        NSLog(@"BACKGROUND FETCH HAS FAILED");
        
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
    
    [self.oneSignal IdsAvailable:^(NSString *userId, NSString *pushToken) {
        
    }];
    
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
    
    //check that view is main viewcontroller class
    if ([self.window.rootViewController.childViewControllers[0] isKindOfClass:[ViewController class]])
    {
        if ([self.window.rootViewController.childViewControllers[0]  isNetworkAvailable] == NO)
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
            
            [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
            
            // Construct URL to sound file
            SystemSoundID soundID;
            
            NSURL *fileURL = [NSURL URLWithString:@"/System/Library/Audio/UISounds/Modern/sms_alert_note.caf"];
            
            AudioServicesCreateSystemSoundID((__bridge_retained CFURLRef)fileURL , &soundID);
            
            AudioServicesPlayAlertSound (soundID);
        }
        
        else
        {
            NSLog(@"CALLED GETHOMEWEATHER FROM APPLICATIONDIDBECOMEACTIVE");
            
            [self.window.rootViewController.childViewControllers[0] getHomeWeather];
        }

    }
    
//    //load username or prompt user if missing
//    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"userName"] == nil || [[NSUserDefaults standardUserDefaults] stringForKey:@"userName"] == NULL || [[[NSUserDefaults standardUserDefaults] stringForKey:@"userName"] isEqualToString:@""])
//    {
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Please enter your first name" message:@"Your name will be used to provide a personal experience." preferredStyle:UIAlertControllerStyleAlert];
//        
//        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//            [self.window.rootViewController.childViewControllers[0] setUserName:((UITextField *) alertController.textFields[0]).text];
//            [[NSUserDefaults standardUserDefaults] setObject:[self.window.rootViewController.childViewControllers[0] userName] forKey:@"userName"];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//            NSLog(@"JUST SAVED USER: %@",[self.window.rootViewController.childViewControllers[0] userName]);
//        }];
//        
//        [alertController addAction:okAction];
//        
//        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
//            textField.placeholder = @"First Name";
//        }];
//        
//        [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
//        
//    }
//    
//    else
//    {
//        [self.window.rootViewController.childViewControllers[0] setUserName:[[NSUserDefaults standardUserDefaults] stringForKey:@"userName"]];
//    }


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
