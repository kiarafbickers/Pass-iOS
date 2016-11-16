//
//  PSDataController.m
//  pass-ios
//
//  Created by Kiara Robles on 11/3/16.
//  Copyright © 2016 Kiara Robles. All rights reserved.
//

#import <dirent.h>
#import "PSEntry.h"
#import "PSDataController.h"

@interface PSDataController ()

@property (nonatomic, copy, readwrite) NSMutableArray *entries;

- (void)readEntries:(NSString *)path;

@end

@implementation PSDataController

@synthesize entries;

- (instancetype)initWithPath:(NSString *)path
{
    if (self) {
        [self readEntries:path];
    }
    return self;
}

- (void)readEntries:(NSString *)path
{
    DIR *openDirectory;
    struct dirent *dirEntry; // Instance of an entry inside of a directory on the filesystem
    PSEntry *entry;
    
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    openDirectory = opendir([path cStringUsingEncoding:NSUTF8StringEncoding]);
    if (!openDirectory) {
        // TODO: Handle error
        return;
    }
    
    while ( (dirEntry = readdir(openDirectory)) ) {
        if (dirEntry->d_name[0] == '.') continue; // Skip hidden files
        
        entry = [[PSEntry alloc] init];
        entry.name = [[NSString alloc] initWithCString:dirEntry->d_name encoding:NSUTF8StringEncoding];
        entry.path = [NSString stringWithFormat:@"%@/%s", path, dirEntry->d_name];
        entry.is_dir = (dirEntry->d_type == DT_DIR ? YES : NO);
        
        [list addObject:entry];
    }
    
    self.entries = list;
}

- (NSUInteger)numEntries
{
    return (unsigned int)[self.entries count];
}

- (PSEntry *)entryAtIndex:(NSUInteger)index
{
    return [self.entries objectAtIndex:index];
}

@end
