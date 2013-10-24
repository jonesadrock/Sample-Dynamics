//
//  FirstViewController.m
//  SampleDynamics
//
//  Created by Adam Jones on 9/20/13.
//  Copyright (c) 2013 CapTech. All rights reserved.
//

#import "FirstViewController.h"

/**
 
 The first tab in this sample application provides a way to configure the primary behaviors in
 UIKit Dynamics.  While not every possible property is availabe through the configuration pane,
 it is simple enough to experiment by modifying this file.
 
 There are 5 UIView objects that represent a set of dynamic items.  Not all are used in every
 sample behavior.  Following is an overview of each behavior:
 
 1. Gravity
 The on/off switch defaults to ON, while the others default to OFF.  Use the x and y values to 
 set the gravity vector.  Remember that a negative value for x or y will define a gravity vector
 left and up, respectively.
 
 2. Collision
 This behavior defaults with all dynamic items added and a boundary that is defined by the 
 reference view of the dynamic animator.  The only configuration option is for the collision
 behavior mode, which can be either between dynamic items only, boundaries only, everything 
 (items and boundaries), or no collision behavior.  Setting the mode to none effectively removes
 the collision behavior from the animator.
 
 3. Push
 You can configure the push vector, defined by x and y values.  In addition, you also define 
 the push mode, either continuous or instantaneous.  The interaction when both gravity and push
 behaviors are added is interesting and it depends on the magnitude of the push vector.  If you
 experiment with theses two behaviors, setting the y values in opposing directions, you may 
 notice that gravity overpowers push in continuous mode, whereas push will take initial control
 in instantaneous mode.  Again, it depends on the magnitudes of the defined vectors.
 
 4. Snap
 The snap behavior is defined by a snap-to point, configured with x and y values.  This represents
 a point within the reference view that a dynamic item will 'snap to.'  The damping value is a range
 between 0 and 1, with 0 being no damping at all.  The lower the damping, the more oscillation you'll 
 see when the item snaps into place.
 
 5. Attachment
 An attachment is defined by one of two options: attach to an anchor point or to other items.  It is 
 possible to define multiple attachments so you can end up with a hybrid interaction between both 
 options.  If you select to attach to an anchor point, there are x and y values that represent a 
 point within the reference view.  If you select 'to items' this behavior will default to a series
 of item attachments, with each dynamic item attaching to another.  The result is a train-like effect
 with each item following the item it's attached to.
 
 Tap the Start Dynamic button to add your configured behaviors to the dynamic animator.  Tapping Stop
 Dynamics will remove all behaviors and reset the layout, moving all dynamic items back into 
 starting position.
 
 Show and Hide Settings display and close the configuration pane.
 
 The relevant behavior configuration code lies within the startDynamics method. You'll notice that 
 there is a lot of setup code, in particular things like multiple properties for defining the various
 behaviors.  There are also many outlets due to the nature of this example, to provide functionality
 for the numerous controls on the configuration pane.
 
 */

@interface FirstViewController ()

// properties
// animator and behaviors
@property (strong, nonatomic) UIDynamicAnimator *dynamicAnimator;       // dynamic animator
@property (strong, nonatomic) UIGravityBehavior *gravityBehavior;       // gravity behavior
@property (strong, nonatomic) UICollisionBehavior *collisionBehavior;   // collision behavior
@property (strong, nonatomic) UIPushBehavior *pushBehavior;             // push behavior
@property (strong, nonatomic) UISnapBehavior *snapBehavior;             // snap behavior
@property (strong, nonatomic) UIAttachmentBehavior *attachmentBehavior;  // attachment behavior
@property (strong, nonatomic) UIAttachmentBehavior *attachmentBehavior2;  // attachment behavior
@property (strong, nonatomic) UIAttachmentBehavior *attachmentBehavior3;  // attachment behavior
@property (strong, nonatomic) UIAttachmentBehavior *attachmentBehavior4;  // attachment behavior
// for resetting view positions
@property CGRect view1Frame;     // view1 frame
@property CGRect view2Frame;     // view2 frame
@property CGRect view3Frame;     // view3 frame
@property CGRect view4Frame;     // view4 frame
@property CGRect view5Frame;     // view5 frame

