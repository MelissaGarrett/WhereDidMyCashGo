//
//  TransactionCell.h
//  WhereDidMyCashGo
//
//  Created by Melissa  Garrett on 9/13/15.
//  Copyright (c) 2015 MelissaGarrett. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TransactionCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *purchaseLabel;
@property (nonatomic, weak) IBOutlet UILabel *costLabel;

@end
