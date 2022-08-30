// 初回リロード時のみ
window.addEventListener('DOMContentLoaded', function() {
  let radio_btns = document.querySelectorAll(`input[type='radio'][name='item']`);
  for (let target of radio_btns) {
    target.addEventListener('change', function () {
      itemSelect(target);
    });
  };
  console.log("初回リロード時");
});

// 初回以降
(function() {
  targetElement()
  console.log("初回以降");
}());

function targetElement() {
  let radio_btns = document.querySelectorAll(`input[type='radio'][name='item']`);
  console.log(radio_btns);
  for (let target of radio_btns) {
    target.addEventListener('change', function () {
      itemSelect(target);
    });
  };
}

function itemSelect(target) {
  let value = target.value;
  if(value) {
    changeOptionInnerHTML(value);
  } else {
    console.log("no value");
  }
  console.log("itemselect");
}

function changeOptionInnerHTML(value) {
  tasks = gon.tasks;
  console.log("changeOptionのgon.tasks", tasks);
  const select = document.getElementById("q_id_eq");
  const options = select.options;
  for( i = 0; i < options.length; i++ ){
    const option = options[i];
    if(value == "title") {
      option.innerHTML = tasks[i].title;
    } else if(value == "content") {
      option.innerHTML = tasks[i].content;
    } else {
      option.innerHTML = tasks[i].user.name;
    }
  }
}
