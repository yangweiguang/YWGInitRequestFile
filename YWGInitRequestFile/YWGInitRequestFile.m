//
//  YWGInitRequestFile.m
//  YWGInitRequestFile
//
//  Created by Visitor on 16/7/29.
//  Copyright © 2016年 YangWeiguang. All rights reserved.
//

#import "YWGInitRequestFile.h"
#import "YWGInputRequestController.h"
#import "YWGClassInfo.h"
#import "YWGPbxprojInfo.h"
#import "NSString+Uplower.h"

static YWGInitRequestFile *sharedPlugin;

@interface YWGInitRequestFile () <YWGInputRequestControllerDelegate>

@property (nonatomic, assign) BOOL notiTag;
@property (nonatomic, strong) YWGInputRequestController *inputCtrl;
@property (nonatomic, copy) NSString *currentFilePath;
@property (nonatomic, copy) NSString *currentProjectPath;
@property (nonatomic) NSTextView *currentTextView;

@end

@implementation YWGInitRequestFile

#pragma mark - Initialization

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    NSArray *allowedLoaders = [plugin objectForInfoDictionaryKey:@"me.delisa.XcodePluginBase.AllowedLoaders"];
    if ([allowedLoaders containsObject:[[NSBundle mainBundle] bundleIdentifier]]) {
        sharedPlugin = [[self alloc] initWithBundle:plugin];
    }
}

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)bundle
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource access
        _bundle = bundle;
        // NSApp may be nil if the plugin is loaded from the xcodebuild command line tool
        if (NSApp && !NSApp.mainMenu) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidFinishLaunching:) name:NSApplicationDidFinishLaunchingNotification object:nil];
        } else {
            [self initializeAndLog];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(outputResult:) name:YWGResultNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationLog:) name:NSTextViewDidChangeSelectionNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationLog:) name:@"IDEEditorDocumentDidChangeNotification" object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationLog:) name:@"PBXProjectDidOpenNotification" object:nil];
        }
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(outputResult:) name:YWGResultNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationLog:) name:NSTextViewDidChangeSelectionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationLog:) name:@"IDEEditorDocumentDidChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationLog:) name:@"PBXProjectDidOpenNotification" object:nil];
    [self initializeAndLog];
}

