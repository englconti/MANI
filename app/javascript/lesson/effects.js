// Confetti and fireworks on a canvas laid over the page, for the end of a lesson.
// No library: a few dozen coloured particles, moved on every animation frame, and the canvas
// is removed when they are gone.

const COLORS = ["#f26b54", "#ffc800", "#0e6b78", "#f6a98a", "#3fb06b", "#ffffff"]

function random(min, max) {
  return min + Math.random() * (max - min)
}

function pick(list) {
  return list[Math.floor(Math.random() * list.length)]
}

// stars: 1 a little confetti, 2 more of it, 3 a lot plus fireworks.
// Returns a function that stops the effect early.
export function launchCelebration(stars = 1) {
  const canvas = document.createElement("canvas")
  canvas.className = "celebration-canvas"
  canvas.setAttribute("aria-hidden", "true")
  document.body.appendChild(canvas)

  const ratio = window.devicePixelRatio || 1
  const width = window.innerWidth
  const height = window.innerHeight
  canvas.width = width * ratio
  canvas.height = height * ratio
  const ctx = canvas.getContext("2d")
  ctx.scale(ratio, ratio)

  const confetti = []
  const sparks = []
  const started = performance.now()
  const confettiTotal = { 1: 50, 2: 100, 3: 150 }[stars] || 50
  let spawned = 0
  let nextBurst = stars >= 3 ? 400 : Infinity
  let bursts = 0
  let frame

  function spawnConfetti(count) {
    for (let i = 0; i < count; i++) {
      confetti.push({
        x: random(0, width), y: random(-40, -8),
        vx: random(-1.2, 1.2), vy: random(2.2, 4.4),
        angle: random(0, Math.PI * 2), spin: random(-0.25, 0.25),
        w: random(6, 11), h: random(10, 16), color: pick(COLORS), sway: random(0, Math.PI * 2)
      })
    }
    spawned += count
  }

  function burst() {
    const cx = random(width * 0.18, width * 0.82)
    const cy = random(height * 0.14, height * 0.45)
    const color = pick(COLORS.slice(0, 5))
    for (let i = 0; i < 44; i++) {
      const angle = (Math.PI * 2 * i) / 44
      const speed = random(2.2, 5.6)
      sparks.push({ x: cx, y: cy, vx: Math.cos(angle) * speed, vy: Math.sin(angle) * speed, life: 1, color })
    }
    bursts += 1
  }

  function step(now) {
    const elapsed = now - started
    ctx.clearRect(0, 0, width, height)

    // Confetti keeps coming for about two seconds
    if (spawned < confettiTotal && elapsed < 2200) spawnConfetti(Math.min(6, confettiTotal - spawned))
    if (elapsed > nextBurst && bursts < 5) {
      burst()
      nextBurst += random(450, 800)
    }

    for (let i = confetti.length - 1; i >= 0; i--) {
      const piece = confetti[i]
      piece.sway += 0.06
      piece.x += piece.vx + Math.sin(piece.sway) * 0.8
      piece.y += piece.vy
      piece.angle += piece.spin
      if (piece.y > height + 30) { confetti.splice(i, 1); continue }
      ctx.save()
      ctx.translate(piece.x, piece.y)
      ctx.rotate(piece.angle)
      ctx.fillStyle = piece.color
      ctx.strokeStyle = "#1b1411"
      ctx.lineWidth = 1.2
      ctx.fillRect(-piece.w / 2, -piece.h / 2, piece.w, piece.h)
      ctx.strokeRect(-piece.w / 2, -piece.h / 2, piece.w, piece.h)
      ctx.restore()
    }

    for (let i = sparks.length - 1; i >= 0; i--) {
      const spark = sparks[i]
      spark.vy += 0.07
      spark.vx *= 0.985
      spark.x += spark.vx
      spark.y += spark.vy
      spark.life -= 0.014
      if (spark.life <= 0) { sparks.splice(i, 1); continue }
      ctx.globalAlpha = Math.max(spark.life, 0)
      ctx.fillStyle = spark.color
      ctx.beginPath()
      ctx.arc(spark.x, spark.y, 2.6, 0, Math.PI * 2)
      ctx.fill()
    }
    ctx.globalAlpha = 1

    const finished = confetti.length === 0 && sparks.length === 0 && spawned >= confettiTotal && (bursts >= 5 || stars < 3)
    if (finished || elapsed > 9000) return stop()
    frame = requestAnimationFrame(step)
  }

  function stop() {
    cancelAnimationFrame(frame)
    canvas.remove()
  }

  frame = requestAnimationFrame(step)
  return stop
}
