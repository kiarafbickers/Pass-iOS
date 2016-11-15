//
//  ActionViewController.m
//  AddZip
//
//  Created by Kiara Robles on 11/10/16.
//  Copyright © 2016 Kiara Robles. All rights reserved.
//

#import "ActionViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <WPZipArchive/WPZipArchive.h>

@interface ActionViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ActionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    static NSString *GroupIdentifier = @"group.com.blockchainme.Pass";
    GetZipURLInItems(self.extensionContext.inputItems, ^(NSURL *url, NSError *error) {
        if (error == nil) {
            
            NSURL *containerURL = [[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:GroupIdentifier] URLByAppendingPathComponent:@"Library/Caches"];
            [WPZipArchive unzipFileAtPath:[url path] toDestination:[containerURL path]];
            
            NSLog(@"EXT: containerURL: %@", [containerURL path]);
            NSLog(@"EXT: zipURL: %@", [url path]);

            [self listDirectoryAtPath:[containerURL path]];
        }});
}

- (NSArray *)listDirectoryAtPath:(NSString *)directory
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
        
        NSLog(@"directoryList: %@", directoryList);
    }
    
    return directoryList;
}
            
static void GetZipURLInItems(NSArray *inputItems, void (^completionHandler)(NSURL *URL, NSError *error))
{
    BOOL zipFound = YES;
    for (NSExtensionItem *item in inputItems) {
        for (NSItemProvider *itemProvider in item.attachments) {
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeZipArchive]) {
                
                NSLog(@"itemProvider: %@", itemProvider);
                
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeZipArchive options:nil completionHandler:completionHandler];
                zipFound = YES;
                break;
            }
        }
        
        if (zipFound) {
            // We only handle one image, so stop looking for more.
            
            break;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)done
{
    [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
}

@end
