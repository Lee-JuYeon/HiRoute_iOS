//
//  UserDao.swift
//  HiRoute
//
//  Created by Jupond on 3/1/26.
//

import CoreData
import os

struct UserDAO {
    private init() {}

    private static let logger = Logger(subsystem: "com.nunulala.app", category: "auth")

    /// User 생성
    static func create(_ user: UserModel, context: NSManagedObjectContext, completion: @escaping (Bool) -> Void) {
        context.perform {
            do {
                if readSync(uid: user.uid, context: context) != nil {
                    logger.warning("User already exists: \(user.uid, privacy: .private(mask: .hash))")
                    completion(false)
                    return
                }

                _ = try UserEntityMapper.toEntity(user, context: context)
                try context.save()
                completion(true)
                logger.info("User created: \(user.uid, privacy: .private(mask: .hash))")
            } catch {
                completion(false)
                logger.error("User create failed: \(error.localizedDescription, privacy: .public)")
            }
        }
    }

    /// User 조회
    static func read(uid: String, context: NSManagedObjectContext, completion: @escaping (UserModel?) -> Void) {
        context.perform {
            do {
                let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
                request.predicate = NSPredicate(format: "uid == %@", uid)

                if let entity = try context.fetch(request).first {
                    let user = try UserEntityMapper.toModel(entity)
                    completion(user)
                } else {
                    completion(nil)
                }
            } catch {
                logger.error("User read failed: \(error.localizedDescription, privacy: .public)")
                completion(nil)
            }
        }
    }

    /// User 업데이트 (암호화 필드 전체 교체: 삭제 → 재생성)
    static func update(_ user: UserModel, context: NSManagedObjectContext, completion: @escaping (Bool) -> Void) {
        context.perform {
            do {
                let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
                request.predicate = NSPredicate(format: "uid == %@", user.uid)

                if let existingEntity = try context.fetch(request).first {
                    context.delete(existingEntity)
                    _ = try UserEntityMapper.toEntity(user, context: context)
                    try context.save()
                    completion(true)
                    logger.info("User updated: \(user.uid, privacy: .private(mask: .hash))")
                } else {
                    completion(false)
                    logger.warning("User not found for update: \(user.uid, privacy: .private(mask: .hash))")
                }
            } catch {
                completion(false)
                logger.error("User update failed: \(error.localizedDescription, privacy: .public)")
            }
        }
    }

    /// User 삭제
    static func delete(uid: String, context: NSManagedObjectContext, completion: @escaping (Bool) -> Void) {
        context.perform {
            do {
                let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
                request.predicate = NSPredicate(format: "uid == %@", uid)

                if let entity = try context.fetch(request).first {
                    context.delete(entity)
                    try context.save()
                    completion(true)
                    logger.info("User deleted: \(uid, privacy: .private(mask: .hash))")
                } else {
                    completion(false)
                    logger.warning("User not found for delete: \(uid, privacy: .private(mask: .hash))")
                }
            } catch {
                completion(false)
                logger.error("User delete failed: \(error.localizedDescription, privacy: .public)")
            }
        }
    }

    // MARK: - Helper (동기식 - context.perform 내부에서만 호출)

    private static func readSync(uid: String, context: NSManagedObjectContext) -> UserModel? {
        do {
            let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
            request.predicate = NSPredicate(format: "uid == %@", uid)

            if let entity = try context.fetch(request).first {
                return try UserEntityMapper.toModel(entity)
            }
            return nil
        } catch {
            logger.error("User readSync failed: \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }
}
