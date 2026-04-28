// hooks/job_search.js
// Hook para melhorar a experiência de busca de vagas

export default {
  mounted() {
    this.setupSearchForm()
    this.setupJobInteractions()
  },

  setupSearchForm() {
    const form = this.el.querySelector('#search-form')
    if (!form) return

    // Auto-submit quando pressionar Enter em campos de texto
    form.querySelectorAll('input[type="text"]').forEach(input => {
      input.addEventListener('keydown', (e) => {
        if (e.key === 'Enter') {
          e.preventDefault()
          form.requestSubmit()
        }
      })
    })
  },

  setupJobInteractions() {
    // Lazy loading de vagas quando scrollar para o final
    this.handleEvent('new_jobs', ({ jobs }) => {
      if (jobs.length > 0) {
        this.showNotification(`${jobs.length} novas vagas encontradas`)
      }
    })
  },

  showNotification(message) {
    const notification = document.createElement('div')
    notification.className = 'toast toast-top toast-end'
    notification.innerHTML = `
      <div class="alert alert-info">
        <span>${message}</span>
      </div>
    `
    document.body.appendChild(notification)
    
    setTimeout(() => {
      notification.remove()
    }, 3000)
  }
}
