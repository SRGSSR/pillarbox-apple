import AVFAudio

/*
You can activate the audio session at any time after setting its category,
but it’s generally preferable to defer this call until your app begins audio playback.
Deferring the call ensures that you won’t prematurely interrupt
any other background audio that may be in progress.
*/
func configureAudioSession() {
    try? AVAudioSession.sharedInstance().setCategory(.playback)
}
