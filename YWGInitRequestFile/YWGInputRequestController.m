//
//  YWGInputRequestController.m
//  YWGInitRequestFile
//
//  Created by Visitor on 16/7/29.
//  Copyright © 2016年 YangWeiguang. All rights reserved.
//

#import "YWGInputRequestController.h"
#import "YWGClassInfo.h"

@interface YWGInputRequestController () <NSTextFieldDelegate, NSWindowDelegate>

@property (weak) IBOutlet NSButton *cancelButton;
@property (weak) IBOutlet NSButton *enterButton;
@property (weak) IBOutlet NSTextField *inputNameTextField;
@property (weak) IBOutlet NSTextField *inputUrlTextField;
@property (weak) IBOutlet NSButton *isPageListButton;

@property (nonatomic, assign) BOOL isPageList;

@end

@implementation YWGInputRequestController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    self.inputUrlTextField.delegate = self;
    self.inputNameTextField.delegate = self;
    self.window.delegate = self;
}

- (void)windowWillClose:(NSNotification *)notification {
    if ([self.delegate respondsToSelector:@selector(windowWillClose)]) {
        [self.delegate windowWillClose];
    }
}
- (IBAction)cancelButtonClick:(id)sender {
    [self close];
}

- (IBAction)enterButtonClick:(id)sender {
    NSTextField *nameTextField = self.inputNameTextField;
    NSTextField *urlTextField = self.inputUrlTextField;
    BOOL result = (nameTextField.stringValue.length > 0 && urlTextField.stringValue.length > 0);
    if (!result) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Input request name & url";
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
        NSLog(@"Error：Json is invalid");
    }else{
        
        YWGClassInfo *classInfo = [[YWGClassInfo alloc] initWithClassName:nameTextField.stringValue url:urlTextField.stringValue isPageList:self.isPageList];
        
        [self close];
        [[NSNotificationCenter defaultCenter] postNotificationName:YWGResultNotification object:classInfo];
    }
}

- (IBAction)isPageListClick:(id)sender {
    NSButton *switchBtn = sender;
    self.isPageList = switchBtn.state;
}

@end
