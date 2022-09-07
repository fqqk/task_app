# タスク管理アプリ

day18 最終課題成果物
<br>

# 環境

docker を使用

- Ruby 2.6.3
- Ruby on Rails 6.0.3

intel チップ Mac での動作確認済み

`現状 M1 チップ Mac では動作しません。`

**【セットアップ】**

こちらのプロジェクトをクローン後,ビルド

```
your dir > docker compose build
```

bundle install を実行して Gemfile.lock を更新

```
your dir > docker compose exec web bundle install
```

package.json の中身に従って yarn.lock を更新

```
your di r> docker compose exec web yarn install
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

動作中のコンテナ確認

```
your dir > docker ps
```

コンテナ破棄

```
your dir> docker rm containerID
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
  gon.tasks = @tasks.as_json(:include => {:user => {:only => [:name]}})
  gon.users = User.select(:id, :name)
end

def mypage
  @tasks = current_user.tasks.incomplete
  gon.tasks = @tasks
  @results = @q.result.where(user_id: current_user.id).incomplete.page(params[:page])
end



private

def set_q
  @q = Task.eager_load(:user).ransack(params[:q])
end
```

app/views/tasks/index.html.erb

この部分の select タグと、自動生成される option タグを以下の javascript で書き換えている

```ruby
<%= search_form_for(@q,class:'w-50 d-flex align-items-center', local: true) do |f| %>
  <%= f.select :id_eq, options_from_collection_for_select(@tasks, :id ,:title) ,{include_blank: "選択してください"},  class: 'form-control search-select mr-2' %>
  <%= f.button '検索', class:"btn btn-primary w-25" %>
<% end %>
```

app/javascript/packs/tasks/index.js

- 選択項目の変化を検知
- 選択項目の値に従い、select タグの name と id,生成する option を切り替える。
- option の中身は gon 経由でコントローラーから渡されたものを使用

```javascript
window.addEventListener("DOMContentLoaded", function () {
  let radio_btns = document.querySelectorAll(
    `input[type='radio'][name='item']`
  );
  for (let target of radio_btns) {
    target.addEventListener("change", function () {
      itemSelect(target);
    });
  }
});

function itemSelect(target) {
  let value = target.value;
  if (value) {
    changeOptionInnerHTML(value);
  } else {
    console.log("no value");
  }
}

function addOptionList(value, q_name, q_id, gons) {
  const select = document.querySelector("select");
  select.removeAttribute("name");
  select.removeAttribute("id");
  select.setAttribute("name", q_name);
  select.setAttribute("id", q_id);
  const rm_target_user = document.querySelectorAll("option");
  rm_target_user.forEach((target) => target.remove());
  for (const gon of gons) {
    const option = document.createElement("option");
    option.value = gon.id;
    option.innerHTML = gon[value];
    select.appendChild(option);
  }
}

function changeOptionInnerHTML(value) {
  const tasks = gon.tasks;
  const users = gon.users;

  if (value == "title") {
    addOptionList(value, "q[id_eq]", "q_id_eq", tasks);
  } else if (value == "content") {
    addOptionList(value, "q[id_eq]", "q_id_eq", tasks);
  } else {
    addOptionList(value, "q[user_id_eq]", "q_user_id_eq", users);
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

# 苦労したこと

- ransack と JavaScript の記述の部分で turbolinks に振り回されたこと
- rails に慣れること

# 今後やってみたいこと

- csv ファイルを扱ってみたい
- SQL 頑張りたい
- gem 探しの旅
