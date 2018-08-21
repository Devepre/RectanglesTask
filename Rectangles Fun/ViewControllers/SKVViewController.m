//
//  SKVViewController.m
//  Rectangles Fun
//
//  Created by Serhii Kyrylenko on 8/20/18.
//  Copyright © 2018 Serhii Kyrylenko. All rights reserved.
//

#import "SKVViewController.h"
#import "Rectangle.h"
#import "RectanglesStore.h"
#import "UIColor+SKVRandomColor.h"

@interface SKVViewController () <RectangleStoreDelegate>

@property(strong, nonatomic) RectanglesStore *rectanglesStore;

@property(strong, nonatomic) UIView *startPointView;
@property (weak, nonatomic) UIView *testView;
@property (assign, nonatomic) CGFloat testViewScale;
@property (assign, nonatomic) CGFloat testViewRotation;

@property (assign, nonatomic, getter=isCreatingRectangle) BOOL creatingRectangle;
@property (assign, nonatomic) CGPoint firstTapPoint;
@property (assign, nonatomic) CGPoint secondTapPoint;

@end

@implementation SKVViewController

static const CGFloat TOUCH_VIEW_FRAME_SIZE = 15;
static const NSUInteger TAG_SHIFT = 2000;

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializeGestures];
}


- (void)initializeGestures {
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tapGesture];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                   action:@selector(handleLongPress:)];
    [self.view addGestureRecognizer:longPressGesture];
    
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                       action:@selector(handleDoubleTap:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTapGesture];
    [tapGesture requireGestureRecognizerToFail:doubleTapGesture];
}


- (void)viewAddRectangle:(Rectangle *)rectangle
                 atIndex:(NSUInteger)index
                animated:(BOOL)animated {
    UIView *rectangleView = [[UIView alloc] initWithFrame:rectangle.frame];
    rectangleView.backgroundColor = rectangle.color;
    rectangleView.tag = index + TAG_SHIFT;
    [self.view addSubview:rectangleView];
    
    if (animated) {
        rectangleView.alpha = 0.f;
        // Perform animations to show rectangle smoothly
        [UIView animateWithDuration:0.3
                         animations:^{
                             rectangleView.alpha = 1.f;
                         } completion:^(BOOL finished) {
                             [self attachGesturesToView:rectangleView];
                         }];
    } else {
        [self attachGesturesToView:rectangleView];
    }
}


- (void)attachGesturesToView:(UIView *)view {
    UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotation:)];
    [view addGestureRecognizer:rotationGesture];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [view addGestureRecognizer:panGesture];
}


- (void)addStartPointViewAtPoint:(CGPoint)point {
    CGRect touchFrame = CGRectMake(point.x - TOUCH_VIEW_FRAME_SIZE / 2.f, point.y - TOUCH_VIEW_FRAME_SIZE / 2.f,
                                   TOUCH_VIEW_FRAME_SIZE, TOUCH_VIEW_FRAME_SIZE);
    self.startPointView = [[UIView alloc] initWithFrame:touchFrame];
    self.startPointView.backgroundColor = UIColor.purpleColor;
    self.startPointView.alpha = .5f;
    self.startPointView.layer.cornerRadius = TOUCH_VIEW_FRAME_SIZE / 2.f;
    [self.view addSubview:self.startPointView];
    
    // Perform animations - should be moved to separate view class
    CGAffineTransform currentTransform = CGAffineTransformMakeScale(.7f, .7f);
    CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, 1.3f, 1.3f);
    self.startPointView.transform = currentTransform;
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.startPointView.transform = newTransform;
                     }];
}


- (void)removeStartPointView {
    // Perform animations - should be moved to separate view class
    CGAffineTransform currentTransform = self.startPointView.transform;
    CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, 0.2f, 0.2f);
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.startPointView.transform = newTransform;
                     } completion:^(BOOL finished) {
                         [self.startPointView removeFromSuperview];
                         self.startPointView = nil;
                     }];
}


#pragma mark - Helper methods

- (void)bringToFrontRectangle:(Rectangle *)rectangle {
    NSUInteger tag = [self.rectanglesStore getIndexForRectangle:rectangle] + TAG_SHIFT;
    UIView *tappedRectangle = [self.view viewWithTag:tag];
    [self.view bringSubviewToFront:tappedRectangle];
}


#pragma mark - Gestures

