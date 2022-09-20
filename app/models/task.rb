class Task < ApplicationRecord
  paginates_per 6
  belongs_to :user
  has_many :comments, dependent: :destroy
  validates :title, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validates :deadline, presence: true
  validates :status, presence: true
  validate :date_after_today?

  scope :incomplete, -> (status = ['doing', 'incomplete']) {
    where(status: status)
  }

  def date_after_today?
    if deadline_changed?
      errors.add(:deadline, "は現在以降のものを選択してください") if deadline < Time.zone.now
    end
  end

  def send_slack
    client = Slack::Web::Client.new
    client.chat_postMessage(
      channel: '#実験場所',
      text: "#{user.name}さんがタスクの新規作成を行いました:fire:",
      blocks: [
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "#{user.name}さんがタスクの新規作成を行いました:fire:"
          }
        },
        {
          "type": "header",
          "text": {
            "type": "plain_text",
            "text": "タイトル:#{title}",
            "emoji": true
          }
        },
        {
          "type": "actions",
          "elements": [
            {
              "type": "button",
              "text": {
                "type": "plain_text",
                "emoji": true,
                "text": "コメントする"
              },
              "style": "primary",
              "url": "http://localhost:8080/tasks/#{id}"
            },
          ]
        }
      ]
    )
  end
end