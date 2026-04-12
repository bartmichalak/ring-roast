import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["card", "dot"]
  static values = { index: { type: Number, default: 0 }, total: Number }

  connect() {
    this.showCard(this.indexValue)
    this.boundKeyHandler = this.handleKeydown.bind(this)
    document.addEventListener("keydown", this.boundKeyHandler)
    this.element.addEventListener("touchstart", this.touchStart.bind(this), { passive: true })
    this.element.addEventListener("touchend", this.touchEnd.bind(this), { passive: true })
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundKeyHandler)
  }

  handleKeydown(event) {
    if (event.key === "ArrowRight" || event.key === "ArrowDown") {
      event.preventDefault()
      this.next()
    } else if (event.key === "ArrowLeft" || event.key === "ArrowUp") {
      event.preventDefault()
      this.previous()
    } else if (event.key === "Escape") {
      window.location.href = "/"
    }
  }

  next() {
    if (this.indexValue < this.totalValue - 1) {
      this.indexValue++
      this.showCard(this.indexValue)
    }
  }

  previous() {
    if (this.indexValue > 0) {
      this.indexValue--
      this.showCard(this.indexValue)
    }
  }

  showCard(index) {
    this.cardTargets.forEach((card, i) => {
      if (i < index) {
        card.style.transform = "translateX(-100%)"
        card.style.opacity = "0"
      } else if (i === index) {
        card.style.transform = "translateX(0)"
        card.style.opacity = "1"
      } else {
        card.style.transform = "translateX(100%)"
        card.style.opacity = "0"
      }
    })

    this.dotTargets.forEach((dot, i) => {
      if (i === index) {
        dot.classList.add("bg-white", "scale-125")
        dot.classList.remove("bg-white/30")
      } else {
        dot.classList.remove("bg-white", "scale-125")
        dot.classList.add("bg-white/30")
      }
    })
  }

  touchStart(event) {
    this.touchStartX = event.changedTouches[0].screenX
  }

  touchEnd(event) {
    const diff = this.touchStartX - event.changedTouches[0].screenX
    if (Math.abs(diff) > 50) {
      diff > 0 ? this.next() : this.previous()
    }
  }
}