// outlets
// general
@property (strong, nonatomic) IBOutlet UIView *refView;                     // reference view
@property (strong, nonatomic) IBOutlet UIView *settingsPane;                // settings pane
@property (strong, nonatomic) IBOutlet UIView *view1;                       // view1 - dynamic item
@property (strong, nonatomic) IBOutlet UIView *view2;                       // view2 - dynamic item
@property (strong, nonatomic) IBOutlet UIView *view3;                       // view3 - dynamic item
@property (strong, nonatomic) IBOutlet UIView *view4;                       // view4 - dynamic item
@property (strong, nonatomic) IBOutlet UIView *view5;                       // view5 - dynamic item
@property (strong, nonatomic) IBOutlet UIButton *toggleButton;              // start/stop dynamics
// gravity settings
@property (strong, nonatomic) IBOutlet UISwitch *gravityToggle;             // gravity on/off
@property (strong, nonatomic) IBOutlet UISlider *gravityX;                  // gravity x value
@property (strong, nonatomic) IBOutlet UISlider *gravityY;                  // gravity y value
@property (strong, nonatomic) IBOutlet UILabel *gravityXValue;              // gravity x value label
@property (strong, nonatomic) IBOutlet UILabel *gravityYValue;              // gravity y value label
// collision mode settings
@property (strong, nonatomic) IBOutlet UISegmentedControl *collisionMode;   // collision mode selection
// push settings
@property (strong, nonatomic) IBOutlet UISwitch *pushToggle;                // push on/off
@property (strong, nonatomic) IBOutlet UISlider *pushX;                     // push x value
@property (strong, nonatomic) IBOutlet UISlider *pushY;                     // push y value
@property (strong, nonatomic) IBOutlet UISegmentedControl *pushMode;        // push mode selection
@property (strong, nonatomic) IBOutlet UILabel *pushXValue;                 // push x value label
@property (strong, nonatomic) IBOutlet UILabel *pushYValue;                 // push y value label
// snap settings
@property (strong, nonatomic) IBOutlet UISwitch *snapToggle;                // snap on/off
@property (strong, nonatomic) IBOutlet UISlider *snapX;                     // snap x value
@property (strong, nonatomic) IBOutlet UISlider *snapY;                     // snap y value
@property (strong, nonatomic) IBOutlet UISlider *snapDamping;               // snap damping
@property (strong, nonatomic) IBOutlet UILabel *snapDampingValue;           // snap damping value label
@property (strong, nonatomic) IBOutlet UILabel *snapXValue;                 // snap x value label
@property (strong, nonatomic) IBOutlet UILabel *snapYValue;                 // snap y value label
// attachment settings
@property (strong, nonatomic) IBOutlet UISwitch *attachToggle;              // attachment on/off
@property (strong, nonatomic) IBOutlet UISegmentedControl *attachType;      // attachment type selection
@property (strong, nonatomic) IBOutlet UISlider *attachX;                   // attachment x value
@property (strong, nonatomic) IBOutlet UISlider *attachY;                   // attachment y value
@property (strong, nonatomic) IBOutlet UILabel *attachXValue;               // attachment x value label
@property (strong, nonatomic) IBOutlet UILabel *attachYValue;               // attachment y value label

// actions
- (IBAction)toggleDynamics:(UIButton *)sender;          // turn dynamics on/off
- (IBAction)hideSettings:(UIButton *)sender;            // hide settings pane
- (IBAction)showSettings:(UIButton *)sender;            // show settings pane
- (IBAction)gravityXChanged:(UISlider *)sender;         // set gravity x value
- (IBAction)gravityYChanged:(UISlider *)sender;         // set gravity y value
- (IBAction)pushXChanged:(UISlider *)sender;            // set push x value
- (IBAction)pushYChanged:(UISlider *)sender;            // set push y value
- (IBAction)snapDampingChanged:(UISlider *)sender;      // set snap damping value
- (IBAction)snapXChanged:(UISlider *)sender;            // set snap x value
- (IBAction)snapYChanged:(UISlider *)sender;            // set snap y value
- (IBAction)attachXChanged:(UISlider *)sender;          // set attachment x value
- (IBAction)attachYChanged:(UISlider *)sender;          // set attachment y value


