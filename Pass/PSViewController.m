//
//  PSViewController.m
//  pass-ios
//
//  Created by Kiara Robles on 11/3/16.
//  Copyright © 2016 Kiara Robles. All rights reserved.
//

#import <Valet/Valet.h>
#import <ObjectivePGP/ObjectivePGP.h>
#import "AppDelegate.h"
#import "PSEntry.h"
#import "PSViewController.h"
#import "PSEntryManager.h"
#import "PSEntryViewController.h"
#import "PSPasswordManager.h"
#import "NSFileManager+PS.h"
#import "FXKeychain.h"

@interface PSViewController ()

@property NSURL *documentsDirectory;
@property NSURL *documentsURL;
@property (nonatomic, retain) VALSecureEnclaveValet *keychain;

@end

@implementation PSViewController


# pragma mark - View Lifecycle Methods


- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.title == nil) {
        self.title = NSLocalizedString(@"Pass Passwords", @"Password title");
    }

    NSArray *paths = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    self.documentsDirectory = [paths lastObject];
    
    UIBarButtonItem *clearButton = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                    target:self
                                    action:@selector(clearKeychain)];
    self.navigationItem.rightBarButtonItem = clearButton;
    
    self.keychain = [[VALSecureEnclaveValet alloc] initWithIdentifier:@"Pass" accessControl:VALAccessControlUserPresence];
    
    if ([self.title isEqualToString:@"Pass Passwords"]){
        [self checkKeyLocally];
    }
}

# pragma mark - Helper Methods

- (void)checkKeyLocally
{
    BOOL isKeyInDocuments = [PSPasswordManager isKeysAtPath:self.entryManager.path];
    PSEntry *keyInKeychain = [[FXKeychain defaultKeychain] objectForKey:@"Pass"];
    
    if (isKeyInDocuments) {
        NSMutableArray *keys = [PSPasswordManager keysAtPath:self.entryManager.path];

        if (keys.count >= 2) {
            NSLog(@"Too many keys in file system. Please select one to use, and move or delete the others.");
        }
    }

    if (keyInKeychain == nil && isKeyInDocuments) {
        [self saveKey];
    }
}

- (void)saveKey {
    
    NSMutableArray *keys = [PSPasswordManager keysAtPath:self.entryManager.path];
    PSEntry *entry = [keys objectAtIndex:0];
    BOOL isKeySaved = [[FXKeychain defaultKeychain] setObject:entry forKey:@"Pass"];
    
    if (isKeySaved) {
        PSEntry *savedKey = [[FXKeychain defaultKeychain] objectForKey:@"Pass"];
        NSLog(@"savedKey: %@", savedKey);
        
        [self reloadDataViewController];
    }
}

# pragma mark - Action Methods

- (void)clearKeychain
{
    // TODO Refactor into shared function
    [PSPasswordManager deleteKeysAtPath:self.entryManager.path];
    [self.keychain removeObjectForKey:@"gpg-passphrase-touchid"];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Clear Keychain"
                                                                   message:@"Proceed to remove all passwords from the keychain" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                         style:UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction *action) {
    }];
    [alert addAction:cancelAction];
    UIAlertAction *okayAction = [UIAlertAction actionWithTitle:@"Yes"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          
        [[NSFileManager defaultManager] deleteAllFilesinDirectory:[self.documentsDirectory path]];
        [self reloadDataViewController];
                                                          
    }];
    [alert addAction:okayAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)reloadDataViewController
{
    PSEntryManager *clearedEntries = [[PSEntryManager alloc] initWithPath:[self.documentsDirectory path]];
    PSViewController *viewController = [[PSViewController alloc] init];
    viewController.entryManager = clearedEntries;
    
    NSMutableArray *stackViewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    [stackViewControllers removeLastObject];
    [stackViewControllers addObject:viewController];
    [self.navigationController setViewControllers:stackViewControllers animated:NO];
}

# pragma mark - Table View Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    PSEntry *savedKey = [[FXKeychain defaultKeychain] objectForKey:@"Pass"];

    if (savedKey == nil) {
        [self.entryManager.entries removeAllObjects];
        [self showAlertWithMessage:@"Add an asc key with fileshare" alertTitle:@"No keys"];
    }
    
    for (NSUInteger i = 0; i < self.entryManager.entries.count; i++) {
        PSEntry *entry = [self.entryManager.entries objectAtIndex:i];
        
        BOOL isEntryKey = !entry.isDirectory && [entry.name hasSuffix:@".gpg"];
        BOOL isEntryDirectoryWithKey = entry.isDirectory && [PSPasswordManager isPasswordInAllSubDirectories:entry.path];
        
        if (!isEntryKey && !isEntryDirectoryWithKey) {
            [self.entryManager.entries removeObjectAtIndex:i];
        }
    }
    
    return self.entryManager.entries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"EntryCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    PSEntry *entry = [self.entryManager.entries objectAtIndex:indexPath.row];

    BOOL isKey = !entry.isDirectory && ([entry.name hasSuffix:@".asc"]);
    if (isKey) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.userInteractionEnabled = false;
    }
    
    cell.textLabel.text = entry.name;
    if (entry.isDirectory)
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    for (int i = 0; i < self.entryManager.entries.count; i++) {
        PSEntry *entry = [self.entryManager.entries objectAtIndex:i];
        NSString *letterString = [[entry.name substringToIndex:1] uppercaseString];
        if ([letterString isEqualToString:title]) {
            [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            break;
        }
    }
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    PSEntry *entry = [self.entryManager.entries objectAtIndex:indexPath.row];
    
    if (entry.isDirectory) {
        // push subdir view onto stack
        PSViewController *subviewController = [[PSViewController alloc] init];
        subviewController.entryManager = [[PSEntryManager alloc] initWithPath:entry.path];
        subviewController.title = entry.name;
        [[self navigationController] pushViewController:subviewController animated:YES];
    } else {
        PSEntryViewController *detailController = [[PSEntryViewController alloc] init];
        detailController.entry = entry;
        [[self navigationController] pushViewController:detailController animated:YES];
    }
}

#pragma - Alert Methods

- (void)showAlertWithMessage:(NSString *)message alertTitle:(NSString *)title
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okayAction = [UIAlertAction actionWithTitle:@"Okay"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           
                                                       }];
    [alert addAction:okayAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showAlertForKeyOverride
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"New Keys"
                                                                   message:@"You currently have a .asc key saved to your keychain, and new keys were detected in filesystem. Do you want to override them?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           [self saveKey];
                                                       }];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No"
                                                         style:UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction * action) {
                                                           
                                                       }];
    [alert addAction:yesAction];
    [alert addAction:noAction];
    [self presentViewController:alert animated:YES completion:nil];
    
}

@end

