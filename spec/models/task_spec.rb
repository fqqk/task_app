require 'rails_helper'

RSpec.describe Task, type: :model do
  describe '#create' do
    it "title, content, deadline, statusが存在すれば登録できること" do
      expect(create(:task)).to be_valid
    end

    it "titleがなければ登録できないこと" do
      task = build(:task, title: nil)
      task.valid?
      expect(task.errors[:title]).to include("を入力してください")
    end

    it "contentがなければ登録できないこと" do
      task = build(:task, content: nil)
      task.valid?
      expect(task.errors[:content]).to include("を入力してください")
    end

    it "deadlineがなければ登録できないこと" do
      task = build(:task, deadline: nil)
      task.valid?
      expect(task.errors[:deadline]).to include("を入力してください")
    end

    it "statusがなければ登録できないこと" do
      task = build(:task, status: nil)
      task.valid?
      expect(task.errors[:status]).to include("を入力してください")
    end

    # it "スラックに通知すること" do

    # end
  end
end
