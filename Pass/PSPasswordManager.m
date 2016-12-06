//
//  PSPasswordManager.m
//  Pass
//
//  Created by Kiara Robles on 11/17/16.
//  Copyright © 2016 Kiara Robles. All rights reserved.
//

#import <Valet/Valet.h>
#import "PSPasswordManager.h"
#import "NSFileManager+PS.h"

@implementation PSPasswordManager

+ (BOOL)isKeysAtPath:(NSString *)directory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *fileList = [fileManager contentsOfDirectoryAtPath:directory error:nil];
    NSMutableArray *keyList = [[NSMutableArray alloc] init];
    
    for(NSString *file in fileList) {
        if([file hasSuffix:@".asc"] || [file hasSuffix:@".gpg"]) {
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

+ (NSMutableArray *)keysAtPath:(NSString *)directory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *fileList = [fileManager contentsOfDirectoryAtPath:directory error:nil];
    NSMutableArray *keyList = [[NSMutableArray alloc] init];
    
    for(NSString *file in fileList) {
        if([file hasSuffix:@".asc"] || [file hasSuffix:@".gpg"]) {
            [keyList addObject:file];
        }
    }
    
    return keyList;
}

+ (void)deleteKeysAtPath:(NSString *)directory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableArray *fileList = [[fileManager contentsOfDirectoryAtPath:directory error:nil] mutableCopy];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];

    for(NSString *filename in fileList) {
        if([filename hasSuffix:@".asc"]) {
            
            NSString *filePath = [documentsPath stringByAppendingPathComponent:filename];
            
            NSError *error;
            BOOL success = [fileManager removeItemAtPath:filePath error:&error];
            if (success) {
                NSLog(@"deleted file -:%@ ", filePath);
            }
            else {
                NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
            }
        }
    }
}

@end
