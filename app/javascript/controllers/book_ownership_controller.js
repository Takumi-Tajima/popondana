import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "categoryList", "newCategoryInput"]
  
  connect() {
    console.log('BookOwnership controller connected')
    console.log('Bootstrap available:', typeof bootstrap !== 'undefined')
    
    // モーダルの初期化
    if (this.hasModalTarget && typeof bootstrap !== 'undefined') {
      this.modal = new bootstrap.Modal(this.modalTarget)
      console.log('Modal initialized')
    } else {
      console.log('Modal target not found or Bootstrap not available')
    }
    
    // 「持ってる」ボタンのクリックイベントを設定
    document.addEventListener('click', (event) => {
      if (event.target.matches('.own-book-btn')) {
        console.log('Own book button clicked')
        this.openModal(event)
      }
    })
  }
  
  openModal(event) {
    console.log('Opening modal')
    const button = event.target
    this.bookData = JSON.parse(button.dataset.book)
    console.log('Book data:', this.bookData)
    
    // カテゴリリストをリセット
    if (this.hasCategoryListTarget) {
      this.categoryListTarget.innerHTML = ''
    }
    
    // 既存のカテゴリを取得して表示
    this.loadCategories()
    
    // モーダルを表示
    if (this.modal) {
      this.modal.show()
      console.log('Modal shown')
    } else {
      console.log('Modal not available')
    }
  }
  
  async loadCategories() {
    try {
      const response = await fetch('/api/categories', {
        headers: {
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        }
      })
      
      if (response.ok) {
        const categories = await response.json()
        
        categories.forEach(category => {
          const checkbox = this.createCategoryCheckbox(category)
          if (this.hasCategoryListTarget) {
            this.categoryListTarget.appendChild(checkbox)
          }
        })
      }
    } catch (error) {
      console.error('カテゴリの取得に失敗しました:', error)
    }
  }
  
  createCategoryCheckbox(category) {
    const div = document.createElement('div')
    div.className = 'form-check'
    
    const input = document.createElement('input')
    input.type = 'checkbox'
    input.className = 'form-check-input'
    input.id = `category_${category.id}`
    input.value = category.id
    input.name = 'category_ids[]'
    
    const label = document.createElement('label')
    label.className = 'form-check-label'
    label.htmlFor = `category_${category.id}`
    label.textContent = category.name
    
    div.appendChild(input)
    div.appendChild(label)
    
    return div
  }
  
  addNewCategory() {
    if (!this.hasNewCategoryInputTarget) return
    
    const categoryName = this.newCategoryInputTarget.value.trim()
    
    if (categoryName) {
      const hiddenInput = document.createElement('input')
      hiddenInput.type = 'hidden'
      hiddenInput.name = 'new_categories[]'
      hiddenInput.value = categoryName
      this.element.appendChild(hiddenInput)
      
      // 表示用のバッジを追加
      const badge = document.createElement('span')
      badge.className = 'badge bg-primary me-2 mb-2'
      badge.textContent = categoryName
      
      const closeBtn = document.createElement('button')
      closeBtn.type = 'button'
      closeBtn.className = 'btn-close btn-close-white ms-1'
      closeBtn.style.fontSize = '0.7rem'
      closeBtn.onclick = () => {
        badge.remove()
        hiddenInput.remove()
      }
      
      badge.appendChild(closeBtn)
      if (this.hasCategoryListTarget) {
        this.categoryListTarget.appendChild(badge)
      }
      
      // 入力欄をクリア
      if (this.hasNewCategoryInputTarget) {
        this.newCategoryInputTarget.value = ''
      }
    }
  }
  
  async save() {
    const formData = new FormData()
    formData.append('book_data', JSON.stringify(this.bookData))
    
    // 選択されたカテゴリIDを収集
    const checkedCategories = this.element.querySelectorAll('input[name="category_ids[]"]:checked')
    checkedCategories.forEach(checkbox => {
      formData.append('category_ids[]', checkbox.value)
    })
    
    // 新しいカテゴリを収集
    const newCategories = this.element.querySelectorAll('input[name="new_categories[]"]')
    newCategories.forEach(input => {
      formData.append('new_categories[]', input.value)
    })
    
    try {
      const response = await fetch('/ownerships', {
        method: 'POST',
        headers: {
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: formData
      })
      
      const result = await response.json()
      
      if (result.status === 'success') {
        // モーダルを閉じる
        this.modal.hide()
        
        // ボタンを無効化
        const button = document.querySelector(`.own-book-btn[data-book*="${this.bookData.isbn}"]`)
        if (button) {
          button.textContent = '所有済み'
          button.disabled = true
          button.classList.remove('btn-primary')
          button.classList.add('btn-secondary')
        }
        
        // 成功メッセージを表示
        this.showFlashMessage('書籍を登録しました。')
      } else {
        alert('エラーが発生しました: ' + result.errors.join(', '))
      }
    } catch (error) {
      console.error('保存に失敗しました:', error)
      alert('保存に失敗しました。')
    }
  }
  
  showFlashMessage(message) {
    const alert = document.createElement('div')
    alert.className = 'alert alert-success alert-dismissible fade show'
    alert.innerHTML = `
      ${message}
      <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    `
    
    const container = document.querySelector('.container')
    container.insertBefore(alert, container.firstChild)
    
    // 3秒後に自動的に消す
    setTimeout(() => {
      alert.remove()
    }, 3000)
  }
}