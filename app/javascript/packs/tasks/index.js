window.addEventListener('DOMContentLoaded', function() {
  const radio_btns = document.querySelectorAll(`input[type='radio'][name='item']`);
  for (const element of radio_btns) {
    element.addEventListener('change', function () {
      replaceOptionList(element);
    });
  };
});

function replaceOptionList(target) {
  const select = document.querySelector(".js-select-target")
  select.removeAttribute('name');
  select.removeAttribute('id');
  const options = document.querySelectorAll("option");
  options.forEach((option) => option.remove());

  let records = "";
  const value = target.value;
  if(value == 'title' || value == 'content') {
    select.setAttribute('name', 'q[id_eq]');
    select.setAttribute('id', 'q_id_eq');
    records = gon.tasks
  } else {
    select.setAttribute('name', 'q[user_id_eq]');
    select.setAttribute('id', 'q_user_id_eq');
    records = gon.users;
  }

  for(const record of records){
    const option = document.createElement('option');
    option.value = record.id;
    option.innerHTML = record[value];
    select.appendChild(option);
  }

}