@end

NSString *const kStartDynamics = @"Start Dynamics";     // for start dynamics button title
NSString *const kStopDynamics = @"Stop Dynamics";       // for stop dynamics button title

@implementation FirstViewController

#pragma mark - Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // save the dynamic item positions so we can reset their positions
    _view1Frame = _view1.frame;
    _view2Frame = _view2.frame;
    _view3Frame = _view3.frame;
    _view4Frame = _view4.frame;
    _view5Frame = _view5.frame;
    
    // init and set the reference view for the dynamic animator
    _dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.refView];
    
    // set the default title for the start/stop dynamics button
    [_toggleButton setTitle:kStartDynamics forState:UIControlStateNormal];
    
    
    CGFloat refViewHeight = _refView.frame.size.height;
    CGFloat refViewWidth = _refView.frame.size.width;
    
    // set the slider values for snap behavior 'snap-to-point' x and y values
    [_snapX setMinimumValue:0];
    [_snapX setMaximumValue:refViewWidth];
    [_snapX setValue:(refViewWidth)/2];
    [_snapY setMinimumValue:0];
    [_snapY setMaximumValue:refViewHeight];
    [_snapY setValue:(refViewHeight)/2];
    // set the initial snap slider label values
    _snapXValue.text = [NSString stringWithFormat:@"%.02f", _snapX.value];
    _snapYValue.text = [NSString stringWithFormat:@"%.02f", _snapY.value];
    
    // set the slider values for attachment anchor point x and y values
    [_attachX setMinimumValue:0];
    [_attachX setMaximumValue:refViewWidth];
    [_attachX setValue:(refViewWidth)/2];
    [_attachY setMinimumValue:0];
    [_attachY setMaximumValue:refViewHeight];
    [_attachY setValue:(refViewHeight)/2];
    // set the initial attachment anchor point slider label values
    _attachXValue.text = [NSString stringWithFormat:@"%.02f", _attachX.value];
    _attachYValue.text = [NSString stringWithFormat:@"%.02f", _attachY.value];
    
}

// when the view first loads, position our settings pane off-screen
- (void)viewDidLayoutSubviews {
    // initial position of settings pane is offscreen
    CGRect newFrame = _settingsPane.frame;
    newFrame.origin.x = [[UIScreen mainScreen] applicationFrame].origin.x;
    newFrame.origin.y = [[UIScreen mainScreen] applicationFrame].size.height;
    _settingsPane.frame = newFrame;
}


