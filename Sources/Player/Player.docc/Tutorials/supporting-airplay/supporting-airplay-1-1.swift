import AVFAudio

func configureAudioSession() {
    try? AVAudioSession.sharedInstance().setCategory(.playback)
}
