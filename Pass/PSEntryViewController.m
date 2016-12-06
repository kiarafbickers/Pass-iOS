//
//  PSEntryViewController.m
//  pass-ios
//
//  Created by Kiara Robles on 11/3/16.
//  Copyright © 2016 Kiara Robles. All rights reserved.
//

#import <Valet/Valet.h>
#import "PSEntry.h"
#import "PSEntryViewController.h"
#import "PSEntryManager.h"

@interface PSEntryViewController()

@property (nonatomic,retain) VALSecureEnclaveValet *keychain;
@property (nonatomic,retain) NSString *keychain_key;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTaskIdentifier;

- (void)copyName;
- (void)showAlertWithMessage:(NSString *)message alertTitle:(NSString *)title;
- (void)decryptGpgWithPasswordOnly:(BOOL)passwordOnly copyToPasteboard:(BOOL)pasteboard showInAlert:(BOOL)showAlert;
- (void)requestGpgWithPasswordOnly:(BOOL)passwordOnly entryTitle:(NSString *)title copyToPasteboard:(BOOL)pasteboard showInAlert:(BOOL)showAlert;

@end


@implementation PSEntryViewController

@synthesize entry;

# pragma mark - View Lifecycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Passwords", @"Password title");
    self.backgroundTaskIdentifier = 0;
    
    self.keychain = [[VALSecureEnclaveValet alloc] initWithIdentifier:@"Pass" accessControl:VALAccessControlUserPresence];
    self.useTouchID = [[self.keychain class] supportsSecureEnclaveKeychainItems];
    self.pasteboard = [UIPasteboard generalPasteboard];
    
    // TODO: Further work required for non-TouchID devices
    if (self.useTouchID) {
        // Local TouchID authentication
        self.keychain_key = @"gpg-passphrase-touchid";
    } else {
        self.keychain_key = @"passphrase";
    }
}

# pragma mark - Table View Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"EntryDetailCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:cellIdentifier];
    }
    
    switch(indexPath.row) {
        case 0:
            cell.textLabel.text = @"Name";
            cell.detailTextLabel.text = self.entry.name;
            break;
        case 1:
            cell.textLabel.text = @"Password";
            cell.detailTextLabel.text = @"Tap to show";
            break;
        case 2:
            cell.textLabel.text = @"Password";
            cell.detailTextLabel.text = @"Tap to copy";
            break;
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch(indexPath.row) {
        case 0:
            // Name
            [self copyName];
            break;
        case 1:
            // Password, first line only, alert
            [self decryptGpgWithPasswordOnly:YES copyToPasteboard:NO showInAlert:YES];
            break;
        case 2:
            // Password, first line only, pasteboard
            [self decryptGpgWithPasswordOnly:YES copyToPasteboard:YES showInAlert:NO];
            break;
        default:
            break;
    }
}

- (void)decryptGpgWithPasswordOnly:(BOOL)passwordOnly copyToPasteboard:(BOOL)pasteboard showInAlert:(BOOL)showAlert
{
    BOOL result = NO;
    NSString *password; // Decryped password
    NSString *keychain_password; // iOS keychain password
    
    if (self.useTouchID) {
        keychain_password = [self.keychain stringForKey:self.keychain_key userPrompt:@"Unlock your keychain to access this password."];
    } else {
        keychain_password = [self.keychain stringForKey:self.keychain_key];
    }
    
    if (keychain_password) {
        password = [PSEntryManager passWithPassword:keychain_password passwordOnly:passwordOnly];
        NSLog(@"password: %@", password);
        NSLog(@"password: %@", password);
        if (password) {
            [self performPasswordAction:password entryTitle:self.entry.name copyToPasteboard:pasteboard showInAlert:showAlert];
            result = YES;
        }
    }
    
    if (!result) {
        // GPG decryption failed with stored keychain passphrase or no keychain passphrase present
        // so try requesting the passphase
        [self requestGpgWithPasswordOnly:passwordOnly entryTitle:self.entry.name copyToPasteboard:pasteboard showInAlert:showAlert];
    }
}

- (void)requestGpgWithPasswordOnly:(BOOL)passwordOnly entryTitle:(NSString *)title copyToPasteboard:(BOOL)pasteboard showInAlert:(BOOL)showAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Password"
                                                                   message:@"Enter password for your GPG key"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action) {
    }];
    [alert addAction:cancelAction];
    
    
    UIAlertAction *okayAction = [UIAlertAction actionWithTitle:@"Okay"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action) {
        NSString *keychain_passphrase = ((UITextField *)[alert.textFields objectAtIndex:0]).text;
        NSString *password = [self.entry passWithPassword:keychain_passphrase passwordOnly:YES];
        if (password) {
            [self.keychain setString:keychain_passphrase forKey:self.keychain_key];
            [self performPasswordAction:password entryTitle:title copyToPasteboard:pasteboard showInAlert:showAlert];
        } else {
            [self showAlertWithMessage:@"Passphrase invalid" alertTitle:@"Passphrase"];
        }
    }];
    [alert addAction:okayAction];
    
    [alert addTextFieldWithConfigurationHandler: ^(UITextField *textField) {
        textField.placeholder = @"Passphrase";
        textField.secureTextEntry = YES;
    }];
    
    [self presentViewController:alert animated:YES completion:nil];
}

# pragma mark - Paste Methods

- (void) performPasswordAction:(NSString *)password entryTitle:(NSString *)title copyToPasteboard:(BOOL)pasteboard showInAlert:(BOOL)showAlert
{
    if (pasteboard) {
        [self copyToPasteboard:password clearTimeout:45.0];
    }
    if (showAlert) {
        [self showAlertWithMessage:password alertTitle:title];
    }
}

- (void)copyName
{
    [self copyToPasteboard:self.entry.name];
}

- (void)copyToPasteboard:(NSString *)string
{
    self.pasteboard.string = string;
}

- (void)copyToPasteboard:(NSString *)string clearTimeout:(double)timeout
{
    NSString *originalPasteboard = self.pasteboard.string;
    [self copyToPasteboard:string];
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:originalPasteboard forKey:@"originalPasteboard"];
    
    __weak UIViewController *weakSelf = self;
    self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        // Once run, invalidate
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
        self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSTimer *timer = [NSTimer timerWithTimeInterval:timeout target:weakSelf selector:@selector(restorePasteboardWithTimer:) userInfo:userInfo repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    });
}

- (void)restorePasteboardWithTimer:(NSTimer *)timer
{
    NSDictionary *dict = [timer userInfo];
    NSString *originalPasteboard = [dict objectForKey:@"originalPasteboard"];
    
    // Replace the original string. We can't access the pasteboard to
    // actually determine whether we should replace or not, so do it anyway.
    // TODO: Implement an option
    [self copyToPasteboard:originalPasteboard];
    
    // Once run, invalidate this task
    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
    self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
}

# pragma mark - Alert Methods

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

@end
