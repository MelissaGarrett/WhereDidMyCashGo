//
//  ViewController.m
//  WhereDidMyCashGo
//
//  Created by Melissa  Garrett on 5/4/15.
//  Copyright (c) 2015 MelissaGarrett. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "MonthlyDataManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    // Access data in Singleton (MonthlyDataManager)
    MonthlyDataManager *monthlyData = [MonthlyDataManager sharedManager];
    
    // Setup the paths to save data entered by user
    [delegate setPaths:NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES)];
    [delegate setDocumentsDirectoryPath:[[delegate paths] objectAtIndex:0]];
    [delegate setFilePath:[[delegate documentsDirectoryPath] stringByAppendingPathComponent:@"CashData"]];
    
    UITapGestureRecognizer *tapToDismiss = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [[self view] addGestureRecognizer:tapToDismiss];
    
    // Check if app has run once
    static NSString * const hasAppRunOnceKey = @"hasAppRunOnceKey";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults boolForKey:hasAppRunOnceKey] == NO) {
        [defaults setBool:YES forKey:hasAppRunOnceKey];
    }
    

    [monthlyData loadDataFromStorage];
    
    [self displayCurrentDate];
    
    [monthlyData checkIfNewMonth];
    
    [self displayTotals];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Display Current Month in Navigation Bar.
-(void)displayCurrentDate {
    MonthlyDataManager *monthlyData = [MonthlyDataManager sharedManager];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"MMMM"];
    [monthlyData setCurrentMonth:[dateFormatter stringFromDate:[NSDate date]]];
    self.navigationItem.title = [monthlyData currentMonth];
}

// Display Last Month's and This Month's spending totals
-(void)displayTotals {
    MonthlyDataManager *monthlyData = [MonthlyDataManager sharedManager];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setPositiveFormat:@"###0.##"];
    
    NSString *formattedLastMonthString = [numberFormatter stringFromNumber:[monthlyData lastMonthTotal]];
    float formattedLastMonth = [formattedLastMonthString floatValue];
    _lblLastMonthTotal.text = [NSString stringWithFormat:@"%.2f", formattedLastMonth];
    
    NSString *formattedCurrentMonthString = [numberFormatter stringFromNumber:[monthlyData currentMonthTotal]];
    float formattedCurrentMonth = [formattedCurrentMonthString floatValue];
    _lblThisMonthTotal.text = [NSString stringWithFormat:@"%.2f", formattedCurrentMonth];
}

- (IBAction)btnEnterTransaction:(UIButton *)sender {
    _txtDescription.hidden = NO;
    _txtCost.hidden = NO;
    _lblErrorMsg.text = @"";
    _lblDollarSign.hidden = NO;
    _lblCostFormat.hidden = NO;
    
    UIButton *cancel = (UIButton *)[[self view] viewWithTag:10];
    [cancel setHidden:NO];
    
    UIButton *save = (UIButton *)[[self view] viewWithTag:11];
    [save setHidden:NO];
}

- (IBAction)btnViewTransaction:(UIButton *)sender {
}

- (IBAction)btnCancel:(UIButton *)sender {
    _txtDescription.text = @"";
    _txtDescription.hidden = YES;
    _txtCost.text = @"";
    _txtCost.hidden = YES;
    _lblErrorMsg.text = @"";
    _lblDollarSign.hidden = YES;
    _lblCostFormat.hidden = YES;
    
    UIButton *cancel = (UIButton *)[[self view] viewWithTag:10];
    [cancel setHidden:YES];
    
    UIButton *save = (UIButton *)[[self view] viewWithTag:11];
    [save setHidden:YES];
}

- (IBAction)btnSave:(UIButton *)sender {
    MonthlyDataManager *monthlyData = [MonthlyDataManager sharedManager];
    
    // Need these to lose focus each time Save is tapped
    // because the Error Message doesn't always clear if one of them has focus
    [_txtDescription resignFirstResponder];
    [_txtCost resignFirstResponder];
    
    if ([self performErrorChecking] == YES) // Have good user input
    {
        _transaction = [[Transaction alloc] init];

        [_transaction setPurchase:_txtDescription.text];
    
        // Convert the Cost entered to an NSNumber so you can use NSNumberFormatter
        NSNumber *costEntered = @([_txtCost.text floatValue]);
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setPositiveFormat:@"###0.##"];
        NSString *formattedNumberString = [numberFormatter stringFromNumber:costEntered];
        
        // Convert the formatted String to NSNumber type for storage
        NSNumber *formattedCost = @([formattedNumberString floatValue]);
        [_transaction setCost:formattedCost];
    
        // Save the custom object data into a mutable array
        [[monthlyData arrayOfTransactions] addObject:_transaction];
    
        // Get Cost and add to CurrentMonthTotal
        float transactionCost = [_txtCost.text floatValue];
        float currentTotal = [[monthlyData currentMonthTotal] floatValue];
        
        currentTotal += transactionCost;
        _lblThisMonthTotal.text = [NSString stringWithFormat:@"%.2f", currentTotal];

        [monthlyData setCurrentMonthTotal:@(currentTotal)];
        
        // Reset data entry fields after each successful Save
        _txtDescription.text = @"";
        _txtCost.text = @"";
    }
}

// Check to make sure the user entered a value in the Purchase field
// and a valid value in the Cost field
-(BOOL)performErrorChecking {
    float costEntered = [_txtCost.text floatValue];
    
    if ([_txtDescription.text length] == 0 ||
        (costEntered <= 0.00))
    {
        _lblErrorMsg.text = @"Please enter both a purchase and valid cost.";
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
    [_txtDescription resignFirstResponder];
    
    [_txtCost resignFirstResponder];
}

// Check user input:
// Description must be <=20 characters;
// Cost must be a numeric value
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.tag == 20) // Description field
    {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];

        return !([newString length] > 20);
    }
    
    if (textField.tag == 21) // Cost field
    {
        // User can use the backspace key
        if ([string isEqualToString:@""])
            return YES;
        
        // User can only enter numbers and one decimal
        NSCharacterSet *newCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
        
        for (int i = 0; i < [string length]; i++)
        {
            unichar c = [string characterAtIndex:i];
            if ([newCharSet characterIsMember:c])
            {
                NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
                NSArray *decimals = [newString componentsSeparatedByString:@"."];
                return !([decimals count] > 2);
            }
        }
        return NO;
    }
    else
        return NO;
}

// Clear the Error Message when user begins entering data in text fields
-(void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.tag == 20 || textField.tag == 21)
    {
        _lblErrorMsg.text = @"";
    }
}

@end
