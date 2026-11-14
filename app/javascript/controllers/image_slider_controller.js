import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["slide"]

  connect() {
    this.currentIndex = 0
    this.showSlide()
  }

  next() {
    this.currentIndex =
      (this.currentIndex + 1) % this.slideTargets.length

    this.showSlide()
  }

  previous() {
    this.currentIndex =
      (this.currentIndex - 1 + this.slideTargets.length) %
      this.slideTargets.length

    this.showSlide()
  }

  showSlide() {
    this.slideTargets.forEach((slide, index) => { slide.classList.toggle("hidden", index !== this.currentIndex) })
  }
}