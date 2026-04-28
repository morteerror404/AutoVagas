// components/notification.js
// Componente de notificação para o sistema AutoVagas

export function showToast(message, type = 'info') {
  const alertClass = {
    'info': 'alert-info',
    'success': 'alert-success',
    'warning': 'alert-warning',
    'error': 'alert-error'
  }[type] || 'alert-info'

  const toast = document.createElement('div')
  toast.className = 'toast toast-top toast-end z-50'
  toast.innerHTML = `
    <div class="${alertClass} shadow-lg">
      <span>${message}</span>
    </div>
  `
  
  document.body.appendChild(toast)
  
  setTimeout(() => {
    toast.remove()
  }, 3000)
}

export function showLoading(element) {
  if (element) {
    element.classList.add('loading', 'loading-spinner', 'loading-sm')
    element.disabled = true
  }
}

export function hideLoading(element) {
  if (element) {
    element.classList.remove('loading', 'loading-spinner', 'loading-sm')
    element.disabled = false
  }
}
