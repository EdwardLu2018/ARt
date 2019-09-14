//
//  Extensions.swift
//  ARt
//
//  Created by Edward on 9/14/19.
//  Copyright © 2019 Edward. All rights reserved.
//

extension FloatingPoint {
    var degreesToRadians : Self {
        return self * .pi / 180
    }
    var radiansToDegrees : Self {
        return self * 180 / .pi
    }
}
