import { Modal } from "bootstrap"

export const BsModal = {
    mounted() {
        const modal = new Modal(this.el)
        modal.show()

        this.el.addEventListener('hidden.bs.modal', event => {
            this.pushEventTo(`#${this.el.getAttribute('id')}`, 'close', {})
            modal.dispose()
        })
        this.el.querySelector('form').addEventListener('submit', event => {
            const backdrop = document.querySelector('.modal-backdrop')
            if (backdrop) backdrop.parentElement.removeChild(backdrop)
        })
    }
}