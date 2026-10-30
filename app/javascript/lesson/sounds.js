// Feedback sounds are synthesised with the Web Audio API, so the app needs no
// audio files and no third-party hosts.

const STORAGE_KEY = "mani-sound"
let audioContext

function context() {
  const AudioContext = window.AudioContext || window.webkitAudioContext
  if (!AudioContext) return null
  audioContext = audioContext || new AudioContext()
  return audioContext
}

// notes: [[frequency in Hz, duration in seconds], ...] played one after another
function play(notes) {
  if (!soundEnabled()) return
  const ctx = context()
  if (!ctx) return
  if (ctx.state === "suspended") ctx.resume()

  let start = ctx.currentTime
  notes.forEach(([frequency, duration]) => {
    const oscillator = ctx.createOscillator()
    const gain = ctx.createGain()
    oscillator.type = "sine"
    oscillator.frequency.value = frequency
    gain.gain.setValueAtTime(0.0001, start)
    gain.gain.exponentialRampToValueAtTime(0.25, start + 0.02)
    gain.gain.exponentialRampToValueAtTime(0.0001, start + duration)
    oscillator.connect(gain).connect(ctx.destination)
    oscillator.start(start)
    oscillator.stop(start + duration + 0.02)
    start += duration
  })
}

export function playCorrect() {
  play([[659, 0.1], [880, 0.18]])
}

export function playWrong() {
  play([[247, 0.16], [185, 0.26]])
}

export function soundEnabled() {
  try {
    return localStorage.getItem(STORAGE_KEY) !== "off"
  } catch (error) {
    return true
  }
}

export function setSoundEnabled(enabled) {
  try {
    localStorage.setItem(STORAGE_KEY, enabled ? "on" : "off")
  } catch (error) {
    // Storage can be blocked (private mode); the choice then lasts only for this page
  }
}
