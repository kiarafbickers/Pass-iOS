/*
 * Copyright (C) 2012  Brian A. Mattern <rephorm@rephorm.com>.
 * Copyright (C) 2015  David Beitey <david@davidjb.com>.
 * All Rights Reserved.
 * This file is licensed under the GPLv2+.
 * Please see COPYING for more information
 */
#import "PSViewController.h"
#import "PSDataController.h"

@interface passwordstoreApplication: UIApplication <UIApplicationDelegate>
{
    UIWindow *_window;
    PSViewController *_viewController;
    PSDataController *_entries;
}
@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, strong) NSString *passDir;

@end


@implementation passwordstoreApplication

@synthesize window = _window;

static NSString *groupIdentifier = @"group.com.blockchainme.Pass";
static NSString *directoryLibCach = @"Library/Caches";

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    NSURL *containerURL = [[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:groupIdentifier] URLByAppendingPathComponent:directoryLibCach];
    // [self listDirectoryAtPath:[containerURL path]];
    
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _entries = [[PSDataController alloc] initWithPath:[containerURL path]];
    _viewController = [[PSViewController alloc] init];
    _viewController.entries = _entries;

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:_viewController];
    // Ensures app is able to change orientation; subviews don't work
    _window.rootViewController = navigationController;
    [_window makeKeyAndVisible];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // TODO: Remove passphrase on app exit for now
}

+ (NSURL*)getSharedContainerURLPath
{
    return [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:groupIdentifier];
}

# pragma mark - Debuging Methods

- (void)listDirectoryAtPath:(NSString *)directory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *fileList = [fileManager contentsOfDirectoryAtPath:directory error:nil];
    NSMutableArray *directoryList = [[NSMutableArray alloc] init];
    
    for(NSString *file in fileList) {
        NSString *path = [directory stringByAppendingPathComponent:file];
        BOOL isDirectory = NO;
        [fileManager fileExistsAtPath:path isDirectory:(&isDirectory)];
        if(isDirectory) {
            [directoryList addObject:file];
        }
    }
}

@end
