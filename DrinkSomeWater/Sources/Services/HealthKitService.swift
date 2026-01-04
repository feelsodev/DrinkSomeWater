import Foundation
import HealthKit

protocol HealthKitServiceProtocol: AnyObject {
    var isAvailable: Bool { get }
    func requestAuthorization() async -> Bool
    func fetchWeight() async -> Double?
    func saveWaterIntake(_ ml: Double, date: Date) async -> Bool
    func fetchTodayWaterIntake() async -> Double
}

final class HealthKitService: BaseService, HealthKitServiceProtocol {
    
    private let healthStore = HKHealthStore()
    
    private var weightType: HKQuantityType? {
        HKQuantityType.quantityType(forIdentifier: .bodyMass)
    }
    
    private var waterType: HKQuantityType? {
        HKQuantityType.quantityType(forIdentifier: .dietaryWater)
    }
    
    var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }
    
    func requestAuthorization() async -> Bool {
        guard isAvailable,
              let weightType = weightType,
              let waterType = waterType else {
            return false
        }
        
        let readTypes: Set<HKObjectType> = [weightType, waterType]
        let writeTypes: Set<HKSampleType> = [waterType]
        
        do {
            try await healthStore.requestAuthorization(toShare: writeTypes, read: readTypes)
            return true
        } catch {
            return false
        }
    }
    
    func fetchWeight() async -> Double? {
        guard let weightType = weightType else { return nil }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: weightType,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, _ in
                guard let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: nil)
                    return
                }
                let weightInKg = sample.quantity.doubleValue(for: .gramUnit(with: .kilo))
                continuation.resume(returning: weightInKg)
            }
            healthStore.execute(query)
        }
    }
    
    func saveWaterIntake(_ ml: Double, date: Date = Date()) async -> Bool {
        guard let waterType = waterType else { return false }
        
        let quantity = HKQuantity(unit: .literUnit(with: .milli), doubleValue: ml)
        let sample = HKQuantitySample(type: waterType, quantity: quantity, start: date, end: date)
        
        do {
            try await healthStore.save(sample)
            return true
        } catch {
            return false
        }
    }
    
    func fetchTodayWaterIntake() async -> Double {
        guard let waterType = waterType else { return 0 }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? Date()
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: waterType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, _ in
                let totalMl = samples?
                    .compactMap { $0 as? HKQuantitySample }
                    .reduce(0.0) { $0 + $1.quantity.doubleValue(for: .literUnit(with: .milli)) } ?? 0
                continuation.resume(returning: totalMl)
            }
            healthStore.execute(query)
        }
    }
}
