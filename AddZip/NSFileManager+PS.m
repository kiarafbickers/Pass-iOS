//
//  NSFileManager+PS.m
//  Pass
//
//  Created by Kiara Robles on 11/17/16.
//  Copyright © 2016 Kiara Robles. All rights reserved.
//

#import "NSFileManager+PS.h"

@implementation NSFileManager (PS)

- (NSArray *)listDirectoryAtPath:(NSString *)directory
{
    NSArray *fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directory error:nil];
    NSMutableArray *directoryList = [[NSMutableArray alloc] init];
    
    for(NSString *file in fileList) {
        NSString *path = [directory stringByAppendingPathComponent:file];
        BOOL isDirectory = NO;
        [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:(&isDirectory)];
        if(isDirectory) {
            [directoryList addObject:file];
        }
    }
    
    return directoryList;
}

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
