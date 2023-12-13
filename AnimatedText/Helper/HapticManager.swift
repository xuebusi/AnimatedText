//
//  HapticManager.swift
//  AnimatedText
//
//  Created by Damra on 27.11.2023.
//

import Foundation
import SwiftUI
import UIKit

class HapticManager {
    //MARK: PROPERTIES
    static let shared = HapticManager()
    
    private var lightImpactGenerator: UIImpactFeedbackGenerator?
    
    //MARK: Initialization
    private init() {
        lightImpactGenerator = UIImpactFeedbackGenerator(style: .light)
        lightImpactGenerator?.prepare()
    }
    
    //MARK: Public Methods
    
    func generateFeedback() {
        lightImpactGenerator?.impactOccurred()
    }
}
