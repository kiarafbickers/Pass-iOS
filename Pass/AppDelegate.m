//
//  AppDelegate.m
//  Pass
//
//  Created by Kiara Robles on 11/10/16.
//  Copyright © 2016 Kiara Robles. All rights reserved.
//

#import "AppDelegate.h"
#import "HockeyKey.h"
@import HockeySDK;

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:AppID];
    // Do some additional configuration if needed here
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{

}

- (void)applicationWillTerminate:(UIApplication *)application
{

}

- (void) resetApp
{
   UIViewController *vc = self.window.rootViewController;
   _window.rootViewController = vc;
}

@end
