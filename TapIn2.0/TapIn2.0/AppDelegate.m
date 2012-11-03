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

@interface AppDelegate(){
    UITextField *passwordField;
}
-(void)promptUsernameInput;
@end

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
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"foo", @"key", nil];
    [[Utilities sharedInstance] sendGet:@"endpointhere" params:dict delegate:self];
    
    NSLog(@"test %@", [Utilities userDefaultValueforKey:@"username"]);
    if(![Utilities userDefaultValueforKey:@"username"])
    [self performSelector:@selector(promptUsernameInput) withObject:nil afterDelay:1];
       
    return YES;
}

-(void)promptUsernameInput {
    UIAlertView *passwordAlert = [[UIAlertView alloc] initWithTitle:@"Howdy" message:@"\n\n\n"
                                                           delegate:self cancelButtonTitle:NSLocalizedString(@"Go",nil) otherButtonTitles: nil];
    
    UILabel *passwordLabel = [[UILabel alloc] initWithFrame:CGRectMake(12,40,260,25)];
    passwordLabel.font = [UIFont systemFontOfSize:16];
    passwordLabel.textColor = [UIColor whiteColor];
    passwordLabel.backgroundColor = [UIColor clearColor];
    passwordLabel.shadowColor = [UIColor blackColor];
    passwordLabel.shadowOffset = CGSizeMake(0,-1);
    passwordLabel.textAlignment = UITextAlignmentCenter;
    passwordLabel.text = @"Sign In";
    [passwordAlert addSubview:passwordLabel];
    
    UIImageView *passwordImage = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"passwordfield" ofType:@"png"]]];
    passwordImage.frame = CGRectMake(11,69,262,31);
    [passwordAlert addSubview:passwordImage];
    
    passwordField = [[UITextField alloc] initWithFrame:CGRectMake(16,73,252,25)];
    passwordField.font = [UIFont systemFontOfSize:18];
    passwordField.backgroundColor = [UIColor whiteColor];
    passwordField.secureTextEntry = NO;
    passwordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    passwordField.autocorrectionType = UITextAutocorrectionTypeNo;
    passwordField.keyboardAppearance = UIKeyboardAppearanceAlert;
    passwordField.delegate = self;
    [passwordField becomeFirstResponder];
    [passwordAlert addSubview:passwordField];
    
    [passwordAlert setTransform:CGAffineTransformMakeTranslation(0,0)];
    [passwordAlert show];

}

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    return [self.viewController supportedInterfaceOrientations];
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
        NSString * urlString = [NSString stringWithFormat:@"http://local.my.codeday.org/videos/watch/%@", [[userInfo objectForKey:@"aps"] objectForKey:@"video"]];
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
            NSURL *url = [NSURL URLWithString:@"http://static.tapin.tv/codeday/index.html"];
            if (![[UIApplication sharedApplication] openURL:url])
                NSLog(@"%@%@",@"Failed to open url:",[url description]);
        }
        
        else {
            //Deeplink
            NSString * urlString = [NSString stringWithFormat:@"http://local.my.codeday.org/videos/watch/%@", [[userInfo objectForKey:@"aps"] objectForKey:@"video"]];
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
    
    NSMutableDictionary * params = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[Utilities phoneID], @"phone_id", dt, @"push", nil];
    [[Utilities sharedInstance] sendGet:@"phone/enroll" params:params delegate:self];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {    
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if([passwordField.text length]>0){
        NSLog(@"got here %@", passwordField.text);
        [Utilities setUserDefaultValue:passwordField.text forKey:@"username"];
        NSMutableDictionary * params = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[Utilities phoneID], @"phone_id", passwordField.text, @"username", nil];
        [[Utilities sharedInstance] sendGet:@"phone/associate" params:params delegate:self];
    }
    else {
        [self promptUsernameInput];
    }
              
    NSLog(@"done %@", passwordField.text);
    
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
