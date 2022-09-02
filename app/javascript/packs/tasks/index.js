window.addEventListener('DOMContentLoaded', function() {
  let radio_btns = document.querySelectorAll(`input[type='radio'][name='item']`);
  for (let target of radio_btns) {
    target.addEventListener('change', function () {
      itemSelect(target);
    });
  };
});

function itemSelect(target) {
  let value = target.value;
  if(value) {
    changeOptionInnerHTML(value);
  } else {
    console.log("no value");
  }
}

function addOptionList(value,q_name,q_id,gons) {
  const select = document.querySelector("select");
  select.removeAttribute('name');
  select.removeAttribute('id');
  select.setAttribute('name',q_name);
  select.setAttribute('id',q_id);
  const rm_target_user = document.querySelectorAll("option");
  rm_target_user.forEach((target) => target.remove());
  for(const gon of gons){
      const option = document.createElement('option');
      option.value = gon.id;
      option.innerHTML = gon[value];
      select.appendChild(option);
  }
}

function changeOptionInnerHTML(value) {
  const tasks = gon.tasks;
  const users = gon.users;

  if(value == 'title') {
    addOptionList(value,'q[id_eq]','q_id_eq',tasks);
  } else if(value == 'content') {
    addOptionList(value,'q[id_eq]','q_id_eq',tasks);
  } else {
    addOptionList(value,'q[user_id_eq]','q_user_id_eq',users);
  }
}