//
//  Preferences.swift
//  EggTimer
//
//  Created by urjhams on 9/14/18.
//  Copyright © 2018 urjhams. All rights reserved.
//

import Foundation

struct Preferences {
    /// The time for the egg to be boiled
    var selectedTime: TimeInterval {
        get {
            let savedTime = UserDefaults.standard.double(forKey: "selectedTime")
            return savedTime > 0 ? savedTime : 360
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "selectedTime")
        }
    }
}
