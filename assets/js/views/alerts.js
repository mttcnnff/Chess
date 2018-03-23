export function flashAlert(text) {
    $("#alert-block").children()[0].innerHTML = text;
    $("#alert-block")[0].className = "";
};

export function flashDanger(text) {
    $("#danger-block").children()[0].innerHTML = text;
    $("#danger-block")[0].className = "";
};