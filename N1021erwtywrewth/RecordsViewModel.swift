//
//  RecordsViewModel.swift
//  N1021erwtywrewth
//
//  Created by Agent on 24.10.2025.
//

import Foundation
import SwiftUI
import Combine

class RecordsViewModel: ObservableObject {
    @Published var records: GameRecords {
        didSet {
            saveRecords()
        }
    }
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "gameRecords"),
           let records = try? JSONDecoder().decode(GameRecords.self, from: data) {
            self.records = records
        } else {
            self.records = GameRecords()
        }
    }
    
    func saveRecords() {
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: "gameRecords")
        }
    }
    
    func resetRecords() {
        records = GameRecords()
    }
}
