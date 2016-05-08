//
//  FailedMessageStore.m
//  Pods
//
//  Created by shuu on 16/5/6.
//
//

#import "FailedMessageStore.h"
#import <FMDB/FMDB.h>
#import "XHMessage.h"

#define kCDFaildMessageTable @"failed_messages"
#define kCDKeyId @"id"
#define kCDKeyConversationId @"conversationId"
#define kCDKeyMessage @"message"

#define kCDCreateTableSQL                                       \
@"CREATE TABLE IF NOT EXISTS " kCDFaildMessageTable @"("    \
kCDKeyId @" VARCHAR(63) PRIMARY KEY, "                  \
kCDKeyConversationId @" VARCHAR(63) NOT NULL,"          \
kCDKeyMessage @" BLOB NOT NULL"                         \
@")"

#define kCDWhereConversationId \
@" WHERE " kCDKeyConversationId @" = ? "

#define kCDSelectMessagesSQL                        \
@"SELECT * FROM " kCDFaildMessageTable          \
kCDWhereConversationId

#define kCDInsertMessageSQL                             \
@"INSERT OR IGNORE INTO " kCDFaildMessageTable @"(" \
kCDKeyId @","                                   \
kCDKeyConversationId @","                       \
kCDKeyMessage                                   \
@") values (?, ?, ?) "                              \

#define kCDDeleteMessageSQL                             \
@"DELETE FROM " kCDFaildMessageTable @" "           \
@"WHERE " kCDKeyId " = ? "                          \

@interface FailedMessageStore ()

@property (nonatomic, strong) FMDatabaseQueue *databaseQueue;

@end

@implementation FailedMessageStore

+ (FailedMessageStore *)store {
    static FailedMessageStore *manager;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        manager = [[FailedMessageStore alloc] init];
    });
    return manager;
}

- (void)setupStoreWithDatabasePath:(NSString *)path {
    if (self.databaseQueue) {
        NSLog(@"database queue should not be nil !!!!");
    }
    self.databaseQueue = [FMDatabaseQueue databaseQueueWithPath:path];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:kCDCreateTableSQL];
    }];
}

- (NSDictionary *)recordFromResultSet:(FMResultSet *)resultSet {
    NSMutableDictionary *record = [NSMutableDictionary dictionary];
    NSData *data = [resultSet dataForColumn:kCDKeyMessage];
    AVIMTypedMessage *message = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    [record setObject:message forKey:kCDKeyMessage];
    //FIXME:crash beacause `[resultSet stringForColumn:kCDKeyId]` is nil
    //TODO:why I should set id ? what are the id working for?
    NSString *idValue = [resultSet stringForColumn:kCDKeyId];
    //TODO: make sure idValue is not nil
    //    if (!idValue) {
    //        [record setObject:[[NSUUID UUID] UUIDString] forKey:kCDKeyId];
    //    } else {
    [record setObject:idValue forKey:kCDKeyId];
    //    }
    return record;
}

- (NSArray *)recordsByConversationId:(NSString *)conversationId {
    NSMutableArray *records = [NSMutableArray array];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:kCDSelectMessagesSQL, conversationId];
        while ([resultSet next]) {
            [records addObject:[self recordFromResultSet:resultSet]];
        }
        [resultSet close];
    }];
    return records;
}

- (NSArray *)selectFailedMessagesByConversationId:(NSString *)conversationId {
    NSArray *records = [self recordsByConversationId:conversationId];
    NSMutableArray *messages = [NSMutableArray array];
    for (NSDictionary *record in records) {
        [messages addObject:record[kCDKeyMessage]];
    }
    return messages;
}

- (BOOL)deleteFailedMessageByRecordId:(NSString *)recordId {
    __block BOOL result;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:kCDDeleteMessageSQL, recordId];
    }];
    return result;
}


- (void)insertFailedXHMessage:(XHMessage *)message {
    if (message.conversationId == nil) {
        @throw [NSException exceptionWithName:NSGenericException
                                       reason:@"conversationId is nil"
                                     userInfo:nil];
    }
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:message];
    NSAssert(data, @"You can not insert nil message to DB");
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:kCDInsertMessageSQL, message.messageId, message.conversationId, data];
    }];
}


- (void)insertFailedMessage:(AVIMTypedMessage *)message {
    if (message.conversationId == nil) {
        @throw [NSException exceptionWithName:NSGenericException
                                       reason:@"conversationId is nil"
                                     userInfo:nil];
    }
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:message];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:kCDInsertMessageSQL, message.messageId, message.conversationId, data];
    }];
}


@end
