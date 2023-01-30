//
//  VibravionService.swift
//  Notes
//
//  Created by Дмитрий Никоноров on 27.01.2023.
//

import Foundation
import UIKit

protocol Vibrationable {
    func vibrate(state: VibrationState)
}

enum VibrationState {
    case error
    case success
    case warning
    case light
    case medium
    case heavy
    case selection
}

class Vibration: Vibrationable {

func vibrate(state: VibrationState) {
      switch state {
      case .error:
          let generator = UINotificationFeedbackGenerator()
          generator.notificationOccurred(.error)

      case .success:
          let generator = UINotificationFeedbackGenerator()
          generator.notificationOccurred(.success)

      case .warning:
          let generator = UINotificationFeedbackGenerator()
          generator.notificationOccurred(.warning)

      case .light:
          let generator = UIImpactFeedbackGenerator(style: .light)
          generator.impactOccurred()

      case .medium:
          let generator = UIImpactFeedbackGenerator(style: .medium)
          generator.impactOccurred()

      case .heavy:
          let generator = UIImpactFeedbackGenerator(style: .heavy)
          generator.impactOccurred()

      case .selection:
          let generator = UISelectionFeedbackGenerator()
          generator.selectionChanged()
      }
    }
}
