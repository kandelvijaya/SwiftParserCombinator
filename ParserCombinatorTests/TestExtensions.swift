//
//  Copyright © 2018 Vijaya Prakash Kandel. All rights reserved.
//

import Foundation

extension String {
    
    static var random:  String {
        let size = Int.Random.small
        let randomString = (0..<size).reduce("") { res, _ in
            return res + String(Character.random)
        }
        
        return randomString
    }
    
    static var uuidRand: String {
        return NSUUID().uuidString
    }
    
}


extension Character {
    
    static var random: Character {
        let aInt = Int("A".unicodeScalars.first!.value)
        let zInt = Int("z".unicodeScalars.first!.value)
        let difference = zInt - aInt
        
        var randomC: Character {
            let point = aInt + Int(arc4random_uniform(UInt32(difference)))
            let unicodeScalar = UnicodeScalar(point)!
            return Character(unicodeScalar)
        }
        return randomC
    }
    
}

extension Int {
    
    struct Random {
        static var small: Int {
            return Int(arc4random_uniform(16))
        }
        
        static var big: Int {
            return Int(arc4random_uniform(255))
        }
        
        static var rand: Int {
            return Int(arc4random())
        }
    }
}