#pragma mark - Actions
// toggle start/stop dynamics button text
- (IBAction)toggleDynamics:(UIButton *)sender {
    if (sender.currentTitle == kStartDynamics) {
        [self startDynamics];
        [sender setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [sender setTitle:kStopDynamics forState:UIControlStateNormal];
    }
    else {
        [self stopDynamics];
        [sender setTitle:kStartDynamics forState:UIControlStateNormal];
        [sender setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    }
}

// hide the settings pane
- (IBAction)hideSettings:(UIButton *)sender {
    [UIView animateWithDuration:0.5f
                     animations:^{
                         CGRect newFrame = _settingsPane.frame;
                         newFrame.origin.x = [[UIScreen mainScreen] applicationFrame].origin.x;
                         newFrame.origin.y = [[UIScreen mainScreen] applicationFrame].size.height;
                         _settingsPane.frame = newFrame;
                     }
                     completion:^(BOOL finished){
                     }
     ];
}

// show the settings pane
- (IBAction)showSettings:(UIButton *)sender {
    [UIView animateWithDuration:0.5f
                     animations:^{
                         CGRect newFrame = _settingsPane.frame;
                         newFrame.origin.x = 0.0f;
                         newFrame.origin.y = 0.0f;
                         _settingsPane.frame = newFrame;
                     }
                     completion:^(BOOL finished){
                     }
     ];
}

// get the gravity direction x value when the slider changes
- (IBAction)gravityXChanged:(UISlider *)sender {
    _gravityXValue.text = [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"%.02f", (sender.value)/10]];
}
// get the gravity direction y value when the slider changes
- (IBAction)gravityYChanged:(UISlider *)sender {
    _gravityYValue.text = [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"%.02f", (sender.value)/10]];
}
// get the push direction x value when the slider changes
- (IBAction)pushXChanged:(UISlider *)sender {
    _pushXValue.text = [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"%.02f", (sender.value)/10]];
}
// get the push direction y value when the slider changes
- (IBAction)pushYChanged:(UISlider *)sender {
    _pushYValue.text = [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"%.02f", (sender.value)/10]];
}
// get the snap damping value when the slider changes
- (IBAction)snapDampingChanged:(UISlider *)sender {
    _snapDampingValue.text = [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"%.02f", (sender.value)/10]];
}
// get the snap to point x value when the slider changes
- (IBAction)snapXChanged:(UISlider *)sender {
    _snapXValue.text = [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"%.02f", sender.value]];
}
// get the snap to point y value when the slider changes
- (IBAction)snapYChanged:(UISlider *)sender {
    _snapYValue.text = [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"%.02f", sender.value]];
}
// get the attachment anchor point x value when the slider changes
- (IBAction)attachXChanged:(UISlider *)sender {
    _attachXValue.text = [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"%.02f", sender.value]];
}
// get the attachment anchor point y value when the slider changes
- (IBAction)attachYChanged:(UISlider *)sender {
    _attachYValue.text = [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"%.02f", sender.value]];
}


