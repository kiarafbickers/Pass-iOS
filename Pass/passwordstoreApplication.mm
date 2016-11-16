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

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    static NSString *GroupIdentifier = @"group.com.blockchainme.Pass";
    NSURL *containerURL = [[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:GroupIdentifier] URLByAppendingPathComponent:@"Library/Caches"];
    NSLog(@"APP: containerURL: %@", [containerURL path]);
    
    [self listDirectoryAtPath:[containerURL path]];
    
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _entries = [[PSDataController alloc] initWithPath:[containerURL path]];
    NSLog(@"entries: %@", _entries);

    _viewController = [[PSViewController alloc] init];
    _viewController.entries = _entries;

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:_viewController];

    // Ensures app is able to change orientation; subviews don't work
    _window.rootViewController = navigationController;
    [_window makeKeyAndVisible];
    
    [self getCacheDirPath];
    [self showFiles];
}

-(void)listDirectoryAtPath:(NSString *)directory
{
    NSFileManager *fM = [NSFileManager defaultManager];
    NSArray *fileList = [fM contentsOfDirectoryAtPath:directory error:nil];
    NSMutableArray *directoryList = [[NSMutableArray alloc] init];
    
    for(NSString *file in fileList) {
        NSString *path = [directory stringByAppendingPathComponent:file];
        BOOL isDir = NO;
        [fM fileExistsAtPath:path isDirectory:(&isDir)];
        if(isDir) {
            [directoryList addObject:file];
        }
    }
    
    NSLog(@"directoryList: %@", directoryList);
}

+ (NSURL*)getSharedContainerURLPath
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *appGroupName = @"group.com.blockchainme.Pass";
    NSURL *groupContainerURL = [fm containerURLForSecurityApplicationGroupIdentifier:appGroupName];
    
    return groupContainerURL;
}

+ (void)createDirAtSharedContainerPath
{
    NSString *sharedContainerPathLocation = [[self getSharedContainerURLPath] absoluteString];
    NSString *directoryToCreate = @"user";
    NSString *dirPath = [sharedContainerPathLocation stringByAppendingPathComponent:directoryToCreate];
    
    BOOL isdir;
    NSError *error = nil;
    NSFileManager *mgr = [[NSFileManager alloc]init];
    if (![mgr fileExistsAtPath:dirPath isDirectory:&isdir]) { //create a dir only that does not exists
        if (![mgr createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"Error while creating dir: %@", error.localizedDescription);
        } else {
            NSLog(@"Dir was created....");
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // remove passphrase on app exit for now
    //  NSLog(@"App will terminate");
    //  [[PDKeychainBindings sharedKeychainBindings] removeObjectForKey:@"passphrase"];
}

- (NSString *)getCacheDirPath
{
    NSString *homePath = NSHomeDirectory();
    NSLog(@"homePath: %@",homePath);
    
    NSString *path = nil;
    NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    if([myPathList count])
    {
//        NSString *bundleName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
//        path = [[myPathList objectAtIndex:0] stringByAppendingPathComponent:bundleName];
//        
//        NSLog(@"Path: %@",path);
        
        path = [myPathList objectAtIndex:0];
        NSLog(@"Path: %@",path);
    }
    return path;
}

- (NSMutableArray *)showFiles
{
    NSError *err        = nil;
    NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *myPath    = [myPathList  objectAtIndex:0];
    NSArray *dirContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:myPath error:&err];
    if(err) NSLog(@"showFiles() - ERROR: %@",[err localizedDescription]);
    NSMutableArray *filePaths  = nil;
    
    int count = (int)[dirContent count];
    for(int i=0; i<count; i++)
    {
        [filePaths addObject:[dirContent objectAtIndex:i]];
        NSLog(@"filePaths: %@", filePaths);
    }
    return filePaths;
}

@end
