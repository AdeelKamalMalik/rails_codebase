import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["target", "template", "flash", "addProductBtn"]
  static values = {
    wrapperSelector: {
      type: String,
      default: ".nested-form-wrapper",
    },
  }

  connect() {
    this.showFlashMessage();
    this.showAddProductBtn();
  }

  focusProduct() {
    document.getElementById(event.currentTarget.dataset.productId).scrollIntoView({
      behavior: "smooth",
      block: "start"
    })
  }

  add(e) {
    e.preventDefault()

    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime().toString());
    this.targetTarget.insertAdjacentHTML("afterbegin", `<div class="animate-fade-up">${content}</div>`);

    const event = new CustomEvent("products:add", {
      bubbles: true
    })
    this.element.dispatchEvent(event)
  }

  beforeRemove(e) {
    e.currentTarget.parentNode.classList.add("animate-fake")
    const id = e.target.closest(this.wrapperSelectorValue).lastElementChild.id
    document.getElementById(id).classList.remove("hidden")
  }

  closeModal(e) {
    document.getElementById(e.currentTarget.dataset.id).classList.add("hidden")
  }

  remove(e) {
    e.preventDefault()
    const wrapper = e.target.closest(this.wrapperSelectorValue)

    const id = wrapper.lastElementChild.id
    if (wrapper.dataset.newRecord === "true") {
      wrapper.classList.add("animate-fade-left")
      document.getElementById(id).classList.add("hidden")
      setTimeout(function() {
        wrapper.remove()
      }, 300)
    } else {
      wrapper.style.display = "none"

      const input = wrapper.querySelector("input[name*='_destroy']")
      input.value = "1"
      wrapper.closest("form").requestSubmit()
    }

    const event = new CustomEvent("products:remove", {
      bubbles: true
    })
    this.element.dispatchEvent(event)
  }

  showAddProductBtn() {
    if (this.hasFlashTarget && this.hasAddProductBtnTarget) {
      this.addProductBtnTarget.classList.remove("hidden");
    }
  }

  showFlashMessage() {
    if (this.hasFlashTarget) {
      const flashElement = this.flashTarget;
      if (flashElement && flashElement.dataset.turboStreamFlash === "true") {
        flashElement.style.display = "block";
        setTimeout(() => {
          flashElement.style.display = "none";
        }, 3000);
      }
    }
  }
}
