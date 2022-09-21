# タスク管理アプリ

day18 最終課題成果物
<br>

# 環境

docker を使用

- Ruby 2.6.3
- Ruby on Rails 6.0.3

**【セットアップ】**

clone

```
your dir > git clone https://github.com/fqqk/task_app.git
```

build

```
your dir > docker compose build
```

db create & migrate

```
your dir > docker-comopse run web rails db:create
your dir > docker-comopse run web rails db:migrate
```

コンテナ起動

```
your dir > docker compose up
```

Access to http://localhost:8080

コンテナ停止

```
your dir > docker compose down
```

## [ER 図](er_diagram.md)

<br>

# 追加機能

### 1)ページネーション

> 使用技術

- gem: kaminari

> 該当コード

モデルにて 1 ページあたりのデータ数を指定

```ruby
class Task < ApplicationRecord
  paginates_per 6
  --省略--
end
```

コントローラで page スコープを使用。

view 側から送信されたページ番号を params[:page]で取り出している

```ruby
--省略--
def index
 @results = @q.result.incomplete.page(params[:page])
 --省略--
end
```

ビュー側での記述

スタイルは bootstrap であてています。

```ruby
<%= paginate @results, theme: 'twitter-bootstrap-4' %>
```

### 2)項目選択式検索機能

> 使用技術

- gem: ransack
- gem: gon
- javascript 側の処理

> 該当コード

app/controllers/tasks_controller.rb

- set_q にて、view から送られてきたパラメータをもとに Task のテーブルから該当のタスクを取得する。のちに、view 側でユーザー名を使用するため Task に紐づくユーザーも一括取得することで N+1 問題への対処をしている。
- 取得した値を JavaScript 側でも扱えるよう、gon で値を渡している

```ruby
before_action :set_q, only: %i[index mypage]

def index
  @tasks = Task.incomplete.preload(:user)
  @results = @q.result.incomplete.page(params[:page])
  gon.tasks = Task.select(:id, :title, :content)
  gon.users = User.select(:id, :name)
end

def mypage
  @tasks = current_user.tasks.incomplete
  gon.tasks = @tasks
  @results = @q.result.where(user_id: current_user.id).incomplete.page(params[:page])
end



private

def set_q
  @q = Task.preload(:user).ransack(params[:q])
end
```

app/views/tasks/index.html.erb

この部分の select タグと、自動生成される option タグを以下の javascript で書き換えている

```ruby
<%= search_form_for(@q,class:'w-50 d-flex align-items-center', local: true) do |f| %>
  <%= f.select :id_eq, options_from_collection_for_select(@tasks,:id ,:title) ,{include_blank: "選択してください"},  class: 'form-control mr-2 js-select-target' %>
  <%= f.button '検索', class:"btn btn-primary w-25" %>
<% end %>
```

app/javascript/packs/tasks/index.js

- 選択項目の変化を検知
- 選択項目の値に従い、select タグの name と id,生成する option を切り替える。
- option の中身は gon 経由でコントローラーから渡されたものを使用

```javascript
window.addEventListener("DOMContentLoaded", function () {
  const radio_btns = document.querySelectorAll(
    `input[type='radio'][name='item']`
  );
  for (const element of radio_btns) {
    element.addEventListener("change", function () {
      replaceOptionList(element);
    });
  }
});

function replaceOptionList(target) {
  const select = document.querySelector(".js-select-target");
  select.removeAttribute("name");
  select.removeAttribute("id");
  const options = document.querySelectorAll("option");
  options.forEach((option) => option.remove());

  let records = "";
  const value = target.value;
  if (value == "title" || value == "content") {
    select.setAttribute("name", "q[id_eq]");
    select.setAttribute("id", "q_id_eq");
    records = gon.tasks;
  } else {
    select.setAttribute("name", "q[user_id_eq]");
    select.setAttribute("id", "q_user_id_eq");
    records = gon.users;
  }

  for (const record of records) {
    const option = document.createElement("option");
    option.value = record.id;
    option.innerHTML = record[value];
    select.appendChild(option);
  }
}
```

### 3)タスク作成通知機能(slackAPI)

[参考資料 出典:Qiita](https://qiita.com/murakami-mm/items/c34af59fdff198161967)

config/initializers/slack_ruby_client.rb

認証トークンの設定
slack-ruby-client を使用した API 実行時に認証用のトークンがパラメータとして送信される

```ruby
Slack.configure do |config|
  config.token = ENV['SLACK_BOT_USER_AUTH_TOKEN']
end
```

app/controllers/tasks_controller.rb

> 使用技術

- gem: slack-ruby-client

モデル内の send_slack メソッドを使用

```ruby
def create
--省略--
  if @task.save
    @task.send_slack
  end
--省略--
end
```

app/models/task.rb

slack 側の仕様に従って作成しました。

他にもできることがたくさんあるので時間を見つけて触りたいです。

```ruby
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
```

### 4)コメント機能

[ER 図](er_diagram.md)でも書いていますが、user テーブル、task テーブルともに 1:N の関係です。

コントローラー、ビュー ともに task と類似しているため割愛

> 該当コード

```ruby
class Comment < ApplicationRecord
  paginates_per 5
  belongs_to :user
  belongs_to :task
  validates :comment, presence: true
end
```

### 5)並べ替え機能

> 使用技術

- gem: ransack

> 該当コード

views/tasks/index.html.erb

```html
<div>
  <label class="font-weight-bold">【並べ替え】</label>
  <label for="content" class="font-weight-bold mr-4"
    ><%= sort_link(@q, :created_at, "作成日") %></label
  >
  <label for="content" class="font-weight-bold"
    ><%= sort_link(@q, :deadline, "期限") %></label
  >
</div>
```

### 6)日時選択バリデーション

タスク新規作成、編集時に使用
期限変更時、現在時刻よりも以前のタスクを作成できないようにした

> 該当コード

models/task.rb

```Ruby
validate :date_after_today?

def date_after_today?
  if deadline_changed?
    errors.add(:deadline, "は現在以降のものを選択してください") if deadline < Time.zone.now
  end
end
```

views/tasks/\_form.html.erb

```html
<div class="form-item">
  <%= form.label :deadline, class:'form-label font-weight-bold' %> <%= raw
  sprintf(form.datetime_select(:deadline, {start_year: Time.zone.now.year,
  end_year: Time.zone.now.next_year.year, default: Time.zone.now, minute_step:
  10, use_two_digit_numbers: true, date_separator: '%s', datetime_separator:
  '%s', time_separator: '%s'}), '年', '月', '日', '時') + '分'%>
</div>
```

# 頑張ったポイント

- ransack と JavaScript の記述の部分で turbolinks に振り回されたこと
- rails に慣れること
- RSpec 書きました！

# タスクアプリ:拡張できそうな箇所

- コメント編集の ajax 化
- send_slack メソッドのクラス化
- 他のアクションに応じた send_slack
- レスポンシブの充実化

# 今後やってみたいこと

- csv ファイルを扱ってみたい
- SQL 頑張りたい
- gem 探しの旅
- インフラ周り理解したい...
