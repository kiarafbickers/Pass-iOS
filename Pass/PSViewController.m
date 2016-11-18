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
#import "PSPrefs.h"
#import "PSEntry.h"
#import "PSViewController.h"
#import "PSDataController.h"
#import "PSEntryViewController.h"

@implementation PSViewController

@synthesize entries;

# pragma mark - View Lifecycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.title == nil) {
        self.title = NSLocalizedString(@"Passwords", @"Password title");
    }
    
    UIBarButtonItem *clearButton = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                    target:self
                                    action:@selector(clearKeychain)];
    self.navigationItem.rightBarButtonItem = clearButton;
}

# pragma mark - Action Methods

- (void)clearKeychain
{
    // TODO Refactor into shared function
    VALSecureEnclaveValet *keychain = [[VALSecureEnclaveValet alloc] initWithIdentifier:@"Pass" accessControl:VALAccessControlUserPresence];
    [keychain removeObjectForKey:@"gpg-passphrase-touchid"];
    
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
                                                          
        NSURL *containerURL = [[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:groupIdentifier] URLByAppendingPathComponent:directoryLibCach];
        [self deleteAllFilesinDirectory:[containerURL path]];
        [self reloadDataViewController];
                                                          
    }];
    [alert addAction:okayAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)reloadDataViewController
{
    NSURL *containerURL = [[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:groupIdentifier] URLByAppendingPathComponent:directoryLibCach];
    
    PSDataController *clearedEntries = [[PSDataController alloc] initWithPath:[containerURL path]];
    PSViewController *viewController = [[PSViewController alloc] init];
    viewController.entries = clearedEntries;
    
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
    return [self.entries numEntries];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"EntryCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // Filter out keys from selectible directories
    PSEntry *entry = [self.entries entryAtIndex:(unsigned int)indexPath.row];
    if ([entry.name hasSuffix:@".asc"]) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.userInteractionEnabled = false;
    }
    
    cell.textLabel.text = entry.name;
    if (entry.is_dir)
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    // Return unique, capitalised first letters of entries
    NSMutableArray *firstLetters = [[NSMutableArray alloc] init];
    [firstLetters addObject:UITableViewIndexSearch];
    for (int i = 0; i < [self.entries numEntries]; i++) {
        NSString *letterString = [[[self.entries entryAtIndex:i].name substringToIndex:1] uppercaseString];
        if (![firstLetters containsObject:letterString]) {
            [firstLetters addObject:letterString];
        }
    }
    return firstLetters;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    for (int i = 0; i < [self.entries numEntries]; i++) {
        NSString *letterString = [[[self.entries entryAtIndex:i].name substringToIndex:1] uppercaseString];
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
    
    PSEntry *entry = [self.entries entryAtIndex:(unsigned int)indexPath.row];
    
    if (entry.is_dir) {
        // push subdir view onto stack
        PSViewController *subviewController = [[PSViewController alloc] init];
        subviewController.entries = [[PSDataController alloc] initWithPath:entry.path];
        subviewController.title = entry.name;
        [[self navigationController] pushViewController:subviewController animated:YES];
    } else {
        PSEntryViewController *detailController = [[PSEntryViewController alloc] init];
        detailController.entry = entry;
        [[self navigationController] pushViewController:detailController animated:YES];
    }
}

# pragma mark - FileManager Methods

// TODO: Get NSFileManager+PS.h to work in this target

- (void)deleteAllFilesinDirectory:(NSString *)directory
{
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:directory];
    NSError* err = nil;
    BOOL res;
    
    NSString *file;
    while (file = [enumerator nextObject]) {
        res = [[NSFileManager defaultManager] removeItemAtPath:[directory stringByAppendingPathComponent:file] error:&err];
        if (!res && err) {
            NSLog(@"Oops: %@", err);
        }
    }
}

@end

