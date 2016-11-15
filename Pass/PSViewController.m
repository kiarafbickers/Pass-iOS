//
//  PSViewController.m
//  pass-ios
//
//  Created by Kiara Robles on 11/3/16.
//  Copyright © 2016 Kiara Robles. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Valet/Valet.h>
#import "PSViewController.h"
#import "PSDataController.h"
#import "PSEntry.h"
#import "PSEntryViewController.h"

@implementation PSViewController

@synthesize entries;

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.title == nil) {
        self.title = NSLocalizedString(@"Passwords", @"Password title");
    }
    
    UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithTitle:@"Clear Keychain" style:UIBarButtonItemStylePlain target:self action:@selector(clearPassphrase) ];
    self.navigationItem.rightBarButtonItem = clearButton;
}

- (void)clearPassphrase {
    // TODO Refactor into shared function
    VALSecureEnclaveValet *keychain = [[VALSecureEnclaveValet alloc] initWithIdentifier:@"Pass" accessControl:VALAccessControlUserPresence];
    [keychain removeObjectForKey:@"gpg-passphrase-touchid"];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Keychain cleared" message:@"Passphrase has been removed from the keychain" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.entries numEntries];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"EntryCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    PSEntry *entry = [self.entries entryAtIndex:indexPath.row];
    
    cell.textLabel.text = entry.name;
    if (entry.is_dir)
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
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

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    for (int i = 0; i < [self.entries numEntries]; i++) {
        NSString *letterString = [[[self.entries entryAtIndex:i].name substringToIndex:1] uppercaseString];
        if ([letterString isEqualToString:title]) {
            [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            break;
        }
    }
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    PSEntry *entry = [self.entries entryAtIndex:indexPath.row];
    
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

@end

