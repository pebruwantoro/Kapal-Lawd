//
//  Delay.swift
//  Kapal-Lawd
//
//  Created by Doni Pebruwantoro on 29/10/24.
//

import Foundation

func delay(_ seconds: Double, completion: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
        completion()
    }
}
