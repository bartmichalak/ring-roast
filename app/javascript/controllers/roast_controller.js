import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["card", "dot", "dotFill"]
  static values = { total: Number, index: { type: Number, default: 0 } }

  connect() {
    this.keydown = this.onKeydown.bind(this)
    window.addEventListener("keydown", this.keydown)
    this.element.addEventListener("touchstart", this.onTouchStart.bind(this), { passive: true })
    this.element.addEventListener("touchend", this.onTouchEnd.bind(this), { passive: true })
    this.render()
  }

  disconnect() {
    window.removeEventListener("keydown", this.keydown)
  }

  next() { this.go(this.indexValue + 1) }
  prev() { this.go(this.indexValue - 1) }

  close(event) {
    event?.preventDefault()
    if (window.history.length > 1) {
      window.history.back()
    } else {
      window.location.href = "/"
    }
  }

  go(target) {
    if (this.totalValue <= 0) return
    if (target < 0 || target >= this.totalValue) return
    this.indexValue = target
    this.render()
  }

  render() {
    this.cardTargets.forEach((card, i) => {
      const active = i === this.indexValue
      card.style.opacity = active ? "1" : "0"
      card.style.pointerEvents = active ? "auto" : "none"
    })
    this.dotFillTargets.forEach((fill, i) => {
      fill.style.width = i < this.indexValue ? "100%" : (i === this.indexValue ? "100%" : "0%")
    })
  }

  onKeydown(event) {
    if (event.key === "ArrowRight" || event.key === " " || event.key === "Enter") {
      event.preventDefault()
      this.next()
    } else if (event.key === "ArrowLeft") {
      event.preventDefault()
      this.prev()
    } else if (event.key === "Escape") {
      event.preventDefault()
      this.close()
    }
  }

  onTouchStart(event) {
    this.touchStartX = event.touches[0].clientX
    this.touchStartY = event.touches[0].clientY
  }

  onTouchEnd(event) {
    if (this.touchStartX == null) return
    const dx = event.changedTouches[0].clientX - this.touchStartX
    const dy = event.changedTouches[0].clientY - this.touchStartY
    this.touchStartX = null
    if (Math.abs(dx) < 40 || Math.abs(dx) < Math.abs(dy)) return
    if (dx < 0) this.next()
    else this.prev()
  }
}
