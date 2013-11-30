//
//  EHTapGestureRecognizer.m
//  EHTapGestureRecognizer
//
//  Copyright (c) 2013 Edward Huynh
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "EHTapGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface EHTapGestureRecognizer ()

/// timer that fails the gesture after it's time has elapsed
@property (nonatomic, strong) NSTimer *failGestureTimer;

@end

static CGFloat defaultWaitTime = 0.0f;

@implementation EHTapGestureRecognizer

- (id)initWithTarget:(id)target action:(SEL)action
{
    self = [super initWithTarget:target action:action];
    
    if (self)
    {
        self.failGestureTimer = nil;
        self.waitTime = defaultWaitTime;
        self.numberOfTapsRequired = 1;
    }
    
    return self;
}

#pragma mark - UIGestureRecognizer

- (void)reset
{
    [self.failGestureTimer invalidate];
    self.failGestureTimer = nil;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    if (![self isTimerRunning])
    {
        [self fireTimer];
    }
    
    [self updateGestureStateWithTouch:[[touches allObjects] firstObject]];
}

#pragma mark - tap processing

- (void)updateGestureStateWithTouch:(UITouch *)touch
{
    if (touch.tapCount == self.numberOfTapsRequired)
    {
        [self.failGestureTimer invalidate];
        self.state = UIGestureRecognizerStateRecognized;
    }
}

- (void)setNumberOfTapsRequired:(NSUInteger)numberOfTapsRequired
{
    _numberOfTapsRequired = numberOfTapsRequired;
    
    // no wait time is required if the number of taps required is 1
    if (numberOfTapsRequired > 1 && ![self hasWaitTimeBeenSet])
    {
        [self calculateReasonableWaitTimeForNumberOfTaps:numberOfTapsRequired];
    }
}

#pragma mark - Timer handling

- (void)fireTimer
{
    self.failGestureTimer = [NSTimer scheduledTimerWithTimeInterval:self.waitTime
                                                             target:self
                                                           selector:@selector(failGesture)
                                                           userInfo:nil
                                                            repeats:NO];
}

- (BOOL)isTimerRunning
{
    return self.failGestureTimer && self.failGestureTimer.isValid;
}

- (void)failGesture
{
    self.state = UIGestureRecognizerStateFailed;
}

#pragma mark - wait time

- (BOOL)hasWaitTimeBeenSet
{
    return self.waitTime != defaultWaitTime;
}

- (void)calculateReasonableWaitTimeForNumberOfTaps:(NSInteger)numberOfTaps
{
    static CGFloat reasonableWaitTimePerTap = 0.1f;
    
    self.waitTime = reasonableWaitTimePerTap * numberOfTaps;
}

@end
