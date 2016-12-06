/*
 * Copyright (C) 2012  Brian A. Mattern <rephorm@rephorm.com>.
 * Copyright (C) 2015  David Beitey <david@davidjb.com>.
 * All Rights Reserved.
 * This file is licensed under the GPLv2+.
 * Please see COPYING for more information
 */
#import "PSViewController.h"
#import "PSEntryManager.h"

@interface passwordstoreApplication: UIApplication <UIApplicationDelegate>
{
    UIWindow *_window;
    PSViewController *_viewController;
    PSEntryManager *_entryManager;
}
@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, strong) NSString *passDir;

@end

@implementation passwordstoreApplication

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    NSArray *paths = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentsDirectory = [paths lastObject];
    
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _entryManager = [[PSEntryManager alloc] initWithPath:[documentsDirectory path]];
    _viewController = [[PSViewController alloc] init];
    _viewController.entryManager = _entryManager;

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:_viewController];
    // Ensures app is able to change orientation; subviews don't work
    _window.rootViewController = navigationController;
    [_window makeKeyAndVisible];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // TODO: Remove passphrase on app exit for now
}

@end
