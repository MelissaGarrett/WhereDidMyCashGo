//
//  TableViewController.h
//  WhereDidMyCashGo
//
//  Created by Melissa  Garrett on 9/8/15.
//  Copyright (c) 2015 MelissaGarrett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Transaction.h"

@interface TableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) Transaction *transaction;

@end
