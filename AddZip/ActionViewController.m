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
#import "NSFileManager+PS.h"
//#import "PSPasswordManager.h"

@interface ActionViewController ()


@end


@implementation ActionViewController

static NSString *groupIdentifier = @"group.com.blockchainme.Pass";
static NSString *directoryLibCach = @"Library/Caches";

# pragma mark - View Lifecycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSURL *containerURL = [[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:groupIdentifier] URLByAppendingPathComponent:directoryLibCach];
    NSArray *localPassDirectory = [[NSFileManager defaultManager] listDirectoryAtPath:[containerURL path]];
    
    if ([localPassDirectory count] != 0) {
        [self showAlertforDeleteDirectory:[containerURL path]];
    } else {
        [self checkZipDirectory:[containerURL path]];
    }
}

- (void)checkZipDirectory:(NSString *)directory
{
    GetZipURLInItems(self.extensionContext.inputItems, ^(NSURL *url, NSError *error) {
        if (error == nil) {

            [WPZipArchive unzipFileAtPath:[url path] toDestination:directory];
            
//            NSArray *directoryList = [[NSFileManager defaultManager] listDirectoryAtPath:directory];
//            
//            BOOL isEmptyDirectory = [directoryList count] == 0;
//            BOOL isKeyInDirectory = [PSPasswordManager isKeysAtPath:directory];
//            BOOL isPasswordInAllSubDirectories = [PSPasswordManager isPasswordInAllSubDirectories:directory];
//            
//            if (isEmptyDirectory) {
//                [self showAlertWithMessage:@"This zip directory does not contain any encrypted passwords. Please try again after zipping pass generated \"password-store\" directory." alertTitle:@"Error"];
//            } else if (!isKeyInDirectory){
//                [self showAlertWithMessage:@"This zip directory does not contain any gpg keys. Please try again after zipping the \"password-store\" directory with the relevant key inside." alertTitle:@"Error"];
//            } else if (!isPasswordInAllSubDirectories) {
//                [self showAlertWithMessage:@"This zip directory does not contain gpg encrypted passwords. Please try again after zipping the \"password-store\" directory with encrypted passwords." alertTitle:@"Error"];
//            } else {
//                [self showAlertWithMessage:@"Passwords Successfully Imported into Pass" alertTitle:@""];
//            }
//            
//        } else {
//            [self showAlertWithMessage:error.localizedDescription alertTitle:@"Error"];
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

# pragma mark - Alert Methods

- (void)showAlertWithMessage:(NSString *)message alertTitle:(NSString *)title
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okayAction = [UIAlertAction actionWithTitle:@"Okay"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
    [self done];
    }];
    [alert addAction:okayAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showAlertforDeleteDirectory:(NSString *)directory
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Update Passwords"
                                                                   message:@"Pass currently contains encrypted passwords. Do you want to override the local saved directory?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           [[NSFileManager defaultManager] deleteAllFilesinDirectory:directory];
                                                           [self checkZipDirectory:directory];
    }];
    [alert addAction:yesAction];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No"
                                                         style:UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction * action) {}];
    [alert addAction:noAction];
    [self presentViewController:alert animated:YES completion:nil];
}

# pragma mark - Action Methods

- (void)done
{
    [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
}

@end
