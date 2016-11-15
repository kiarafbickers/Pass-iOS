//
//  PSDataController.m
//  pass-ios
//
//  Created by Kiara Robles on 11/3/16.
//  Copyright © 2016 Kiara Robles. All rights reserved.
//

#import "PSDataController.h"
#import "PSEntry.h"
#import <dirent.h>

@interface PSDataController ()

@property (nonatomic, copy, readwrite) NSMutableArray *entries;

- (void) readEntries:(NSString *)path;

@end

@implementation PSDataController

@synthesize entries;

- (id)initWithPath:(NSString *)path {
    if ( (self = [super init]) ) {
        [self readEntries:path];
    }
    
    return self;
}

- (void)readEntries:(NSString *)path {
    DIR *d;
    struct dirent *dent;
    PSEntry *entry;
    
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    d = opendir([path cStringUsingEncoding:NSUTF8StringEncoding]);
    if (!d) {
        // XXX handle error!
        return;
    }
    
    while ( (dent = readdir(d)) ) {
        if (dent->d_name[0] == '.') continue; // skip hidden files
        
        entry = [[PSEntry alloc] init];
        entry.name = [[NSString alloc] initWithCString:dent->d_name
                                              encoding:NSUTF8StringEncoding];
        entry.path = [NSString stringWithFormat:@"%@/%s", path, dent->d_name];
        entry.is_dir = (dent->d_type == DT_DIR ? YES : NO);
        
        [list addObject:entry];
    }
    
    self.entries = list;
}

- (unsigned) numEntries {
    return [self.entries count];
}

- (PSEntry *)entryAtIndex:(unsigned)index {
    return [self.entries objectAtIndex:index];
}

@end
