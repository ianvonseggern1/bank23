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
  // TODO persist in user defaults
  var audioOn = true
  
  func toggleAudio() {
    audioOn = !audioOn
  }
  
  func playKerplunk() {
    playSound(name: "kerplunk-sound", extensionName: "wav", soundId: 0)
  }
  
  func playChaChing() {
    playSound(name: "cha-ching", extensionName: "wav", soundId: 1)
  }
  
  private func playSound(name: String, extensionName: String, soundId: Int) {
    if !audioOn {
      return
    }
    
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
