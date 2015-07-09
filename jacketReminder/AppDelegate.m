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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)])
    {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    //[[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    //fetch every 30 mins
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:1800];

    return YES;
}

-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    counter++;
    
    NSLog(@"########### Received Background Fetch #%d ###########",counter);
    //Download  the Content .
    ViewController *view = [[ViewController alloc]init];
    [view getHomeWeather];
    
    // Set up Local Notifications
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    NSDate *now = [NSDate date];
    localNotification.fireDate = now;
    localNotification.alertBody = [NSString stringWithFormat:@"fetch #%d in background",counter];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
    //Cleanup
    completionHandler(UIBackgroundFetchResultNewData);
    NSLog(@"Fetch completed");
    
}




- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSLog(@"\n\n\napplicationWillResignActive\n\n\n");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"\n\n\nDID ENTER BACKGROUND\n\n\n");
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     NSLog(@"\n\n\napplicationWillEnterForeground\n\n\n");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     //NSLog(@"\n\n\napplicationDidBecomeActive\n\n\n");
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
