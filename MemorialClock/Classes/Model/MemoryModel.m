//
//  MemoryModel.m
//  MemorialClock
//
//  Created by プー坊 on 11/09/19.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MemoryModel.h"
#import "FMDatabase.h"
#import "NSDictionary+Null.h"


#define kDBName @"MemorialClock.db"
#define kImageDirectory @"image"

static MemoryModel *sharedMemoryModel_ = nil;

@interface MemoryModel (Private)
- (NSArray *)memoryIdList;
- (int)nextMemoryId;
- (NSString *)imagePath:(int)memoryId;
@end

@implementation MemoryModel

//--------------------------------------------------------------//
#pragma mark -- Initialize --
//--------------------------------------------------------------//

+ (MemoryModel *)sharedMemoryModel
{
    @synchronized(self) {
        if (!sharedMemoryModel_) {
            sharedMemoryModel_ = [[self alloc] init];
        }
    }
    return sharedMemoryModel_;
}

- (id)init{
    self = [super init];

    if (!self) {
        return nil;
    }

    //データベースファイルをリソースからドキュメントにコピーする
    NSString *resourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kDBName];

    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    dbPath_ = [[[documentPaths objectAtIndex:0] stringByAppendingPathComponent:kDBName] retain];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    //debug用に毎回消す
    if ([fileManager fileExistsAtPath:dbPath_]) {
        [fileManager removeItemAtPath:dbPath_ error:nil];
    }
    if ([fileManager fileExistsAtPath:dbPath_] == NO) {
        NSError *error;
        if ([fileManager copyItemAtPath:resourcePath toPath:dbPath_ error:&error] == NO) {
            NSLog(@"DB COPY ERROR! %@", [error localizedDescription]);
        }
    }

    //画像保存用のディレクトリを作成
    NSString *imageDirectory = [[documentPaths objectAtIndex:0] stringByAppendingPathComponent:kImageDirectory];
    if ([fileManager fileExistsAtPath:imageDirectory] == NO) {
        [fileManager createDirectoryAtPath:imageDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }

    //メンバー初期化
    memoryIdList_ = [[self memoryIdList] retain];
    prevMemoryId_ = 0;

    return self;
}

- (void)dealloc
{
    [dbPath_ release], dbPath_ = nil;
    [memoryIdList_ release], memoryIdList_ = nil;
    [super dealloc];
}

//--------------------------------------------------------------//
#pragma mark -- private methods --
//--------------------------------------------------------------//

- (NSArray *)memoryIdList
{
    NSString *selectMemoryId =
    @"SELECT "
    @"  memory_id "
    @"FROM memory ";
    //NSLog(@"selectMemoryId: %@", selectMemoryId);

    NSMutableArray *memoryIdList = [[[NSMutableArray alloc] initWithCapacity:100] autorelease];

    FMDatabase *db = [FMDatabase databaseWithPath:dbPath_];
    if ([db open]) {
        [db setShouldCacheStatements:YES];
        FMResultSet *rs = [db executeQuery:selectMemoryId];
        while ([rs next]) {
            [memoryIdList addObject:[NSNumber numberWithInt:[rs intForColumn:@"memory_id"]]];
        }
        [rs close];
        [db close];
    } else {
        NSLog(@"Could not open db.");
    }
    //NSLog(@"memoryIdList: %@", memoryIdList);

    return memoryIdList;
}

- (int)nextMemoryId
{
    int memoryId = 0;
    switch ([memoryIdList_ count]) {
        case 0:
            memoryId = 0;
            break;
        case 1:
            memoryId = [[memoryIdList_ objectAtIndex:0] intValue];
            break;
        default: //2-
            do {
                //乱数で前回と違う値を設定
                memoryId = 0;
                break;
            } while (prevMemoryId_ == memoryId);
            break;
    }
    prevMemoryId_ = memoryId;
    return memoryId;
}

