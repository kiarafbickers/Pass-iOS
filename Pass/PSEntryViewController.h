//
//  PSEntryViewController.h
//  pass-ios
//
//  Created by Kiara Robles on 11/3/16.
//  Copyright © 2016 Kiara Robles. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PSEntry;

@interface PSEntryViewController: UITableViewController

@property(nonatomic,retain) PSEntry *entry;
@property(nonatomic,retain) UIPasteboard *pasteboard;
@property(nonatomic,assign) BOOL useTouchID;

@end
