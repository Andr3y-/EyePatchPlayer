//
// UIViewController+RESideMenu.m
// RESideMenu
//
// Copyright (c) 2013-2014 Roman Efimov (https://github.com/romaonthego)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "UIViewController+RESideMenu.h"
#import "RESideMenu.h"

@implementation UIViewController (RESideMenu)

- (RESideMenu *)sideMenuViewController
{
    UIViewController *iter = self.parentViewController;
    while (iter) {
        if ([iter isKindOfClass:[RESideMenu class]]) {
            return (RESideMenu *)iter;
        } else if (iter.parentViewController && iter.parentViewController != iter) {
            iter = iter.parentViewController;
        } else {
            iter = nil;
        }
    }
    return nil;
}

-(void) drawRightMenuButton {
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_burger_menu_raw_small"] style:UIBarButtonItemStylePlain target:self action:@selector(presentRightMenuViewController:)];
    rightButton.tintColor = [UIColor blackColor];
    self.navigationItem.rightBarButtonItem = rightButton;
}
//func drawRightMenuButton() {
//    let anotherButton = UIBarButtonItem(image:UIImage(named: "icon_burger_menu_raw_small"), style:UIBarButtonItemStyle.Plain, target:self, action:"presentRightMenuViewController:")
//    anotherButton.tintColor = UIColor.blackColor()
//    self.navigationItem.rightBarButtonItem = anotherButton;
//}

#pragma mark -
#pragma mark IB Action Helper methods

- (IBAction)presentLeftMenuViewController:(id)sender
{
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (IBAction)presentRightMenuViewController:(id)sender
{
    [self.sideMenuViewController presentRightMenuViewController];
}

@end
