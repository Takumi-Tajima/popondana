import { Controller } from "@hotwired/stimulus"

// Chrome拡張機能のエラーをキャッチ
window.addEventListener('error', (event) => {
  if (event.message && event.message.includes('message port closed')) {
    console.warn('Chrome extension error detected, ignoring:', event.message)
    event.preventDefault()
  }
})

export default class extends Controller {
  static targets = ["modal", "categorySelect"]
  
  connect() {
    console.log('BookOwnership controller connected')
    console.log('Bootstrap available:', typeof bootstrap !== 'undefined')
    console.log('Has modal target:', this.hasModalTarget)
    
    // デバッグ情報を追加
    if (this.hasModalTarget) {
      console.log('Modal element:', this.modalTarget)
      console.log('Modal ID:', this.modalTarget.id)
    }
    
    // モーダルの初期化
    try {
      if (this.hasModalTarget && typeof bootstrap !== 'undefined') {
        this.modal = new bootstrap.Modal(this.modalTarget)
        console.log('Modal initialized successfully')
      } else {
        console.log('Modal target not found or Bootstrap not available')
      }
    } catch (error) {
      console.error('Error initializing modal:', error)
    }
    
    // 「持ってる」ボタンのクリックイベントを設定
    // Stimulusのdata-actionを使うため、このグローバルイベントリスナーは削除
  }
  
  openModal(event) {
    console.log('Opening modal')
    const button = event.target
    
    try {
      this.bookData = JSON.parse(button.dataset.book)
      console.log('Book data:', this.bookData)
    } catch (error) {
      console.error('Error parsing book data:', error)
      return
    }
    
    // Tom-selectを初期化
    this.initializeTomSelect()
    
    // モーダルを表示
    try {
      if (this.modal) {
        this.modal.show()
        console.log('Modal shown successfully')
      } else {
        console.log('Modal not available, trying to initialize')
        // モーダルが初期化されていない場合、再度初期化を試みる
        if (this.hasModalTarget && typeof bootstrap !== 'undefined') {
          this.modal = new bootstrap.Modal(this.modalTarget)
          this.modal.show()
          console.log('Modal initialized and shown')
        }
      }
    } catch (error) {
      console.error('Error showing modal:', error)
    }
  }
  
  async initializeTomSelect() {
    if (!this.hasCategorySelectTarget) return
    
    try {
      const response = await fetch('/api/categories', {
        headers: {
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        }
      })
      
      if (response.ok) {
        const categories = await response.json()
        
        // 既存の選択肢をクリア
        this.categorySelectTarget.innerHTML = ''
        
        // カテゴリをオプションとして追加
        categories.forEach(category => {
          const option = document.createElement('option')
          option.value = category.id
          option.textContent = category.name
          this.categorySelectTarget.appendChild(option)
        })
        
        // Tom-selectを初期化
        this.tomSelect = new TomSelect(this.categorySelectTarget, {
          plugins: ['remove_button'],
          create: true,
          createOnBlur: true,
          placeholder: 'カテゴリを選択または作成...',
          render: {
            option_create: function(data, escape) {
              return '<div class="create">新しいカテゴリ「<strong>' + escape(data.input) + '</strong>」を追加</div>';
            }
          }
        })
      }
    } catch (error) {
      console.error('カテゴリの取得に失敗しました:', error)
    }
  }
  
  async save() {
    const formData = new FormData()
    formData.append('book_data', JSON.stringify(this.bookData))
    
    // Tom-selectから選択された値を取得
    if (this.tomSelect) {
      const selectedValues = this.tomSelect.getValue()
      const existingCategories = []
      const newCategories = []
      
      selectedValues.forEach(value => {
        // 数値の場合は既存のカテゴリID、文字列の場合は新規カテゴリ名
        if (isNaN(value)) {
          newCategories.push(value)
        } else {
          existingCategories.push(value)
        }
      })
      
      existingCategories.forEach(id => {
        formData.append('category_ids[]', id)
      })
      
      newCategories.forEach(name => {
        formData.append('new_categories[]', name)
      })
    }
    
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
        const isbn = this.bookData.isbn || this.bookData.isbn_13 || this.bookData.isbn_10
        if (isbn) {
          const button = document.querySelector(`.own-book-btn[data-book*="${isbn}"]`)
          if (button) {
            button.textContent = '所有済み'
            button.disabled = true
            button.classList.remove('btn-primary')
            button.classList.add('btn-secondary')
          }
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