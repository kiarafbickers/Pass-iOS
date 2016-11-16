//
//  PSEntry.m
//  pass-ios
//
//  Created by Kiara Robles on 11/3/16.
//  Copyright © 2016 Kiara Robles. All rights reserved.
//

#include <ObjectivePGP/ObjectivePGP.h>
#import "PSEntry.h"
#import "PSPrefs.h"

@implementation PSEntry

@synthesize name, path, is_dir, pass;

- (NSString *)name
{
    if ([name hasSuffix:@".gpg"]) {
        return [name substringToIndex:[name length] - 4];
    }
    else {
        return name;
    }
}

- (NSString *)passWithPassword:(NSString *)password passwordOnly:(BOOL)passwordOnly
{
    NSURL *containerURL = [[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:groupIdentifier] URLByAppendingPathComponent:directoryLibCach];
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
    // TODO: Prompt No Key
    
    NSData *encryptedPassword = [NSData dataWithContentsOfFile:self.path];
    NSError *error = nil;
    NSString *decryptedPasswordString = nil;
    NSData *decryptedPassword = [pgp decryptData:encryptedPassword passphrase:password error:&error];
    if (decryptedPassword && !error) {
        decryptedPasswordString = [[NSString alloc] initWithData:decryptedPassword encoding:NSUTF8StringEncoding];
    }
    
    return decryptedPasswordString;
}

@end
