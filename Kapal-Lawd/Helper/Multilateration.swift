//
//  Multilateration.swift
//  Kapal-Lawd
//
//  Created by Doni Pebruwantoro on 13/11/24.
//

import Foundation

func multilateration(data: [BeaconData]) -> [DetectedBeacon]{
    guard data.count >= 3 else {
        print(ErrorHandler.errorMultilateration.errorDescription!)
        return []
    }
    
    var A = [[Double]]()
    var B = [Double]()
    
//    let refPoint = data[0].position
    let refPoint = Point(xPosition: 0.0, yPosition: 0.0)
    let d1 = data[0].distance
    
    for i in 1..<data.count{
        let position = data[i].position
        let di = data[i].distance
        
        let rowA = [
            2 * (position.xPosition - refPoint.xPosition),
            2 * (position.yPosition - refPoint.yPosition),
        ]
        
        let bValue = pow(d1, 2) - pow(di, 2) - pow(refPoint.xPosition, 2) + pow(position.xPosition, 2) - pow(refPoint.yPosition, 2) + pow(position.yPosition, 2)
        
        A.append(rowA)
        B.append(bValue)
    }
    
    let matrixA = A
    let vectorB = B
    
    let AT = transpose(matrixA)
    let ATA = matrixMultiply(AT, matrixA)
    let ATB = matrixVectorMultiply(AT, vectorB)
    
    guard let solution = solveLinearSystem(ATA, ATB) else {
        print(ErrorHandler.errorSolveLinearSystem.errorDescription!)
        return []
    }
    
    let estimatedPosition = Point(xPosition: solution[0], yPosition: solution[1])
    
    var detectedBeacons: [DetectedBeacon] = []
    
    for beacon in data{
        let euclideanDistance = euclideanDistanace(beaconPosition: beacon.position, targetPosition: estimatedPosition)
        
        let detectedBeacon = DetectedBeacon(
            uuid: beacon.uuid,
            estimatedDitance: beacon.distance,
            euclideanDistance: euclideanDistance,
            averageDistance: abs(beacon.distance+euclideanDistance) / 2,
            userPosition: estimatedPosition
        )
        
        detectedBeacons.append(detectedBeacon)
    }
    
    return Array(Set(detectedBeacons))
}

private func euclideanDistanace(beaconPosition: Point, targetPosition: Point) -> Double {
    return sqrt(pow(beaconPosition.xPosition - targetPosition.xPosition, 2) + pow(beaconPosition.yPosition, targetPosition.yPosition))
}

private func transpose(_ matrix: [[Double]]) -> [[Double]] {
    let rows = matrix.count
    let cols = matrix[0].count
    var transposed = Array(repeating: Array(repeating: 0.0, count: rows), count: cols)
    for i in 0..<rows {
        for j in 0..<cols {
            transposed[j][i] = matrix[i][j]
        }
    }
    return transposed
}

private func matrixMultiply(_ A: [[Double]], _ B: [[Double]]) -> [[Double]] {
    let rowsA = A.count
    let colsA = A[0].count
    let colsB = B[0].count
    var result = Array(repeating: Array(repeating: 0.0, count: colsB), count: rowsA)
    for i in 0..<rowsA {
        for j in 0..<colsB {
            for k in 0..<colsA {
                result[i][j] += A[i][k] * B[k][j]
            }
        }
    }
    return result
}

private func matrixVectorMultiply(_ A: [[Double]], _ B: [Double]) -> [Double] {
    let rowsA = A.count
    let colsA = A[0].count
    var result = Array(repeating: 0.0, count: rowsA)
    for i in 0..<rowsA {
        for j in 0..<colsA {
            result[i] += A[i][j] * B[j]
        }
    }
    return result
}

private func solveLinearSystem(_ A: [[Double]], _ B: [Double]) -> [Double]? {
    var augmentedMatrix = A
    let n = B.count
    
    for i in 0..<n {
        augmentedMatrix[i].append(B[i])
    }
    
    for i in 0..<n {
        if augmentedMatrix[i][i] == 0 {
            for k in i+1..<n {
                if augmentedMatrix[k][i] != 0 {
                    augmentedMatrix.swapAt(i, k)
                    break
                }
            }
        }
        
        let pivot = augmentedMatrix[i][i]
        guard pivot != 0 else { return nil }
        
        for j in i..<n+1 {
            augmentedMatrix[i][j] /= pivot
        }
        
        for k in i+1..<n {
            let factor = augmentedMatrix[k][i]
            for j in i..<n+1 {
                augmentedMatrix[k][j] -= factor * augmentedMatrix[i][j]
            }
        }
    }
    
    var x = Array(repeating: 0.0, count: n)
    for i in stride(from: n - 1, through: 0, by: -1) {
        x[i] = augmentedMatrix[i][n]
        for j in i+1..<n {
            x[i] -= augmentedMatrix[i][j] * x[j]
        }
    }
    
    return x
}
