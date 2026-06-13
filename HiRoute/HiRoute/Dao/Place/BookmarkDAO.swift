//
//  BookmarkDAO.swift
//  HiRoute
//
//  Created by Jupond on 3/6/26.
//

import CoreData

/// 북마크 독립 저장/조회 (PlaceEntity 관계 없이 placeUID 기반)
struct BookmarkDAO {
    private init() {}

    /// 북마크 토글 (존재하면 삭제, 없으면 생성)
    /// - Returns: true = 추가됨, false = 제거됨
    static func toggle(userUid: String, placeUid: String, context: NSManagedObjectContext, completion: @escaping (Bool) -> Void) {
        context.perform {
            do {
                let request: NSFetchRequest<BookmarkEntity> = BookmarkEntity.fetchRequest()
                request.predicate = NSPredicate(format: "userUID == %@ AND placeUID == %@", userUid, placeUid)

                if let existing = try context.fetch(request).first {
                    context.delete(existing)
                    try context.save()
                    print("BookmarkDAO, toggle // Success : 북마크 제거 - \(placeUid)")
                    completion(false)
                } else {
                    let entity = BookmarkEntity(context: context)
                    entity.userUID = userUid
                    entity.placeUID = placeUid
                    try context.save()
                    print("BookmarkDAO, toggle // Success : 북마크 추가 - \(placeUid)")
                    completion(true)
                }
            } catch {
                print("BookmarkDAO, toggle // Exception : \(error.localizedDescription)")
                completion(false)
            }
        }
    }

    /// 북마크 여부 확인
    static func isBookmarked(userUid: String, placeUid: String, context: NSManagedObjectContext, completion: @escaping (Bool) -> Void) {
        context.perform {
            do {
                let request: NSFetchRequest<BookmarkEntity> = BookmarkEntity.fetchRequest()
                request.predicate = NSPredicate(format: "userUID == %@ AND placeUID == %@", userUid, placeUid)
                request.fetchLimit = 1
                let count = try context.count(for: request)
                completion(count > 0)
            } catch {
                print("BookmarkDAO, isBookmarked // Exception : \(error.localizedDescription)")
                completion(false)
            }
        }
    }

    /// 유저의 북마크 placeUID 목록 조회
    static func getUserBookmarkPlaceUids(userUid: String, context: NSManagedObjectContext, completion: @escaping ([String]) -> Void) {
        context.perform {
            do {
                let request: NSFetchRequest<BookmarkEntity> = BookmarkEntity.fetchRequest()
                request.predicate = NSPredicate(format: "userUID == %@", userUid)
                let entities = try context.fetch(request)
                let placeUids = entities.compactMap { $0.placeUID }
                print("BookmarkDAO, getUserBookmarkPlaceUids // Success : \(placeUids.count)개 조회")
                completion(placeUids)
            } catch {
                print("BookmarkDAO, getUserBookmarkPlaceUids // Exception : \(error.localizedDescription)")
                completion([])
            }
        }
    }
}
