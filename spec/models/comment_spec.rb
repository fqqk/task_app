require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe 'validation' do
    it "commentが存在すれば登録できること" do
      expect(create(:comment)).to be_valid
    end

    it "commentがなければ登録できないこと" do
      comment = build(:comment, comment: nil)
      comment.valid?
      expect(comment.errors.full_messages).to include("Commentを入力してください")
    end

    it "commentが140文字以上であれば登録できないこと" do
      comment = build(:comment, comment: 'a'*141)
      comment.valid?
      expect(comment.errors[:comment]).to include("は140文字以内で入力してください")
    end
  end

  describe "Association" do
    it "ユーザーモデルと関連があること" do
      expect(build(:comment).user_id).to eq nil
    end

    it "タスクモデルと関連があること" do
      expect(build(:comment).task_id).to eq nil
    end
  end
end