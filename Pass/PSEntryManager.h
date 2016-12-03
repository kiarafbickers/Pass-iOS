//
//  PSEntryManager.h
//  pass-ios
//
//  Created by Kiara Robles on 11/3/16.
//  Copyright © 2016 Kiara Robles. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PSEntry;

@interface PSEntryManager : NSObject

@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSMutableArray *entries;

- (instancetype)initWithPath:(NSString *)path;

@end
