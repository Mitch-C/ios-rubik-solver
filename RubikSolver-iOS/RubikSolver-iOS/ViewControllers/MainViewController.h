//
//  ViewController.h
//  RubikSolver-iOS
//
//  Created by rhcpfan on 15/01/17.
//  Copyright © 2017 HomeApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController


@property (weak, nonatomic) IBOutlet UIButton *startButton;


- (IBAction)didPressStartButton:(UIButton *)sender;

@end

