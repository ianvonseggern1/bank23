//
//  NoiseEffectsController.swift
//  Bank23
//
//  Created by Ian Vonseggern on 12/17/17.
//  Copyright © 2017 Ian Vonseggern. All rights reserved.
//

import Foundation
import AudioToolbox
import AVFoundation

let AUDIO_SETTING_USER_DEFAULT_KEY = "AudioSetting"

public final class NoiseEffectsController
{
  var audioOn = true
  
  init() {
    let audioDefault = UserDefaults.standard.object(forKey: AUDIO_SETTING_USER_DEFAULT_KEY) as! Bool?
    audioOn = audioDefault == nil ? true : audioDefault!
    
    try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback,
                                                     with: [.mixWithOthers])
  }
  
  func toggleAudio() {
    audioOn = !audioOn
    
    UserDefaults.standard.set(audioOn, forKey: AUDIO_SETTING_USER_DEFAULT_KEY)
    UserDefaults.standard.synchronize()
  }
  
  func playKerplunk() {
    playSound(name: "Plunk 2", extensionName: "wav", soundId: 0)
  }
  
  func playChaChing() {
    playSound(name: "Coins 4", extensionName: "wav", soundId: 1)
  }
  
  func playSwish() {
    playSound(name: "Swish 1", extensionName: "wav", soundId: 2)
  }
  
  func playSlide() {
    playSound(name: "Slide 1", extensionName: "wav", soundId: 3)
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
