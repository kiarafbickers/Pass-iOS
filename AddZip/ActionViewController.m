//
//  ActionViewController.m
//  AddZip
//
//  Created by Kiara Robles on 11/10/16.
//  Copyright © 2016 Kiara Robles. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import <WPZipArchive/WPZipArchive.h>
#import "ActionViewController.h"

@interface ActionViewController ()

@end


@implementation ActionViewController

static NSString *groupIdentifier = @"group.com.blockchainme.Pass";
static NSString *directoryLibCach = @"Library/Caches";

# pragma mark - View Lifecycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];

    GetZipURLInItems(self.extensionContext.inputItems, ^(NSURL *url, NSError *error) {
        if (error == nil) {
            
            NSURL *containerURL = [[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:groupIdentifier] URLByAppendingPathComponent:directoryLibCach];
            [WPZipArchive unzipFileAtPath:[url path] toDestination:[containerURL path]];
        } else {
            [self showAlertWithMessage:error.localizedDescription alertTitle:@"Error"];
        }
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

# pragma mark - WPZipArchive Methods

static void GetZipURLInItems(NSArray *inputItems, void (^completionHandler)(NSURL *URL, NSError *error))
{
    BOOL zipFound = YES;
    for (NSExtensionItem *item in inputItems) {
        for (NSItemProvider *itemProvider in item.attachments) {
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeZipArchive]) {
                
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeZipArchive options:nil completionHandler:completionHandler];
                zipFound = YES;
                break;
            }
        }
        
        if (zipFound) {
            break;
        }
    }
}

# pragma mark - Action Methods

- (IBAction)done
{
    [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
}

- (void)showAlertWithMessage:(NSString *)message alertTitle:(NSString *)title
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okayAction = [UIAlertAction actionWithTitle:@"Okay"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {}];
    [alert addAction:okayAction];
    [self presentViewController:alert animated:YES completion:nil];
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
    
    NSLog(@"directoryList: %@", directoryList);
}

@end
