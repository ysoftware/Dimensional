//
//  SoundManager.swift
//  Dimensional
//
//  Created by Ярослав Ерохин on 21.11.16.
//  Copyright © 2016 Yaroslav Erohin. All rights reserved.
//

import Foundation

@objc final class SoundManager:NSObject {

    // MARK: - Singleton

    @objc public static let shared = SoundManager()

	private override init() {
//		musicPlayer = AKPlayer()
//		effectsPlayer = AKPlayer()
//
//		eq = AKLowPassFilter(musicPlayer, cutoffFrequency: 20000, resonance: 15)
//		let mixer = AKMixer([eq, effectsPlayer])
//
//		AudioKit.output = mixer
//		try! AudioKit.start()
	}

    // MARK: - Properties

//	let musicPlayer:AKPlayer
//	let effectsPlayer:AKPlayer
//	let eq:AKLowPassFilter

    // MARK: - Methods

	@objc func playMenuMusic() { play("menu.mp3", .music) }

	@objc func playGameMusic() { play("game.mp3", .music) }

	@objc func hitEnemy() {
//		eq.cutoffFrequency = 50
//		play("shield.mp3")
//
//		animate { timer in
//			self.eq.cutoffFrequency *= 4
//			if (self.eq.cutoffFrequency > 20000) {
//				timer.cancel()
//			}
//		}
	}

	@objc func died() {
//		animate { timer in
//			self.eq.cutoffFrequency /= 4
//			if (self.eq.cutoffFrequency < 100) {
//				timer.cancel()
//				self.musicPlayer.stop()
//			}
//		}
	}

	private func play(_ name:String, _ p:Player = .fx) {
//		let player = p == .fx ? effectsPlayer : musicPlayer
//		player.stop()
//		player.load(audioFile: try! AKAudioFile(readFileName: name))
//		player.start(at: AVAudioTime(hostTime: 0))
	}

	enum Player { case music, fx }
}

func animate(_ ms:Int = 250, _ block: @escaping (DispatchSourceTimer)->Void) {
	let timer = DispatchSource.makeTimerSource()
	timer.schedule(deadline: .now(), repeating: .milliseconds(ms), leeway: .milliseconds(ms/5))
	timer.setEventHandler { block(timer) }
	timer.resume()
}
