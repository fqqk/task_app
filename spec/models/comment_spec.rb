require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe 'validation' do
    it "commentが存在すれば登録できること" do
      expect(create(:comment)).to be_valid
    end

    it "commentがなければ登録できないこと" do
      comment = build(:comment, comment: nil)
      comment.valid?
      expect(comment.errors[:comment].to_sentence).to include("Userを入力してください、Commentを入力してください")
    end
  end
end