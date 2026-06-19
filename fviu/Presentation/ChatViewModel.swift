//
//  ViewModel.swift
//  fviu
//
//  Created by lilit on 19.06.26.
//
import Foundation
@MainActor
public class ChatViewModel {
    public var todayDateString: String {
        Date().formatted(date: .abbreviated, time: .omitted)
    }
    
    public var customTodayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.YYYY"
        return formatter.string(from: Date())
    }
}