- (void)initializeAndLog
{
    NSString *name = [self.bundle objectForInfoDictionaryKey:@"CFBundleName"];
    NSString *version = [self.bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *status = [self initialize] ? @"loaded successfully" : @"failed to load";
    NSLog(@"🔌 Plugin %@ %@ %@", name, version, status);
}

#pragma mark - Implementation

- (BOOL)initialize
{
    self.notiTag = YES;
    // Create menu items, initialize UI, etc.
    // Sample Menu Item:
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Window"];
    if (menuItem) {
        //Input JSON window
        NSMenuItem *inputJsonWindow = [[NSMenuItem alloc] initWithTitle:@"Input request window" action:@selector(showInputJsonWindow:) keyEquivalent:@"J"];
        [inputJsonWindow setKeyEquivalentModifierMask:NSAlphaShiftKeyMask | NSControlKeyMask];
        inputJsonWindow.target = self;
        [[menuItem submenu] addItem:inputJsonWindow];
        return YES;
    } else {
        return NO;
    }
}

- (void)notificationLog:(NSNotification *)notify {
    if (!self.notiTag) return;
    if ([notify.name isEqualToString:NSTextViewDidChangeSelectionNotification]) {
        if ([notify.object isKindOfClass:[NSTextView class]]) {
            NSTextView *text = (NSTextView *)notify.object;
            self.currentTextView = text;
        }
    } else if ([notify.name isEqualToString:@"IDEEditorDocumentDidChangeNotification"]){
        //Track the current open paths
        NSObject *array = notify.userInfo[@"IDEEditorDocumentChangeLocationsKey"];
        NSURL *url = [[array valueForKey:@"documentURL"] firstObject];
        if (![url isKindOfClass:[NSNull class]]) {
            NSString *path = [url absoluteString];
            self.currentFilePath = path;
        }
    }else if ([notify.name isEqualToString:@"PBXProjectDidOpenNotification"]){
        if (!self.currentProjectPath) {
            self.currentProjectPath = [notify.object valueForKey:@"path"];
            [[YWGPbxprojInfo shareInstance] setParamsWithPath:[self.currentProjectPath stringByAppendingPathComponent:@"project.pbxproj"]];
        }
    }
}

-(void)outputResult:(NSNotification *)noti {
    YWGClassInfo *classInfo = noti.object;
    
    if (!self.currentTextView) return;
    //再添加.m文件的内容
    NSString *urlStr = [NSString stringWithFormat:@"%@m",[self.currentFilePath substringWithRange:NSMakeRange(0, self.currentFilePath.length-1)]] ;
    NSLog(@"+++++++++%@", urlStr);
    NSURL *writeUrl = [NSURL URLWithString:urlStr];
    //The original content
    NSString *originalContent = [NSString stringWithContentsOfURL:writeUrl encoding:NSUTF8StringEncoding error:nil];
    
    //先添加主类的属性
    if (classInfo.isPageList) {
        NSRange atInsertRange = [self.currentTextView.string rangeOfString:@"@interface"];
        if (atInsertRange.location == NSNotFound) {
            return;
        }
        atInsertRange = [self.currentTextView.string rangeOfString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(atInsertRange.location + atInsertRange.length, self.currentTextView.string.length - atInsertRange.location - atInsertRange.length)];
        
        [self.currentTextView insertText:[NSString stringWithFormat:@"\n@property (nonatomic, strong) NSMutableArray * %@;\n\n@property (nonatomic, assign) NSInteger page;\n", classInfo.dataProName] replacementRange:NSMakeRange(atInsertRange.location + 1, 0)];
        
        //.m 文件
        NSString *methodStr = [NSString stringWithFormat:@"\n- (NSMutableArray *)%@ {\n    if (!_%@) {\n        _%@ = [[NSMutableArray alloc] init];\n    }\n    return _%@;\n}\n", classInfo.dataProName, classInfo.dataProName, classInfo.dataProName, classInfo.dataProName];
        NSRange lastEndRange = [originalContent rangeOfString:@"@end"];
        if (lastEndRange.location != NSNotFound) {
            originalContent = [originalContent stringByReplacingCharactersInRange:NSMakeRange(lastEndRange.location, 0) withString:methodStr];
        }
        
    }
    
    NSRange hlastEndRange = [self.currentTextView.string rangeOfString:@"@end"];
    if (hlastEndRange.location != NSNotFound) {
        [self.currentTextView insertText:classInfo.methordContentForH replacementRange:NSMakeRange(hlastEndRange.location, 0)];
    }
    
    NSString * impContent = [NSString stringWithFormat:@"\n#import \"%@.h\"\n#import \"%@.h\"", classInfo.className, classInfo.modelClassName];
    NSRange mLastRange = [originalContent rangeOfString:@".h\""];
    originalContent = [originalContent stringByReplacingCharactersInRange:NSMakeRange(mLastRange.location + mLastRange.length, 0) withString:impContent];
    
    NSRange lastEndRange = [originalContent rangeOfString:@"@end"];
    originalContent = [originalContent stringByReplacingCharactersInRange:NSMakeRange(lastEndRange.location, 0) withString:classInfo.methordContentForM];
    [originalContent writeToURL:writeUrl atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    //选择保存路径
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setTitle:@"Input request window"];
    [panel setCanChooseDirectories:YES];
    [panel setCanCreateDirectories:YES];
    [panel setCanChooseFiles:NO];
    
    if ([panel runModal] == NSModalResponseOK) {
        NSString *folderPath = [[[panel URLs] objectAtIndex:0] relativePath];
        [classInfo createFileWithFolderPath:folderPath];
        [[NSWorkspace sharedWorkspace] openFile:folderPath];
    }
    
    [classInfo addUrlToFileWithFileName:@"NetWorkUrlConfig" currentProPath:self.currentProjectPath currentFilePath:self.currentFilePath];
}

- (void)showInputJsonWindow:(NSMenuItem *)item {
    if (!(self.currentTextView && self.currentFilePath)) {
        NSError *error = [NSError errorWithDomain:@"Current state is not edit!" code:0 userInfo:nil];
        NSAlert *alert = [NSAlert alertWithError:error];
        [alert runModal];
        return;
    }
    self.notiTag = NO;
    self.inputCtrl = [[YWGInputRequestController alloc] initWithWindowNibName:@"YWGInputRequestController"];
    self.inputCtrl.delegate = self;
    [self.inputCtrl showWindow:self.inputCtrl];
}

-(void)windowWillClose {
    self.notiTag = YES;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
