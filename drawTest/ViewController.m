//
//  ViewController.m
//  drawTest
//
//  Created by zhangyun on 2018/2/23.
//  Copyright © 2018年 zy. All rights reserved.
//

#import "ViewController.h"
#import "TView.h"
#import "GWWAttributeLabel.h"

@interface ViewController ()
@property (nonatomic,strong) TView *tview;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *redv = [[UIView alloc] initWithFrame:self.view.bounds];
    redv.backgroundColor = [UIColor redColor];
    [self.view addSubview:redv];
    
    TView *v = [[TView alloc] initWithFrame:CGRectMake(0,20,self.view.bounds.size.width,500)];
//    TView *v = [[TView alloc] initWithFrame:self.view.bounds];
//    v.clearsContextBeforeDrawing = NO;
    v.attributeStringPath = [[NSBundle mainBundle] pathForResource:@"Img.txt" ofType:nil];
    v.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:v];
    self.tview = v;
//
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    btn.frame = CGRectMake(100, 100, 100, 40);
//    [self.view addSubview:btn];
//
//    GWWAttributeLabel *label = [[GWWAttributeLabel alloc] initWithFrame:self.view.bounds];
//    [label setBackgroundColor:[UIColor purpleColor]];
//    [self.view addSubview:label];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //    self.backgroundColor = [UIColor blueColor];
//    CGRect frame = self.tview.frame;
//    self.tview.frame = CGRectMake(0, 0, frame.size.width/2, frame.size.height/2);
//    NSLog(@"screen frame = %@",NSStringFromCGRect([UIScreen mainScreen].bounds));
    
//    [self.tview setNeedsDisplayInRect:CGRectMake(100,100,100,100)];
//    [self.tview setNeedsDisplayInRect:self.tview.bounds];
    [self.tview setNeedsDisplay];
}
@end
