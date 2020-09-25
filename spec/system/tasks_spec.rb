require 'rails_helper'

describe 'タスク管理機能', type: :system do

  let(:user_a) {FactoryBot.create(:user, name: 'ユーザーA', email: 'a@example.com')} #letを呼び出すとユーザーAを作成する
  let(:user_b) {FactoryBot.create(:user, name: 'ユーザーB', email: 'b@example.com')} #letを呼び出すとユーザーBを作成する
  let!(:task_a) {FactoryBot.create(:task, name: '最初のタスク',user: user_a)}         #作成者がユーザーAであるタスクを作成しておく

  before do
    # ログインする
    visit login_path                                #ログイン画面にアクセスする
      fill_in 'メールアドレス',with: login_user.email #login_userのメールアドレスを入力する
      fill_in 'パスワード',with: login_user.password #login_userのパスワードを入力する
      click_button 'ログインする'                    #[ログインする]ボタンを押す

  end
  
  shared_examples_for 'ユーザーAが作成したタスクが表示される' do #share_examplesでitを共通化する
    it  { expect(page).to have_content '最初のタスク' } #作成済みのタスクの名称が画面上に表示されていることを確認
  end

  describe '一覧表示機能' do
    context 'ユーザーAがログインしている時' do
      let(:login_user){user_a} #letでlogin_userにuser_aを代入
      it_behaves_like 'ユーザーAが作成したタスクが表示される' 
    end
    
    context 'ユーザーBがログインしているとき' do
      let(:login_user){user_b} #letでlogin_userにuser_bを代入
      it 'ユーザーAが作成したタスクが表示されない' do
        # ユーザーAが作成したタスクの名称が画面上に表示されていないことを確認
        expect(page).to have_no_content '最初のタスク'
      end
    end
  end
  describe '詳細表示機能' do
    context 'ユーザーAがログインしている時' do
      let(:login_user){user_a}
      before do
        visit task_path(task_a)
      end
      
      it_behaves_like 'ユーザーAが作成したタスクが表示される' 
      
    end
  end

  describe '新規登録機能' do
    let(:login_user) {user_a}

    before do
      visit new_task_path
      fill_in '名称', with: task_name
      click_button '登録する'
    end

    context '新規作成画面で名称を入力した時' do
      let(:task_name) {'新規作成のテストを書く'}

      it '正常に登録される' do
        expect(page).to have_selector '.alert-success', text: '新規作成のテストを書く'
      end
    end

    context '新規作成画面で名称を入力しなかった時' do
      let(:task_name) { '' }

      it 'エラーとなる' do
        within '#error_explanation' do
          expect(page).to have_content '名称を入力してください'
        end
      end
    end
  end
end