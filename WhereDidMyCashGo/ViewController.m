//
//  ViewController.m
//  WhereDidMyCashGo
//
//  Created by Melissa  Garrett on 5/4/15.
//  Copyright (c) 2015 MelissaGarrett. All rights reserved.
//

#import "ViewController.h"
#import "Transaction.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Setup the paths to store data entered by user
    self.paths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
    self.documentsDirectoryPath = [self.paths objectAtIndex:0];
    self.filePath = [self.documentsDirectoryPath stringByAppendingPathComponent:@"CashData"];
    
    [self loadTransactionData];
    
    UITapGestureRecognizer *tapToDismiss = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [self.view addGestureRecognizer:tapToDismiss];
    
    [self getCurrentDate];
    
    [self getTotals];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Retrieve the transactions in permanent storage from the current month
-(void)loadTransactionData {
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.filePath])
    {
        self.arrayOfTransactions = [[NSKeyedUnarchiver unarchiveObjectWithFile:self.filePath] mutableCopy];
    }
    
    // populate TableView (displayed when user taps the View Transactions button)...
    
}

// Get current date to display current month in Navigation Bar.
// Also, use it to check for a new month, and if so, save the current month's
// spending total as the previous month's total, and reset the current month's
// total to 0.
-(void)getCurrentDate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"MMMM"];
    NSString *currentMonth = [dateFormatter stringFromDate:[NSDate date]];
    
    // compare to last active month to see if need to reset total
    
    
    self.navigationItem.title = currentMonth;
}

- (IBAction)btnEnterTransaction:(UIButton *)sender {
    self.txtDescription.hidden = NO;
    self.txtCost.hidden = NO;
    self.lblErrorMsg.text = @"";
    self.lblDollarSign.hidden = NO;
    self.lblCostFormat.hidden = NO;
    
    UIButton *cancel = (UIButton *)[self.view viewWithTag:10];
    [cancel setHidden:NO];
    
    UIButton *save = (UIButton *)[self.view viewWithTag:11];
    [save setHidden:NO];
}

- (IBAction)btnViewTransaction:(UIButton *)sender {
    
}

- (IBAction)btnCancel:(UIButton *)sender {
    self.txtDescription.text = @"";
    self.txtDescription.hidden = YES;
    self.txtCost.text = @"";
    self.txtCost.hidden = YES;
    self.lblErrorMsg.text = @"";
    self.lblDollarSign.hidden = YES;
    self.lblCostFormat.hidden = YES;
    
    UIButton *cancel = (UIButton *)[self.view viewWithTag:10];
    [cancel setHidden:YES];
    
    UIButton *save = (UIButton *)[self.view viewWithTag:11];
    [save setHidden:YES];
}

- (IBAction)btnSave:(UIButton *)sender {
    // Need these to lose focus each time Save is tapped
    // because the Error Message doesn't always clear if one of them has focus
    [self.txtDescription resignFirstResponder];
    [self.txtCost resignFirstResponder];
    
    if ([self performErrorChecking] == YES) // Have good user input
    {
        Transaction *eachTransaction = [[Transaction alloc] init];

        [eachTransaction setPurchase:self.txtDescription.text];
    
        float costEntered = [self.txtCost.text floatValue];
        [eachTransaction setCost:[NSNumber numberWithFloat:costEntered]];
    
        // Save the custom object data into a mutable array
        [self.arrayOfTransactions addObject:eachTransaction];
    
        // Save the array data into permanent storage
        [NSKeyedArchiver archiveRootObject:self.arrayOfTransactions toFile:self.filePath];
    
        // update TableView with new transaction, but don't display
    
    
        // Update this month's total on Interface
        float thisMonth = [self.lblThisMonthTotal.text floatValue];
        thisMonth += [self.txtCost.text floatValue];
        self.lblThisMonthTotal.text = [NSString stringWithFormat:@"%.2f", thisMonth];
    
        // Reset data entry fields after each successful Save
        self.txtDescription.text = @"";
        self.txtCost.text = @"";
    }
}

// Check to make sure the user entered a value in the Purchase field
// and a valid value in the Cost field
-(BOOL)performErrorChecking {
    if ([self.txtDescription.text length] == 0)
    {
        self.lblErrorMsg.text = @"Please enter a purchase.";
        return NO;
    }
    return YES;
}

// Dismiss the keyboard when user taps the Return key
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}

// Dismiss the keyboard when user taps in the background
-(void)dismissKeyboard:(id)sender {
    [self.txtDescription resignFirstResponder];
    
    [self.txtCost resignFirstResponder];
}

// Check user input:
// Description must be <=20 characters,
// Cost must be a numeric value
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.tag == 20) // Description field
    {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];

        return !([newString length] > 20);
    }
    else if (textField.tag == 21) // Cost field
    {
        NSCharacterSet *newCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
        for (int i = 0; i < [string length]; i++)
        {
            unichar c = [string characterAtIndex:i];
            if ([newCharSet characterIsMember:c])
            {
                return YES;
            }
        }
        return NO;
    }
    else
        return YES;
}

// Clear the Error Message when user begins entering data in text fields
-(void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.tag == 20 || textField.tag == 21)
    {
        self.lblErrorMsg.text = @"";
        
    }
}

// Display Last Month's and This Month's spending totals
-(void)getTotals {
    // set these as the greater of what's in storage or 0.00
    float lastMonthTotal = 0.00;
    float thisMonthTotal = 0.00;
    
    self.lblLastMonthTotal.text = [NSString stringWithFormat:@"%.2f", lastMonthTotal];
    self.lblThisMonthTotal.text = [NSString stringWithFormat:@"%.2f", thisMonthTotal];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfTransactions.count;
}

//-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//}

@end
