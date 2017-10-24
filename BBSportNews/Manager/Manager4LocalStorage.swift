//
//  Manager4LocalStorage.swift
//  BBSportNews
//
//  Created by dat on 10/24/17.
//  Copyright © 2017 dat. All rights reserved.
//

import Foundation


class Manager4LocalStorage{
    public static let shared = Manager4LocalStorage()

    func getDocumentsDirectory() -> String? {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return path
    }
    func getCachesDirectory() -> String? {
        let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        return path
    }
}
