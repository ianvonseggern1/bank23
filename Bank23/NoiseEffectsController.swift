//
//  NoiseEffectsController.swift
//  Bank23
//
//  Created by Ian Vonseggern on 12/17/17.
//  Copyright © 2017 Ian Vonseggern. All rights reserved.
//

import Foundation
import AudioToolbox

public final class NoiseEffectsController
{
  static func playKerplunk() {
    NoiseEffectsController.playSound(name: "kerplunk-sound", extensionName: "wav", soundId: 0)
  }
  
  static func playChaChing() {
    NoiseEffectsController.playSound(name: "cha-ching", extensionName: "wav", soundId: 1)
  }
  
  private static func playSound(name: String, extensionName: String, soundId: Int) {
    if let soundUrl = Bundle.main.url(forResource: name, withExtension: extensionName) {
      var soundId: SystemSoundID = 0
      AudioServicesCreateSystemSoundID(soundUrl as CFURL, &soundId)
      AudioServicesAddSystemSoundCompletion(soundId, nil, nil, { (soundId, _) -> Void in
        AudioServicesDisposeSystemSoundID(soundId)
      }, nil)
      
      AudioServicesPlaySystemSound(soundId)
    }
  }
}
