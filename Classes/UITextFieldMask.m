//
//  UITextFieldMask.m
//  NSStringMask
//
//  Created by Flávio Caetano on 5/3/13.
//  Copyright (c) 2013 Flavio Caetano. All rights reserved.
//

#import "UITextFieldMask.h"

@interface UITextFieldMask ()

/**
 *  The user defined `UITextFieldDelegate`.
 */
@property (nonatomic, strong) id<UITextFieldDelegate> _extension;

@end

@implementation UITextFieldMask

// An adapter of UITextFieldDelegate to easily integrate with NSStringMask.
- (instancetype)initWithMask:(NSStringMask *)mask
{
    self = [super init];
    if (self)
    {
        self.mask = mask;
    }
    return self;
}

#pragma mark - Properties

- (void)setDelegate:(id<UITextFieldDelegate>)delegate
{
    self._extension = delegate;
}

- (void)setMask:(NSStringMask *)mask
{
    _mask = mask;
    
    [super setDelegate:(mask ? self : self._extension)];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([self._extension respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)] &&
        ! [self._extension textField:textField shouldChangeCharactersInRange:range replacementString:string])
    {
        return NO;
    }
    
    NSString *mutableString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    NSString *clean = [self.mask validCharactersForString:mutableString];
    
    mutableString = [self.mask format:mutableString];
    
    NSRange newRange = NSMakeRange(0, 0);
    
    if (clean.length > 0)
    {
        newRange = [mutableString rangeOfString:[clean substringFromIndex:clean.length-1] options:NSBackwardsSearch];
        if (newRange.location == NSNotFound)
        {
            newRange.location = mutableString.length;
        }
        else
        {
            newRange.location += newRange.length;
        }
    } else {
        newRange = [mutableString rangeOfString:self.mask.placeholder];
    }
    newRange.length = 0;
    
    textField.text = mutableString;
    [textField setValue:[NSValue valueWithRange:newRange] forKey:@"selectionRange"];
    
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([self._extension respondsToSelector:@selector(textFieldDidBeginEditing:)])
    {
        [self._extension textFieldDidBeginEditing:textField];
    }
    
    NSString *clean = [self.mask validCharactersForString:textField.text];
    
    NSRange newRange = NSMakeRange(0, 0);
    if (clean.length > 0)
    {
        newRange = [textField.text rangeOfString:[clean substringFromIndex:clean.length-1] options:NSBackwardsSearch];
        if (newRange.location == NSNotFound)
        {
            newRange.location = textField.text.length;
        }
        else
        {
            newRange.location += newRange.length;
        }
    } else {
        newRange = [textField.text rangeOfString:self.mask.placeholder];
    }
    
    newRange.length = 0;
    
    [textField setValue:[NSValue valueWithRange:newRange] forKey:@"selectionRange"];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([self._extension respondsToSelector:@selector(textFieldDidEndEditing:)])
    {
        [self._extension textFieldDidEndEditing:textField];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([self._extension respondsToSelector:@selector(textFieldShouldBeginEditing:)])
    {
        return [self._extension textFieldShouldBeginEditing:textField];
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if ([self._extension respondsToSelector:@selector(textFieldShouldClear:)])
    {
        return [self._extension textFieldShouldClear:textField];
    }
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if ([self._extension respondsToSelector:@selector(textFieldShouldEndEditing:)])
    {
        return [self._extension textFieldShouldEndEditing:textField];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([self._extension respondsToSelector:@selector(textFieldShouldReturn:)])
    {
        textField.text = [self.mask validCharactersForString:textField.text];
        return [self._extension textFieldShouldReturn:textField];
    }
    
    return YES;
}

#pragma mark - Overridden Methods

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    if (self.mask)
    {
        [super setDelegate:self];
    }
}

@end
