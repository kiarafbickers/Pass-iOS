//
//  PSViewController.h
//  pass-ios
//
//  Created by Kiara Robles on 11/3/16.
//  Copyright © 2016 Kiara Robles. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PSEntryManager;

@interface PSViewController : UITableViewController

@property (nonatomic, retain) PSEntryManager *entries;

@end
