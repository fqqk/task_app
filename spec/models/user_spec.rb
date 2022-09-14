require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validation' do
    it "name, email, password, password_confirmationが存在すれば登録できること" do
      expect(build(:user)).to be_valid
    end

    it "nameがなければ登録できないこと" do
      user = build(:user, name: nil)
      user.valid?
      expect(user.errors[:name]).to include("を入力してください")
    end

    it "emailがなければ登録できないこと" do
      user = build(:user, email: nil)
      user.valid?
      expect(user.errors[:email]).to include("を入力してください")
    end

    it "passwordがなければ登録できないこと" do
      user = build(:user, password: nil)
      user.valid?
      expect(user.errors[:password]).to include("を入力してください")
    end

    it "重複したemailが存在する場合登録できないこと" do
      user = create(:user)
      another_user = build(:user, email: user.email)
      another_user.valid?
      expect(another_user.errors[:email]).to include("はすでに存在します")
    end
  end

  describe "Association" do
    it "ユーザーが削除された場合、タスクも同時に削除されること" do
      user = FactoryBot.build(:user)
      user.tasks << FactoryBot.build(:task)
      user.save
      expect {
        user.destroy
      }.to change(Task, :count).by(-1)
    end

    it "ユーザーが削除された場合、コメントも同時に削除されること" do
      user = FactoryBot.build(:user)
      user.comments << FactoryBot.build(:comment)
      user.save
      expect {
        user.destroy
      }.to change(Comment, :count).by(-1)
    end
  end
end