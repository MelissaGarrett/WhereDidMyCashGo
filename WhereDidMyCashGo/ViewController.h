//
//  ViewController.h
//  WhereDidMyCashGo
//
//  Created by Melissa  Garrett on 5/4/15.
//  Copyright (c) 2015 MelissaGarrett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Transaction.h"

@interface ViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UILabel *lblMonthName;

@property (strong, nonatomic) IBOutlet UITextField *txtDescription;

@property (strong, nonatomic) IBOutlet UITextField *txtCost;

@property (strong, nonatomic) IBOutlet UILabel *lblCostFormat;

@property (strong, nonatomic) IBOutlet UILabel *lblErrorMsg;

@property (strong, nonatomic) IBOutlet UILabel *lblLastMonthTotal;

@property (strong, nonatomic) IBOutlet UILabel *lblThisMonthTotal;

@property (strong, nonatomic) Transaction *transaction;

- (IBAction)btnEnterTransaction:(UIButton *)sender;
- (IBAction)btnViewTransaction:(UIButton *)sender;
- (IBAction)btnCancel:(UIButton *)sender;
- (IBAction)btnSave:(UIButton *)sender;

@end

