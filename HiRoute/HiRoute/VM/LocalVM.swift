//
//  LocalVM.swift
//  HiRoute
//
//  Created by Jupond on 11/28/25.
//
import SwiftUI
import Combine
import CoreData

class LocalVM : ObservableObject {
    
    @Published var nationality : NationalityType {
        didSet {
            saveToUserDefaults()
        }
    }
    
    private let userDefaults = UserDefaults.standard
    private let userDefaultsKey = "local"
    
    
    init() {
        // 앱 시작시 UserDefaults에서 로드
        let savedRawValue = UserDefaults.standard.string(forKey: "local")
                
        if let savedRawValue = savedRawValue,
           let savedType = NationalityType(rawValue: savedRawValue) {
            self.nationality = savedType
        } else {
            self.nationality = NationalityType.systemDefault
        }
                                
        
        backgroundContext = CoreDataStack.shared.persistentContainer.newBackgroundContext()
        backgroundContext.automaticallyMergesChangesFromParent = true
        backgroundContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        
        setupMemoryWarningObserver()
        print("LocalVM, init // Success : LocalVM 초기화 완료")
    }
    
    // MARK: - Public Methods
    func updateNationality(_ newType: NationalityType) {
        nationality = newType
        print("🌍 Nationality updated to: \(newType)")
    }
    
    func resetToSystemDefault() {
        nationality = NationalityType.systemDefault
    }
    
    // MARK: - Private Methods
    private func loadFromUserDefaults() -> NationalityType {
        guard let savedRawValue = userDefaults.string(forKey: userDefaultsKey),
              let savedType = NationalityType(rawValue: savedRawValue) else {
            return NationalityType.systemDefault
        }
        return savedType
    }
    
    private func saveToUserDefaults() {
        userDefaults.set(nationality.displayText, forKey: userDefaultsKey)
    }
    
