//
//  NoiseEffectsController.swift
//  Bank23
//
//  Created by Ian Vonseggern on 12/17/17.
//  Copyright © 2017 Ian Vonseggern. All rights reserved.
//

import Foundation
import AudioToolbox

let AUDIO_SETTING_USER_DEFAULT_KEY = "AudioSetting"

public final class NoiseEffectsController
{
  var audioOn = true
  
  init() {
    let audioDefault = UserDefaults.standard.object(forKey: AUDIO_SETTING_USER_DEFAULT_KEY) as! Bool?
    audioOn = audioDefault == nil ? true : audioDefault!
  }
  
  func toggleAudio() {
    audioOn = !audioOn
    
    UserDefaults.standard.set(audioOn, forKey: AUDIO_SETTING_USER_DEFAULT_KEY)
    UserDefaults.standard.synchronize()
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
