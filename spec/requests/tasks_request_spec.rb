require 'rails_helper'

RSpec.describe "Tasks", type: :request do
  before do
    @user = create(:user)
    @other_user = create(:user, name: "別人")
  end

  describe "#index" do
    context "ログイン済みユーザーの場合" do
      it "一覧ページに遷移すること" do
        sign_in @user
        get root_path
        expect(response).to render_template(:index)
      end
    end

    context "未ログインユーザーの場合" do
      it "一覧ページに遷移できないこと" do
        get root_path
        expect(response).not_to render_template(:index)
      end
    end
  end

  describe "#create" do
    context "ログイン済みユーザーの場合" do
      context "タスク作成に成功した場合" do
        it "タスクが作成されている" do
          task_params = FactoryBot.attributes_for(:task)
          sign_in @user
          expect {
            post tasks_path, params: { task: task_params }
          }.to change(@user.tasks, :count).by(1)
        end

        it "タスク詳細ページに遷移すること" do
          task_params = FactoryBot.attributes_for(:task)
          sign_in @user
          post tasks_path, params: { task: task_params }
          expect(response).to have_http_status '302'
          expect(response).to redirect_to task_url(Task.last)
        end
      end

      context "タスク作成に失敗した場合" do
        it "新規タスク作成画面がレンダリングされること" do
          task_params = FactoryBot.attributes_for(:task, title: nil)
          sign_in @user
          post tasks_path, params: { task: task_params }
          expect(response).to render_template(:new)
          expect(flash[:alert]).to be_present
        end
      end
    end

    context "未ログインユーザーの場合" do
      it "タスクを作成できないこと" do
        task_params = FactoryBot.attributes_for(:task)
        expect{
          post tasks_path, params: { task: task_params }
        }.to change(Task, :count).by(0)
      end

      it "ログイン画面にリダイレクトすること" do
        task_params = FactoryBot.attributes_for(:task)
        post tasks_path, params: { task: task_params }
        expect(response).to have_http_status '302'
        expect(response).to redirect_to "/users/sign_in"
      end
    end
  end

  describe "#update" do
    context "ログインユーザーの場合" do
      context "自分のタスクの更新に成功した場合" do
        it "タスクの更新ができること" do
          sign_in @user
          task = FactoryBot.create(:task, user: @user)
          task_params = FactoryBot.attributes_for(:task, content: "新しいタスクです")
          put task_path(task), params: { task: task_params }
          expect(task.reload.content).to eq "新しいタスクです"
        end

        it "タスク詳細画面に遷移すること" do
          sign_in @user
          task = FactoryBot.create(:task, user: @user)
          task_params = FactoryBot.attributes_for(:task, content: "新しいタスクです")
          put task_path(task), params: { task: task_params }
          expect(response).to redirect_to task_url(task)
          expect(flash[:notice]).to be_present
        end
      end

      context "タスクの更新に失敗した場合" do
        it "タスクの編集画面がレンダリングされること" do
          sign_in @user
          task = FactoryBot.create(:task, user: @user)
          task_params = FactoryBot.attributes_for(:task, content: nil)
          put task_path(task), params: { task: task_params }
          expect(response).to render_template(:edit)
          expect(flash[:alert]).to be_present
        end
      end

      context "他の人のタスクを更新した場合" do
        it "更新できないこと" do
          task = FactoryBot.create(:task, user: @other_user)
          sign_in @user
          task_params = FactoryBot.attributes_for(:task, content: "新しいタスクです")
          put task_path(task), params: { task: task_params }
          expect(response).to redirect_to tasks_url
          expect(flash[:alert]).to be_present
        end
      end
    end

    context "未ログインユーザーの場合" do
      it "タスクの更新ができないこと" do
        task = FactoryBot.create(:task, user: @user)
        task_params = FactoryBot.attributes_for(:task, content: "新しいタスクです")
        put task_path(task), params: { task: task_params }
        expect(task.reload.content).to eq "テストタスクです"
      end
    end
  end

  describe "#update_assign" do
    context "ログインユーザーの場合" do
      context "自分のタスクの担当者を変更した場合" do
        it "変更ができること" do
          sign_in @user
          task = FactoryBot.create(:task, user: @user)
          patch update_assign_task_path(task.id), params: {user_id: @other_user.id}
          task.reload
          expect(task.user_id).to eq @other_user.id
        end

        it "詳細画面に遷移すること" do
          sign_in @user
          task = FactoryBot.create(:task, user: @user)
          patch update_assign_task_path(task), params: {task: FactoryBot.attributes_for(:task, user: @other_user)}
          expect(response).to redirect_to task_url(task)
        end
      end

      context "他の人のタスクの担当者を変更しようとした場合" do
        it "変更できないこと" do
          sign_in @user
          task = FactoryBot.create(:task, user: @other_user)
          expect {
            patch update_assign_task_path(task), params: {task: FactoryBot.attributes_for(:task, user: @user)}
          }.to change(Task, :count).by(0)
        end

        it "一覧画面にリダイレクトすること" do
          sign_in @user
          task = FactoryBot.create(:task, user: @other_user)
          patch update_assign_task_path(task), params: {task: FactoryBot.attributes_for(:task, user: @user)}
          expect(response).to redirect_to tasks_url
          expect(flash[:alert]).to eq '権限がありません'
        end
      end
    end

    context "未ログインユーザーの場合" do
      it "担当者の変更ができないこと" do
        task = FactoryBot.create(:task, user: @user)
        patch update_assign_task_path(task), params: {task: FactoryBot.attributes_for(:task, user: @user)}
        expect(task.reload.user.name).to eq "福士斗真"
      end
    end
  end

  describe "#destroy" do
    context "ログインユーザーの場合" do
      context "自分のタスクの削除した場合" do
        it "タスクの削除ができること" do
          sign_in @user
          task = FactoryBot.create(:task, user: @user)
          expect {
            delete task_path(task)
          }.to change(@user.tasks, :count).by(-1)
        end

        it "一覧画面に遷移すること" do
          sign_in @user
          task = FactoryBot.create(:task, user: @user)
          delete task_path(task)
          expect(response).to redirect_to tasks_url
        end
      end

      context "他の人のタスクを削除しようとした場合" do
        it "削除できないこと" do
          sign_in @user
          task = FactoryBot.create(:task, user: @other_user)
          expect {
            delete task_path(task)
          }.to change(Task, :count).by(0)
        end

        it "一覧画面にリダイレクトすること" do
          sign_in @user
          task = FactoryBot.create(:task, user: @other_user)
          delete task_path(task)
          expect(response).to redirect_to tasks_url
        end
      end
    end

    context "未ログインユーザーの場合" do
      it "タスクの削除ができないこと" do
        task = FactoryBot.create(:task, user: @user)
        expect {
          delete task_path(task)
        }.to change(Task, :count).by(0)
      end
    end
  end
end
