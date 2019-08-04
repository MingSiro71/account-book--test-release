function checkAmount(){

  if (document.getElementById("record_account").value == "消耗品費"){
    // rule: If 消耗品費 costs much more 300,000, hide submit
    if (document.getElementById("record_amount").value > 300000){
      alert("1つあたり30万円以上の備品は資産扱いになります。経理上の正当性についてご自身で確認を行ってください。");
    }
    // rule: If 消耗品費 costs much more 100,000, do alart
    if (document.getElementById("record_amount").value > 100000){
      alert("1つあたり10万円以上の備品は青色申告の個人事業主を除き資産扱いになります。経理上の正当性についてご自身で確認を行ってください。");
    };
  };
}