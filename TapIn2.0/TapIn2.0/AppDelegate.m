//
//  AppDelegate.m
//  TapIn2.0
//
//  Created by Vu Tran on 10/12/12.
//  Copyright (c) 2012 Vu Tran. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"
#import "Mixpanel.h"
#import "ASIHTTPRequest.h"
#import "Utilities.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    // Override point for customization after application launch.
    [Mixpanel sharedInstanceWithToken:@"1b683ba52e759e1045150e8b69a6c16f"];
    
    // Let the device know we want to receive push notifications
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // app was already in the foreground
    if ( application.applicationState == UIApplicationStateActive )
    {
        NSString * urlString = [NSString stringWithFormat:@"http://duck.tapin.tv/play_video.php?v=%@", [[userInfo objectForKey:@"aps"] objectForKey:@"video"]];
        NSLog(@"This is the notification %@",urlString);
    }
    // app was just brought from background to foreground
    else
    {
        NSString * message = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
        message = [message lowercaseString];
        
        if ([message rangeOfString:@"download"].location != NSNotFound)
        {
            //Download app
            NSURL *url = [NSURL URLWithString:@"http://static.tapin.tv/duck/index.html"];
            if (![[UIApplication sharedApplication] openURL:url])
                NSLog(@"%@%@",@"Failed to open url:",[url description]);
        }
        
        else {
            //Deeplink
            NSString * urlString = [NSString stringWithFormat:@"http://duck.tapin.tv/play_video.php?v=%@", [[userInfo objectForKey:@"aps"] objectForKey:@"video"]];
            NSURL *url = [NSURL URLWithString:urlString];
            if (![[UIApplication sharedApplication] openURL:url])
                NSLog(@"%@%@",@"Failed to open url:",[url description]);

        }
    }
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    
	NSString * dt = [NSString stringWithFormat:@"%@", deviceToken];
    dt = [dt stringByReplacingOccurrencesOfString:@" " withString:@""];
    dt = [dt stringByReplacingOccurrencesOfString:@"<" withString:@""];
    dt = [dt stringByReplacingOccurrencesOfString:@">" withString:@""];

	NSLog(@"My token is: %@", dt);
    NSString * urlString = [NSString stringWithFormat:@"http://duck.tapin.tv/storepush.php?phoneid=%@&token=%@", [Utilities phoneID], dt];
    NSURL *url = [NSURL URLWithString: urlString];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        NSString *response = [request responseString];
    }
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"App Close"];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"App Open"];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
