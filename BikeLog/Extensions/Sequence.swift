//
//  Sequence.swift
//  Bike Log
//
//  Created by Ameir Al-Zoubi on 1/16/22.
//

import Foundation

extension Sequence {
    func sorted<T: Comparable>(comparingKeyPath keyPath: KeyPath<Element, T>, ascending: Bool = true) -> [Element] {
        return self.sorted(by: { ($0[keyPath: keyPath] < $1[keyPath: keyPath]) == ascending })
    }
}
