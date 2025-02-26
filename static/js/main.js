function sM() {
    var $e = $("#navoverlay");
    var $t = $("#navpane");
    var $l = $("#burger");
    var $n = $("#content");

    if ($e.css('display') === 'none') {
        $e.css('display', 'block');
        $t.css('display', 'block');
        $n.css('position', 'fixed');
        $l.css('transform', 'rotate(90deg)');
        $n.css('margin-right', '8px');
    } else {
        $e.css('display', 'none');
        $t.css('display', 'none');
        $n.css('position', 'absolute');
        $l.css('transform', 'rotate(-180deg)');
        $n.css('margin-right', '0px');
    }
}

$(document).ready(function($){
    $("#burger").on("click", sM);
    $("#navoverlay").on("click", sM);
})