    // MARK: - Published Properties
    @Published var schedules: [ScheduleModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private let mainContext = CoreDataStack.shared.context
    private let backgroundContext: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()
    
    private let batchSize = 20
    private let maxMemoryItems = 100
    
    /// 일정 생성
    func createSchedule(_ schedule: ScheduleModel) {
        performBackgroundTask { [weak self] context in
            guard let self = self else { return }
            
            // 중복 확인
            if self.checkDuplicateSync(uid: schedule.uid, in: context) {
                DispatchQueue.main.async {
                    self.errorMessage = "이미 존재하는 일정입니다"
                    print("LocalVM, createSchedule // Warning : 중복된 일정 생성 시도 - \(schedule.uid)")
                }
                return
            }
            
            let scheduleEntity = ScheduleEntity(context: context)
            self.mapModelToEntity(schedule, entity: scheduleEntity, context: context)
            
            do {
                try context.save()
                DispatchQueue.main.async { [weak self] in
                    self?.schedules.append(schedule)
                    print("LocalVM, createSchedule // Success : 일정 생성 완료 - \(schedule.title)")
                }
            } catch {
                context.rollback()
                DispatchQueue.main.async { [weak self] in
                    self?.errorMessage = "일정 생성 실패: \(error.localizedDescription)"
                    print("LocalVM, createSchedule // Exception : \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// 일정 업데이트
    func updateSchedule(_ schedule: ScheduleModel) {
        performBackgroundTask { [weak self] context in
            guard let self = self else { return }
            
            let request: NSFetchRequest<ScheduleEntity> = ScheduleEntity.fetchRequest()
            request.predicate = NSPredicate(format: "uid == %@", schedule.uid)
            request.fetchLimit = 1
            
            do {
                if let existingEntity = try context.fetch(request).first {
                    self.cleanupExistingRelations(entity: existingEntity, context: context)
                    self.mapModelToEntity(schedule, entity: existingEntity, context: context)
                    
                    try context.save()
                    
                    DispatchQueue.main.async { [weak self] in
                        if let index = self?.schedules.firstIndex(where: { $0.uid == schedule.uid }) {
                            self?.schedules[index] = schedule
                        }
                        print("LocalVM, updateSchedule // Success : 일정 업데이트 완료 - \(schedule.title)")
                    }
                } else {
                    print("LocalVM, updateSchedule // Warning : 업데이트할 일정을 찾을 수 없음 - \(schedule.uid)")
                }
            } catch {
                context.rollback()
                DispatchQueue.main.async { [weak self] in
                    self?.errorMessage = "일정 업데이트 실패: \(error.localizedDescription)"
                    print("LocalVM, updateSchedule // Exception : \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// 일정 삭제
    func deleteSchedule(uid: String) {
        performBackgroundTask { [weak self] context in
            guard let self = self else { return }
            
            let request: NSFetchRequest<ScheduleEntity> = ScheduleEntity.fetchRequest()
            request.predicate = NSPredicate(format: "uid == %@", uid)
            request.fetchLimit = 1
            
            do {
                if let entity = try context.fetch(request).first {
                    context.delete(entity)
                    try context.save()
                    
                    DispatchQueue.main.async { [weak self] in
                        self?.schedules.removeAll { $0.uid == uid }
                        print("LocalVM, deleteSchedule // Success : 일정 삭제 완료 - \(uid)")
                    }
                } else {
                    print("LocalVM, deleteSchedule // Warning : 삭제할 일정을 찾을 수 없음 - \(uid)")
                }
            } catch {
                context.rollback()
                DispatchQueue.main.async { [weak self] in
                    self?.errorMessage = "일정 삭제 실패: \(error.localizedDescription)"
                    print("LocalVM, deleteSchedule // Exception : \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// 모든 일정 로드
    func loadAllSchedules() {
        guard !isLoading else {
            print("LocalVM, loadAllSchedules // Warning : 이미 로딩 중")
            return
        }
        
        isLoading = true
        errorMessage = nil
        print("LocalVM, loadAllSchedules // Info : 일정 로딩 시작")
        
        performBackgroundTask { [weak self] context in
            guard let self = self else { return }
            
            let request: NSFetchRequest<ScheduleEntity> = ScheduleEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "editDate", ascending: false)]
            request.fetchBatchSize = self.batchSize
            
            do {
                let entities = try context.fetch(request)
                let schedules = entities.compactMap { self.convertToScheduleModel($0) }
                
                DispatchQueue.main.async { [weak self] in
                    self?.schedules = schedules
                    self?.isLoading = false
                    print("LocalVM, loadAllSchedules // Success : 일정 로드 완료 - \(schedules.count)개")
                    self?.checkMemoryLimits()
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.isLoading = false
                    self?.errorMessage = "일정 로드 실패: \(error.localizedDescription)"
                    print("LocalVM, loadAllSchedules // Exception : \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// 특정 일정 조회
    func getSchedule(uid: String) -> ScheduleModel? {
        // 먼저 메모리에서 찾기
        if let schedule = schedules.first(where: { $0.uid == uid }) {
            print("LocalVM, getSchedule // Success : 메모리에서 일정 조회 - \(uid)")
            return schedule
        }
        
        // CoreData에서 찾기
        let request: NSFetchRequest<ScheduleEntity> = ScheduleEntity.fetchRequest()
        request.predicate = NSPredicate(format: "uid == %@", uid)
        request.fetchLimit = 1
        
        do {
            if let entity = try mainContext.fetch(request).first {
                print("LocalVM, getSchedule // Success : CoreData에서 일정 조회 - \(uid)")
                return convertToScheduleModel(entity)
            } else {
                print("LocalVM, getSchedule // Warning : 일정을 찾을 수 없음 - \(uid)")
            }
        } catch {
            errorMessage = "일정 조회 실패: \(error.localizedDescription)"
            print("LocalVM, getSchedule // Exception : \(error.localizedDescription)")
        }
        
        return nil
    }
    
    // MARK: - Memory Management
    
    /// 메모리 정리
    func clearMemoryCache() {
        mainContext.perform { [weak self] in
            self?.mainContext.refreshAllObjects()
        }
        
        backgroundContext.perform { [weak self] in
            self?.backgroundContext.reset()
        }
        
        print("LocalVM, clearMemoryCache // Success : 메모리 캐시 정리 완료")
    }
    
    /// 메모리 제한 확인
    private func checkMemoryLimits() {
        if schedules.count > maxMemoryItems {
            let sortedSchedules = schedules.sorted { $0.editDate < $1.editDate }
            let keepCount = maxMemoryItems * 3 / 4
            let removedCount = schedules.count - keepCount
            schedules = Array(sortedSchedules.suffix(keepCount))
            print("LocalVM, checkMemoryLimits // Warning : 메모리 제한으로 \(removedCount)개 항목 정리")
        }
    }
    
    /// 메모리 경고 관찰자 설정
    private func setupMemoryWarningObserver() {
        NotificationCenter.default.publisher(for: UIApplication.didReceiveMemoryWarningNotification)
            .sink { [weak self] _ in
                self?.handleMemoryWarning()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { [weak self] _ in
                self?.clearMemoryCache()
            }
            .store(in: &cancellables)
        
        print("LocalVM, setupMemoryWarningObserver // Success : 메모리 경고 관찰자 설정 완료")
    }
    
    private func handleMemoryWarning() {
        let beforeCount = schedules.count
        schedules.removeAll { $0.planList.isEmpty }
        let afterCount = schedules.count
        clearMemoryCache()
        print("LocalVM, handleMemoryWarning // Warning : 메모리 경고 대응 - \(beforeCount - afterCount)개 빈 일정 제거")
    }
    
    // MARK: - Private Helpers
    
    /// 백그라운드 작업 수행
    private func performBackgroundTask(_ task: @escaping (NSManagedObjectContext) -> Void) {
        backgroundContext.perform { [weak self] in
            guard let self = self else {
                print("LocalVM, performBackgroundTask // Warning : self가 해제됨")
                return
            }
            task(self.backgroundContext)
        }
    }
    
    /// 중복 확인
    private func checkDuplicateSync(uid: String, in context: NSManagedObjectContext) -> Bool {
        let request: NSFetchRequest<ScheduleEntity> = ScheduleEntity.fetchRequest()
        request.predicate = NSPredicate(format: "uid == %@", uid)
        request.fetchLimit = 1
        
        do {
            let count = try context.count(for: request)
            return count > 0
        } catch {
            print("LocalVM, checkDuplicateSync // Exception : \(error.localizedDescription)")
            return false
        }
    }
    
    /// 기존 관계 정리
    private func cleanupExistingRelations(entity: ScheduleEntity, context: NSManagedObjectContext) {
        if let plans = entity.planList as? Set<PlanEntity> {
            let deleteCount = plans.count
            for plan in plans {
                context.delete(plan)
            }
            print("LocalVM, cleanupExistingRelations // Info : 기존 관계 \(deleteCount)개 정리")
        }
    }
    
    /// Model → Entity 매핑
    private func mapModelToEntity(_ model: ScheduleModel, entity: ScheduleEntity, context: NSManagedObjectContext) {
        entity.uid = model.uid
        entity.index = Int32(model.index)
        entity.title = model.title
        entity.memo = model.memo
        entity.editDate = model.editDate
        entity.d_day = model.d_day
        
        for plan in model.planList {
            let planEntity = createVisitPlaceEntity(from: plan, schedule: entity, context: context)
            entity.addToPlanList(planEntity)
        }
        
        print("LocalVM, mapModelToEntity // Success : 모델 매핑 완료 - \(model.title), 방문장소 \(model.planList.count)개")
    }
    
    /// VisitPlaceEntity 생성
    private func createVisitPlaceEntity(from plan: PlanModel, schedule: ScheduleEntity, context: NSManagedObjectContext) -> PlanEntity {
        let entity = PlanEntity(context: context)
        entity.uid = plan.uid
        entity.index = Int32(plan.index)
        entity.memo = plan.memo
        entity.schedule = schedule
        
        return entity
    }
    
    /// Entity → Model 변환
    private func convertToScheduleModel(_ entity: ScheduleEntity) -> ScheduleModel? {
        guard let uid = entity.uid,
              let title = entity.title,
              let editDate = entity.editDate,
              let dDay = entity.d_day else {
            print("LocalVM, convertToScheduleModel // Warning : 필수 필드 누락 - entity 변환 실패")
            return nil
        }
        
        var planList: [PlanModel] = []
        
        if let plans = entity.planList as? Set<PlanEntity> {
            let sortedPlans = plans.sorted { $0.index < $1.index }
            planList = sortedPlans.compactMap { convertToVisitPlaceModel($0) }
        }
        
        return ScheduleModel(
            uid: uid,
            index: Int(entity.index),
            title: title,
            memo: entity.memo ?? "",
            editDate: editDate,
            d_day: dDay,
            planList: planList
        )
    }
    
    /// VisitPlaceEntity → VisitPlaceModel 변환
    private func convertToVisitPlaceModel(_ entity: PlanEntity) -> PlanModel? {
        guard let uid = entity.uid else {
            print("LocalVM, convertToVisitPlaceModel // Warning : VisitPlace uid 누락")
            return nil
        }
        
        // TODO: 실제 PlaceModel, FileModel 변환 구현
        let emptyPlace = PlaceModel.empty()
        
        return PlanModel(
            uid: uid,
            index: Int(entity.index),
            memo: entity.memo ?? "",
            placeModel: PlaceModel.empty(),
            files: []
        )
    }
    
    deinit {
        cancellables.removeAll()
        clearMemoryCache()
        print("LocalVM, deinit // Success : 모든 리소스 해제 완료")
    }
       
}
