//
//  Places.swift
//  FoursquareClone
//
//  Created by İlhan Cüvelek on 4.02.2024.
//

import Foundation
import UIKit

class Places{  // Singleton
    
    static let sharedInstance = Places()
    
    var placeName=""
    var placeType=""
    var placeAtmosphere=""
    var image=UIImage()
    var latitude=""
    var longitude=""
    
    private init(){
        
    }
}