- (void)handleTap:(UITapGestureRecognizer *)tapGesture {
    CGPoint locationInView = [tapGesture locationInView:self.view];
    NSLog(@"Tap: %@", NSStringFromCGPoint(locationInView));
    
    // tap is on top of rectangle?
    Rectangle *tappedRectangle = [self.rectanglesStore getRectangleForPoint:locationInView];
    if (tappedRectangle) {
        [self bringToFrontRectangle:tappedRectangle];
    } else { // handling creating rectangle
        if (self.isCreatingRectangle) {
            [self removeStartPointView];
            self.secondTapPoint = locationInView;
            
            [self.rectanglesStore addRectangleForStartPoint:self.firstTapPoint
                                                   endPoint:self.secondTapPoint];
        } else {
            self.firstTapPoint = locationInView;
            [self addStartPointViewAtPoint:locationInView];
        }
        
        self.creatingRectangle = !self.isCreatingRectangle;
    }
    
}


// user can change object color with long tap gesture (just apply new random color)
- (void)handleLongPress:(UILongPressGestureRecognizer *)longPressGesture {
    CGPoint locationInView = [longPressGesture locationInView:self.view];
    NSLog(@"LongPress: %@", NSStringFromCGPoint(locationInView));
    
    switch (longPressGesture.state) {
        case UIGestureRecognizerStateBegan:
            [self.rectanglesStore rectangleForPoint:locationInView
                                      changeColorTo:UIColor.randomColor];
            break;
        default:
            break;
    }

}

// user can remove object via 2 taps on object
- (void)handleDoubleTap:(UITapGestureRecognizer *)doubleTapGesture {
    CGPoint locationInView = [doubleTapGesture locationInView:self.view];
    NSLog(@"Double Tap: %@", NSStringFromCGPoint(locationInView));
    
    [self.rectanglesStore removeRectangleAtPoint:locationInView];
}


// User can rotate object
- (void)handleRotation:(UIRotationGestureRecognizer *)sender {
    static CGFloat initialRotation;
    static Rectangle *currentRectangle;
    if (sender.state == UIGestureRecognizerStateBegan) {
        initialRotation = atan2f(sender.view.transform.b, sender.view.transform.a);
        CGPoint locationInView = [sender locationInView:self.view];
        currentRectangle = [self.rectanglesStore getRectangleForPoint:locationInView];
    }
    CGFloat newRotation = initialRotation + sender.rotation;
    sender.view.transform = CGAffineTransformMakeRotation(newRotation);
    
    currentRectangle.frame = sender.view.frame;
}


// User can drag/move object
- (void)handlePan:(UIPanGestureRecognizer *)sender {
    static CGPoint locationInView;
    static Rectangle *currentRectangle;
    
    static CGPoint initialCenter;
    if (sender.state == UIGestureRecognizerStateBegan) {
        initialCenter = sender.view.center;
        locationInView = [sender locationInView:self.view];
        currentRectangle = [self.rectanglesStore getRectangleForPoint:locationInView];
    }
    CGPoint translation = [sender translationInView:sender.view.superview];
    sender.view.center = CGPointMake(initialCenter.x + translation.x, initialCenter.y + translation.y);
    
    currentRectangle.frame = sender.view.frame;
}

#pragma mark - Getters and Setters

- (RectanglesStore *)rectanglesStore {
    if (!_rectanglesStore) {
        _rectanglesStore = [[RectanglesStore alloc] init];
        _rectanglesStore.delegate = self;
    }
    return _rectanglesStore;
}


#pragma mark - RectangleStoreDelegate

- (void)addedRectangle:(Rectangle *)rectangle atIndex:(NSUInteger)index {
    [self viewAddRectangle:rectangle
                   atIndex:index
                  animated:YES];
    NSLog(@"Created rectangle is: %@", rectangle);
}


- (void)changedRectangle:(Rectangle *)rectangle atIndex:(NSUInteger)index {
    UIView *rectangleView = [self.view viewWithTag:index + TAG_SHIFT];
    [rectangleView removeFromSuperview];
    
    [self viewAddRectangle:rectangle
                   atIndex:index
                  animated:NO];
}


- (void)removedRectangle:(Rectangle *)rectangle
                 atIndex:(NSUInteger)index {
    UIView *rectangleView = [self.view viewWithTag:index + TAG_SHIFT];
    [rectangleView removeFromSuperview];
}

@end
