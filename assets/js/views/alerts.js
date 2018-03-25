export function flashAlert(text) {
    $("#alert-block").children()[0].innerHTML = text;
    $("#alert-block")[0].className = "";
    $("#danger-block")[0].className = "d-none"
};

export function flashDanger(text) {
    $("#danger-block").children()[0].innerHTML = text;
    $("#danger-block")[0].className = "";
    $("#alert-block")[0].className = "d-none"
};