//
//  PSDataController.h
//  pass-ios
//
//  Created by Kiara Robles on 11/3/16.
//  Copyright © 2016 Kiara Robles. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PSEntry;

@interface PSDataController : NSObject

- (id)initWithPath:(NSString *)path;
- (unsigned)numEntries;
- (PSEntry *)entryAtIndex:(unsigned)index;

@end