- (NSString *)imagePath:(int)memoryId
{
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *imagePath = [[documentPaths objectAtIndex:0] stringByAppendingPathComponent:kImageDirectory];
    imagePath = [imagePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.jpg", memoryId]];
    //NSLog(@"imagePath: %@", imagePath);

    return imagePath;
}

//--------------------------------------------------------------//
#pragma mark -- public methods --
//--------------------------------------------------------------//

- (NSDictionary *)memory
{
    NSMutableDictionary *memory = [[NSMutableDictionary alloc] initWithCapacity:5];
    [memory setObject:[NSNumber numberWithInt:0] forKey:@"memory_id"];
    [memory setObjectNull:nil forKey:@"name"];
    [memory setObjectNull:nil forKey:@"message"];
    [memory setObjectNull:nil forKey:@"image"];

    int memoryId = [self nextMemoryId];
    if (memoryId > 0) {
        NSString *selectMemory =
        @"SELECT "
        @"  memory_id, "
        @"  name, "
        @"  message "
        @"FROM memory "
        @"WHERE memory_id = ? ";
        //NSLog(@"selectMemory: %@", selectMemory);

        FMDatabase *db = [FMDatabase databaseWithPath:dbPath_];
        if ([db open]) {
            [db setShouldCacheStatements:YES];
            FMResultSet *rs = [db executeQuery:selectMemory,
                               [NSNumber numberWithInt:memoryId]];
            while ([rs next]) {
                [memory setObject:[NSNumber numberWithInt:[rs intForColumn:@"memory_id"]] forKey:@"memory_id"];
                [memory setObjectNull:[rs stringForColumn:@"name"] forKey:@"name"];
                [memory setObjectNull:[rs stringForColumn:@"message"] forKey:@"message"];
                [memory setObjectNull:[UIImage imageWithContentsOfFile:[self imagePath:memoryId]] forKey:@"image"];
                break;
            }
            [rs close];
            [db close];
        } else {
            NSLog(@"Could not open db.");
        }
    }
    //NSLog(@"memory: %@", memory);

    return memory;
}

- (int)addMemory:(NSString *)name message:(NSString *)message image:(UIImage *)image
{
    int memoryId;

    NSString *insertMemory =
    @"INSERT INTO memory ( "
    @"  name, "
    @"  message "
    @") "
    @"VALUES ( "
    @"  ?, "
    @"  ? "
    @") ";
    //NSLog(@"insertMemory: %@", insertMemory);

    NSString *selectMaxMemoryId =
    @"SELECT MAX(memory_id) "
    @"FROM memory ";
    //NSLog(@"selectMaxMemoryId: %@", selectMaxMemoryId);

    FMDatabase *db = [FMDatabase databaseWithPath:dbPath_];
    if ([db open]) {
        [db setShouldCacheStatements:YES];
        [db beginTransaction];

        //memoryレコード登録
        [db executeUpdate:insertMemory,
         name,
         message];
        if ([db hadError]) {
            NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }

        //新規ID取得
        FMResultSet *rs = [db executeQuery:selectMaxMemoryId];
        while ([rs next]) {
            memoryId = [rs intForColumnIndex:0];
            break;
        }
        [rs close];

        //画像保存
        NSString *imagePath = [self imagePath:memoryId];
        NSData *imageData = UIImagePNGRepresentation(image);
        [imageData writeToFile:imagePath atomically:YES];

        [db commit];
        [db close];
    } else {
        NSLog(@"Could not open db.");
    }

    //IDリスト再取得
    [memoryIdList_ release], memoryIdList_ = [[self memoryIdList] retain];

    return memoryId;
}

//--------------------------------------------------------------//
#pragma mark -- Singleton --
//--------------------------------------------------------------//

+ (id)allocWithZone:(NSZone*)zone
{
    @synchronized(self) {
        if (!sharedMemoryModel_) {
            sharedMemoryModel_ = [super allocWithZone:zone];
            return sharedMemoryModel_;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone*)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (unsigned)retainCount
{
    return UINT_MAX;
}

- (void)release
{
}

- (id)autorelease
{
    return self;
}

@end
