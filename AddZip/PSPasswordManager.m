//
//  PSPasswordManager.m
//  Pass
//
//  Created by Kiara Robles on 11/17/16.
//  Copyright © 2016 Kiara Robles. All rights reserved.
//

#import "PSPasswordManager.h"
#import "NSFileManager+PS.h"

@implementation PSPasswordManager

+ (BOOL)isKeysAtPath:(NSString *)directory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *fileList = [fileManager contentsOfDirectoryAtPath:directory error:nil];
    NSMutableArray *keyList = [[NSMutableArray alloc] init];
    
    for(NSString *file in fileList) {
        if([file hasSuffix:@".asc"]) {
            [keyList addObject:file];
            return YES;
        }
    }
    
    return NO;
}

+ (BOOL)isPasswordInAllSubDirectories:(NSString *)directory
{
    NSArray *directoryList = [[NSFileManager defaultManager] listDirectoryAtPath:directory];
    
    for (NSUInteger i = 0; i < [directoryList count]; i++) {
        NSString *file = directoryList[i];
        NSString *subDirectory = [directory stringByAppendingPathComponent:file];
        NSArray *subFileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:subDirectory error:nil];
        
        if(![subFileList[0] hasSuffix:@".gpg"]) {
            return NO;
        }
    }
    
    return YES;
}

@end