#pragma mark - Private
- (void)startDynamics {
    
    //
    // gravity behavior settings
    //
    if (_gravityToggle.isOn) {
       
        if (!_gravityBehavior) {
            // init gravity behavior
            _gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[_view1, _view2, _view3, _view4, _view5]];
        }
        
        // set x and y values for gravity direction
        [_gravityBehavior setGravityDirection:CGVectorMake(_gravityX.value/10, _gravityY.value/10)];
        [_dynamicAnimator addBehavior:_gravityBehavior];
    }
    else {
        [_dynamicAnimator removeBehavior:_gravityBehavior];
        _gravityBehavior = nil;
    }
    
    //
    // collision behavior settings
    //
    if (!_collisionBehavior) {
        // init collision behavior
        _collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[_view1, _view2, _view3, _view4, _view5]];
        // set collision reference bounds as the boundary
        [_collisionBehavior setTranslatesReferenceBoundsIntoBoundary:YES];
    }

    // set collision mode behavior
    switch (_collisionMode.selectedSegmentIndex) {
        case 0:  // to items only
            [_collisionBehavior setCollisionMode:UICollisionBehaviorModeItems];
            [_dynamicAnimator addBehavior:_collisionBehavior];
            break;
        case 1:  // to only boundaries
            [_collisionBehavior setCollisionMode:UICollisionBehaviorModeBoundaries];
            [_dynamicAnimator addBehavior:_collisionBehavior];
            break;
        case 2:  // to both items and boundaries
            [_collisionBehavior setCollisionMode:UICollisionBehaviorModeEverything];
            [_dynamicAnimator addBehavior:_collisionBehavior];
            break;
        case 3:  // to no collision behavior -> remove the behavior
            [_dynamicAnimator removeBehavior:_collisionBehavior];
            _collisionBehavior = nil;
            break;
        default:
            break;
    }
    
    //
    // push behavior settings
    //
    if (_pushToggle.isOn) {
        
        _pushBehavior = nil;
        
        // set push mode and init the behavior
        switch (_pushMode.selectedSegmentIndex) {
            case 0:  // to continuous
                _pushBehavior = [[UIPushBehavior alloc] initWithItems:@[_view1, _view2, _view3] mode:UIPushBehaviorModeContinuous];
                break;
            case 1:  // to instantaneous
                _pushBehavior = [[UIPushBehavior alloc] initWithItems:@[_view1, _view2, _view3] mode:UIPushBehaviorModeInstantaneous];
            default:
                break;
        }
        
        // set the push direction vector, x and y values
        [_pushBehavior setPushDirection:CGVectorMake(_pushX.value/10, _pushY.value/10)];
        [_dynamicAnimator addBehavior:_pushBehavior];
    }
    else {
        [_dynamicAnimator removeBehavior:_pushBehavior];
        _pushBehavior = nil;
    }
    
    //
    // snap behavior settings
    //
    if (_snapToggle.isOn) {
        
        _snapBehavior = nil;
        
        // init the snap behavior with x and y 'snap-to-point' values
        _snapBehavior = [[UISnapBehavior alloc] initWithItem:_view1 snapToPoint:CGPointMake(_snapX.value, _snapY.value)];
        // set the damping
        [_snapBehavior setDamping:_snapDamping.value/10];
        [_dynamicAnimator addBehavior:_snapBehavior];
    }
    else {
        [_dynamicAnimator removeBehavior:_snapBehavior];
        _snapBehavior = nil;
    }
    
    //
    // attachment behavior settings
    //
    if (_attachToggle.isOn) {
        
        _attachmentBehavior = nil;
        
        // set attachment type
        switch (_attachType.selectedSegmentIndex) {
            case 0:  // attach to anchor point
                // init behavior and set x and y anchor point values
                _attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:_view1 attachedToAnchor:CGPointMake(_attachX.value, _attachY.value)];
                
                break;
            case 1:  // attach to other item(s)
                // init multiple attachment behaviors so we can attach multiple items (the effect is cooler)
                _attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:_view5 attachedToItem:_view4];
                _attachmentBehavior2 = [[UIAttachmentBehavior alloc] initWithItem:_view4 attachedToItem:_view3];
                _attachmentBehavior3 = [[UIAttachmentBehavior alloc] initWithItem:_view3 attachedToItem:_view2];
                _attachmentBehavior4 = [[UIAttachmentBehavior alloc] initWithItem:_view2 attachedToItem:_view1];
                                
                // add 3 of the behaviors
                [_dynamicAnimator addBehavior:_attachmentBehavior2];
                [_dynamicAnimator addBehavior:_attachmentBehavior3];
                [_dynamicAnimator addBehavior:_attachmentBehavior4];
                
                // if gravity is also turned on, which it should be to get the 'cool' item-to-item effect,
                // let's reassign to a single dynamic item.  This way, when the single items is influenced
                // by the gravity, the rest of the items will follow like a train
                if (_gravityToggle.isOn) {
                    
                    if (_gravityBehavior) {
                        // first remove the behavior from the animator
                        [_dynamicAnimator removeBehavior:_gravityBehavior];
                        _gravityBehavior = nil;
                        // init a new gravity behavior with a single item
                        _gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[_view1]];
                    }
                    
                    // set x and y values for the gravity vector
                    [_gravityBehavior setGravityDirection:CGVectorMake(_gravityX.value/10, _gravityY.value/10)];
                    [_dynamicAnimator addBehavior:_gravityBehavior];
                }
            default:
                break;
        }
        
        // add this behavior here since it's added for either of the available attachment types
        [_dynamicAnimator addBehavior:_attachmentBehavior];
    }
    else {
        [_dynamicAnimator removeBehavior:_attachmentBehavior];
        _attachmentBehavior = nil;
    }
    
}

// stop the dynamics from executing and reset all the items
- (void)stopDynamics {
    
    // remove all dynamic animator behaviors
    [_dynamicAnimator removeAllBehaviors];
    
    // reset the dynamic items views to their original positions
    [UIView animateWithDuration:0.5f
                     animations:^{
                         _view1.frame = _view1Frame;
                         _view2.frame = _view2Frame;
                         _view3.frame = _view3Frame;
                         _view4.frame = _view4Frame;
                         _view5.frame = _view5Frame;
                     }
                     completion:^(BOOL finished){
                     }
     ];
    
}


@end
