//
//  PSEntry.m
//  pass-ios
//
//  Created by Kiara Robles on 11/3/16.
//  Copyright © 2016 Kiara Robles. All rights reserved.
//

#import "PSEntry.h"
#include <ObjectivePGP/ObjectivePGP.h>

@implementation PSEntry

@synthesize name, path, is_dir, pass;

static NSString *GroupIdentifier = @"group.com.blockchainme.Pass";

- (NSString *)name
{
    if ([name hasSuffix:@".gpg"]) {
        return [name substringToIndex:[name length] - 4];
    }
    else {
        return name;
    }
}

- (NSString *)passWithPassphrase:(NSString *)passphrase passwordOnly:(BOOL)passwordOnly
{
    NSURL *containerURL = [[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:GroupIdentifier] URLByAppendingPathComponent:@"Library/Caches"];
    NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[containerURL path] error:nil];
    NSArray *gpgKeys = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.asc'"]];
    

    NSString *keyPrefix;
    NSString *keyExt;
    for (NSString *key in gpgKeys) {
        keyPrefix = [key stringByReplacingOccurrencesOfString:@".asc" withString:@""];
        keyExt = [NSString stringWithFormat:@"%@/%@", [containerURL path], key];
    }
    
    ObjectivePGP *pgp = [[ObjectivePGP alloc] init];
    BOOL foundKey = [pgp importKey:keyPrefix fromFile:keyExt];
    NSLog(foundKey ? @"foundKey: Yes" : @"foundKey: No");
    
    NSData *encryptedPassword = [NSData dataWithContentsOfFile:self.path];
    
    /* need provide passphrase if required */
    NSError *error = nil;
    NSString *decryptedPasswordString = nil;
    NSData *decryptedPassword = [pgp decryptData:encryptedPassword passphrase:passphrase error:&error];
    if (decryptedPassword && !error) {
        NSLog(@"decryption success: %@", decryptedPassword);
        decryptedPasswordString = [[NSString alloc] initWithData:decryptedPassword encoding:NSUTF8StringEncoding];
        NSLog(@"decryption success: %@", decryptedPasswordString);
    }
    
    return decryptedPasswordString;
}

@end
