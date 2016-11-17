//
//  PSPasswordManager.h
//  Pass
//
//  Created by Kiara Robles on 11/17/16.
//  Copyright © 2016 Kiara Robles. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSPasswordManager : NSObject

+ (BOOL)isKeysAtPath:(NSString *)directory;
+ (BOOL)isPasswordInAllSubDirectories:(NSString *)directory;

@end
