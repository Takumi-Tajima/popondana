import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "categorySelect"]
  
  connect() {
    console.log('CategoryEdit controller connected')
    
    // モーダルの初期化
    if (this.hasModalTarget && typeof bootstrap !== 'undefined') {
      this.modal = new bootstrap.Modal(this.modalTarget)
    }
  }
  
  openModal(event) {
    console.log('Opening category edit modal')
    const button = event.currentTarget
    this.ownershipId = button.dataset.ownershipId
    
    // Tom-selectを初期化
    this.initializeTomSelect()
    
    // モーダルを表示
    if (this.modal) {
      this.modal.show()
    }
  }
  
  async initializeTomSelect() {
    if (!this.hasCategorySelectTarget) return
    
    try {
      // すべてのカテゴリを取得
      const allCategoriesResponse = await fetch('/api/categories', {
        headers: {
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        }
      })
      
      // 現在の所有に紐付いているカテゴリを取得
      const ownershipResponse = await fetch(`/ownerships/${this.ownershipId}.json`, {
        headers: {
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        }
      })
      
      if (allCategoriesResponse.ok && ownershipResponse.ok) {
        const allCategories = await allCategoriesResponse.json()
        const ownershipData = await ownershipResponse.json()
        const selectedCategoryIds = ownershipData.category_ids || []
        
        // 既存の選択肢をクリア
        this.categorySelectTarget.innerHTML = ''
        
        // カテゴリをオプションとして追加
        allCategories.forEach(category => {
          const option = document.createElement('option')
          option.value = category.id
          option.textContent = category.name
          option.selected = selectedCategoryIds.includes(category.id)
          this.categorySelectTarget.appendChild(option)
        })
        
        // Tom-selectを初期化
        if (this.tomSelect) {
          this.tomSelect.destroy()
        }
        
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
      const response = await fetch(`/ownerships/${this.ownershipId}/update_categories`, {
        method: 'PATCH',
        headers: {
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: formData
      })
      
      const result = await response.json()
      
      if (result.status === 'success') {
        // モーダルを閉じる
        this.modal.hide()
        
        // ページをリロード
        window.location.reload()
      } else {
        alert('エラーが発生しました')
      }
    } catch (error) {
      console.error('保存に失敗しました:', error)
      alert('保存に失敗しました。')
    }
  }

  async deleteCategory(event) {
    const categoryName = event.currentTarget.dataset.categoryName
    
    if (!confirm(`カテゴリ「${categoryName}」を削除してもよろしいですか？\n\n※このカテゴリは全ての書籍から削除されます。`)) {
      return
    }
    
    try {
      const response = await fetch(`/api/categories/${encodeURIComponent(categoryName)}`, {
        method: 'DELETE',
        headers: {
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        }
      })
      
      const result = await response.json()
      
      if (result.status === 'success') {
        // ページをリロード
        window.location.reload()
      } else {
        alert('カテゴリの削除に失敗しました')
      }
    } catch (error) {
      console.error('カテゴリの削除に失敗しました:', error)
      alert('カテゴリの削除に失敗しました')
    }
  }
}