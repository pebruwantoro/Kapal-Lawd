//
//  Converter.swift
//  Kapal-Lawd
//
//  Created by Doni Pebruwantoro on 29/10/24.
//
import Foundation

func convertSecondsToTimeString(seconds: Double) -> String {
    let totalMinutes = Int(seconds) / 60
    let totalSeconds = Int(seconds) % 60
    
    let timeString = String(format: "%02d:%02d", totalMinutes, totalSeconds)
    return timeString
}

func convertToSeconds(from timeString: String) -> Double? {
    let components = timeString.split(separator: ":")
    
    guard components.count == 2,
          let minutes = Double(components[0]),
          let seconds = Double(components[1])
    else {
        return nil
    }
    
    let totalSeconds = (minutes * 60) + seconds
    return totalSeconds
}

func formattedDate(_ dateString: String) -> String {
    let inputFormatter = DateFormatter()
    inputFormatter.dateFormat = "yyyy-MM-dd"
    
    if let newDate = inputFormatter.date(from: dateString) {
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd MMMM yyyy"
        
        let formattedDateString = outputFormatter.string(from: newDate)
        
        return formattedDateString
    }
    
    return ""
}
