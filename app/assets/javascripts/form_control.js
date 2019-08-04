// On load js itself

let accounts;

// After loading html structure 

document.addEventListener("turbolinks:load", function(){

  // when page with record form is loaded, load accounts
  const record_form = document.getElementById("record_form")
  if (record_form !== null){
  accounts = load_accounts();
  }
  // console.dir(accounts);

  // Equip form interface controller to record_account box
  const accountTypeBox = document.getElementById("record_account");
  if (accountTypeBox){
    accountTypeBox.addEventListener('keyup', formControl, false);
  }
  // Equip rulr checker to record_amount box
  const amountBox = document.getElementById("record_amount");
  if (amountBox){
    amountBox.addEventListener('keyup', checkAmount, false);
  }
});

// Aftre loading whole elements
window.onload = function(){
}

// Other events

// disable enter key submission
document.onkeypress = enter;


// Functions library
function load_accounts(){
  return difinitions();
}

function enter(){
  if( window.event.keyCode == 13 ){
    return false;
  }
}

function formControl(){
  const accountTypeBox = document.getElementById("record_account");
  let input = accountTypeBox.value;
  if (accounts[input]){
    if (accounts[input]['taxselection']){
      document.getElementById("tax").classList.remove("inactive")
    }
    if (accounts[input]['options']){
      let html = "";
      document.getElementById("option").classList.remove("inactive")
      let checkboxes = []; 
      checkboxes = accounts[input]['options'].map(option =>{
        let string = "<input type='radio' value='"+ option.value +"' name='record[option]' id='option_"+ option.value +"'> " + option.label;
        return string
      });
      html = "<label for='record_option'>オプション</label><p>"
      + checkboxes.join(" ")
      + "</p>";
      document.getElementById("option").innerHTML = html;
    }
    // if (accounts[input]['has_when']){
    //   document.getElementById("when").classList.remove("inactive")
    // }
    if (accounts[input]['has_to']){
      document.getElementById("where").classList.remove("inactive")
    }
    if (accounts[input]['has_from']){
      document.getElementById("where_from").classList.remove("inactive")
    }
    if (accounts[input]['has_quantity']){
      document.getElementById("quantity").classList.remove("inactive")
    }
    if (accounts[input]['recomend']){
      let html = ""
      let recomendations = []
      let recomendWords = document.getElementById("recomend")
      recomendWords.classList.remove("inactive")
      recomendations = accounts[input]['recomend'].map(r =>{
        let string = "<span class='recomendation-word' value='" + r + "' >" + r + "</span>, ";
        return string
      });
      html = "これかも？ "
      + recomendations.join(" ");
      recomendWords.innerHTML = html;
      recomendWords.addEventListener('click', fillRecomendation, false);
    }
  }
  else{
    document.getElementById("tax").classList.add("inactive");
    document.getElementById("option").classList.add("inactive");
    // document.getElementById("when").classList.add("inactive")
    document.getElementById("where").classList.add("inactive");
    document.getElementById("where_from").classList.add("inactive");
    document.getElementById("quantity").classList.add("inactive");
  }
}

function fillRecomendation(e){
  document.getElementById("record_account").value = e.target.attributes.value.nodeValue;
  let recomendWords = document.getElementById("recomend");
  recomendWords.classList.add("inactive");
  recomendWords.innerHTML = "";
  formControl();
}