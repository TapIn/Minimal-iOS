//
//  SignUpViewController.h
//  TapIn2.0
//
//  Created by Vu Tran on 11/3/12.
//  Copyright (c) 2012 Vu Tran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignUpViewController : UIViewController
{
    IBOutlet UITextField * firstname;
    IBOutlet UITextField * lastname;
    IBOutlet UITextField * pass;
    IBOutlet UIButton * submit;
}
-(IBAction)submitButtonTapped:(id)sender;
@end
