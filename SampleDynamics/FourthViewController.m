//
//  FourthViewController.m
//  SampleDynamics
//
//  Created by Adam Jones on 9/27/13.
//  Copyright (c) 2013 CapTech. All rights reserved.
//

#import "FourthViewController.h"

/**
 
 The intent of this last example is to provide some insight into the memory utilization for using UIKit Dynamics.  It is
 primarily focused on collision and rotation behaviors.  Apple recommends not going overboard with collisions due to the
 impact it has on memory.  It may be true but this example shows that you can put many, many objects in motion, with many, 
 many collisions, and still have a functioning application.  In addition to testing some of the limits of Dynamics, this
 example also provides some neat visuals.  Implementing this type of mass animation before UIKit Dynamics would have been
 a little challenging.
 
 */

@interface FourthViewController ()

@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UIView *smallView;
@property (strong, nonatomic) UIDynamicAnimator *dynamicAnimator;           // dynamic animator
@property (strong, nonatomic) UIDynamicItemBehavior *dynamicItemBehavior;   // dynamic item behavior
@property (strong, nonatomic) UICollisionBehavior *collisionBehavior;       // collision behavior
@property (nonatomic) int selectedCount;                                    // # of views count
@property (nonatomic) CGFloat xVelo;
@property (nonatomic) CGFloat yVelo;

@property (strong, nonatomic) IBOutlet UIButton *toggleAnimation;
@property (strong, nonatomic) IBOutlet UISlider *sliderCount;
@property (strong, nonatomic) IBOutlet UILabel *countLabel;
@property (strong, nonatomic) IBOutlet UIButton *addCollVelo;

- (IBAction)sliderCountChanged:(UISlider *)sender;
- (IBAction)toggleAnimationHandler:(UIButton *)sender;
- (IBAction)btnAddCollVelo:(UIButton *)sender;

@end

NSString *const kStartAnimation = @"Start Animation";     // for start animation button title
NSString *const kStopAnimation = @"Stop Animation";       // for stop animation button title


#define min 0
#define max 1000

@implementation FourthViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // set the default title for the start/stop animation button
    [_toggleAnimation setTitle:kStartAnimation forState:UIControlStateNormal];
    
    _addCollVelo.hidden = YES;
    
    _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(20, 20, [[UIScreen mainScreen] applicationFrame].size.width - 40, [[UIScreen mainScreen] applicationFrame].size.height - 170)];
    [_backgroundView setBackgroundColor:[UIColor lightGrayColor]];
    [self.view addSubview:_backgroundView];
    
    _dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:_backgroundView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sliderCountChanged:(UISlider *)sender {
    _countLabel.text = [NSString stringWithFormat:@"%i", (int)roundf(sender.value)];
    _selectedCount = (int)roundf(sender.value);
}

- (IBAction)toggleAnimationHandler:(UIButton *)sender {
    
    if (sender.currentTitle == kStartAnimation) {
        [self startAnimation];
        [sender setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [sender setTitle:kStopAnimation forState:UIControlStateNormal];
        _addCollVelo.hidden = NO;
    }
    else {
        [self stopAnimation];
        [sender setTitle:kStartAnimation forState:UIControlStateNormal];
        [sender setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        _addCollVelo.hidden = YES;
    }
    
}

- (IBAction)btnAddCollVelo:(UIButton *)sender {
    
    _collisionBehavior = [[UICollisionBehavior alloc] init];
    [_collisionBehavior setTranslatesReferenceBoundsIntoBoundary:YES];
    [_collisionBehavior setCollisionMode:UICollisionBehaviorModeEverything];
    
    [_dynamicAnimator removeBehavior:_dynamicItemBehavior];
//    _dynamicItemBehavior = nil;
    
    for (UIView *vw in _backgroundView.subviews) {
        
        [_collisionBehavior addItem:vw];
        
        _dynamicItemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[vw]];
        [_dynamicItemBehavior addAngularVelocity:5.0 forItem:vw];
        [_dynamicItemBehavior setAllowsRotation:YES];
        [_dynamicItemBehavior setDensity:0.5];
        [_dynamicItemBehavior setElasticity:1.0];
        [_dynamicItemBehavior setAngularResistance:0.0];
        
        _xVelo = arc4random() % (int)roundf(50);
        _yVelo = arc4random() % (int)roundf(50);
        
        if ((int)roundf(_xVelo) % 2 == 0) {
            _xVelo = -(_xVelo);
        }
        
        if ((int)roundf(_yVelo) % 2 == 0) {
            _yVelo = -(_yVelo);
        }
        
        [_dynamicItemBehavior addLinearVelocity:CGPointMake(_xVelo, _yVelo) forItem:vw];
        
        [_dynamicAnimator addBehavior:_dynamicItemBehavior];
        
        NSLog(@"Linear Velocity x,y: %f, %f", [_dynamicItemBehavior linearVelocityForItem:vw].x, [_dynamicItemBehavior linearVelocityForItem:vw].y);
    }
    
    [_dynamicAnimator addBehavior:_collisionBehavior];
}

- (void)startAnimation {
    
    CGFloat vWidth = _backgroundView.frame.size.width - 10;
    CGFloat vHeight = _backgroundView.frame.size.height - 10;
    
    _selectedCount = (int)roundf(_sliderCount.value);
    
    for (int i = 0; i < _selectedCount; i++) {
        
        _smallView = [[UIView alloc] initWithFrame:CGRectMake(arc4random() % (int)roundf(vWidth),
                                                              arc4random() % (int)roundf(vHeight), 10, 10)];
        
        /*
         Random colorization code borrowed from https://gist.github.com/kylefox/1689973
         */
        CGFloat hue = ( arc4random() % 256 / 256.0 );               //  0.0 to 1.0
        CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
        CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
        UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
        
        [_smallView setBackgroundColor:color];
        [_backgroundView addSubview:_smallView];
        
        _dynamicItemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[_smallView]];
        [_dynamicItemBehavior addAngularVelocity:5.0 forItem:_smallView];
        [_dynamicItemBehavior setAllowsRotation:YES];
        [_dynamicItemBehavior setAngularResistance:0.0];
        
        [_dynamicAnimator addBehavior:_dynamicItemBehavior];
    }
    
}

- (void)stopAnimation {
    
    [_dynamicAnimator removeAllBehaviors];
    
    for (UIView *vw in _backgroundView.subviews) {
        
        [vw removeFromSuperview];
        
    }
    
}
@end
