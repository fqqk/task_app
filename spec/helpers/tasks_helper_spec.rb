require 'rails_helper'

RSpec.describe TasksHelper, type: :helper do
  describe '#button_text' do
    context 'action_nameがnewの場合' do
      it '登録するという文字列を返すこと' do
        controller.action_name = 'new'
        expect(button_text).to eq '登録する'
      end
    end

    context 'action_nameがeditの場合' do
      it '更新するという文字列を返すこと' do
        controller.action_name = 'edit'
        expect(button_text).to eq '更新する'
      end
    end
  end

  describe '#now_is_within_deadline?' do
    it "期限が現在よりも前であればfalseを返すこと" do
      expect(now_is_within_deadline?(Time.now.yesterday)).to eq false
    end
  end
end
