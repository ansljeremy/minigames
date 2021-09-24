const color = "#ffffff";
const bgColor = "#72717f";
const bgColor2 = "#e7b81b";

let canvas = null;
let ctx = null;
let width = null;
let height = null;
let degrees = 0;
let newDegrees = 0;
let time = 0;

let keyToPress = null;
let gameStart = null
let gameEnd = null;
let animationLoop = null;
let isOpen = false;

function getRandomInt(min, max) {
    min = Math.ceil(min);
    max = Math.floor(max);
    return Math.floor(Math.random() * (max - min + 1) + min); //The maximum is inclusive and the minimum is inclusive
}

function init() {
    // Clear the canvas every time a chart is drawn
    ctx.clearRect(0, 0, width, height);

    // Background 360 degree arc
    ctx.beginPath();
    ctx.strokeStyle = bgColor;
    ctx.lineWidth = 20;
    ctx.arc(width / 2, height / 2, 100, 0, Math.PI * 2, false);
    ctx.stroke();

    // Green zone
    ctx.beginPath();
    ctx.strokeStyle = bgColor2;
    ctx.lineWidth = 20;
    ctx.arc(
        width / 2,
        height / 2,
        100,
        gameStart - (90 * Math.PI) / 180,
        gameEnd - (90 * Math.PI) / 180,
        false
    );
    ctx.stroke();

    // Angle in radians = angle in degrees * PI / 180
    let radians = (degrees * Math.PI) / 180;
    ctx.beginPath();
    ctx.strokeStyle = color;
    ctx.lineWidth = 20;
    ctx.arc(
        width / 2,
        height / 2,
        100,
        0 - (90 * Math.PI) / 180,
        radians - (90 * Math.PI) / 180,
        false
    );
    ctx.stroke();

    // Adding the key_to_press
    // ctx.fillStyle = bgcolor;
    ctx.fillStyle = color;
    ctx.font = "100px sans-serif";
    let text_width = ctx.measureText(keyToPress).width;
    ctx.fillText(keyToPress, width / 2 - text_width / 2, height / 2 + 35);
}

function draw(data) {
    if (typeof animationLoop !== undefined) clearInterval(animationLoop);
    $("#minigames-body").show();
    $("#minigames-body").html(`<canvas id="canvas" width="300" height="300"></canvas>`);

    degrees = 0;
    newDegrees = 360;

    gameStart = data.gameStart;
    gameEnd = data.gameEnd;
    keyToPress = data.gameKey;
    time = data.gameTime;

    canvas = document.getElementById("canvas");
    ctx = canvas.getContext("2d");
    width = canvas.width;
    height = canvas.height;

    isOpen = true

    animationLoop = setInterval(animate_to, time);
}

function animate_to() {
    if (degrees >= newDegrees) {
        wrong();
        return;
    }

    degrees += 2;
    init();
}

function stop(){
    if (typeof animationLoop !== undefined) clearInterval(animationLoop);
    canvas = null;
    ctx = null;
    width = 0;
    height = 0;

    $("#minigames-body").html('');
    $("#minigames-body").hide();
    isOpen = false
}

function wrong(){
    $.post('https://minigames/skillcirclefail');
    stop();
}

document.addEventListener("keydown", function (ev) {
    if(isOpen){
        let keyPressed = ev.key;
        let validKeys = ["1", "2", "3", "4"];
        if (validKeys.includes(keyPressed)) {
            $.post('https://minigames/skillcirclecheck', JSON.stringify({ degrees, keyPressed }));
            stop();
        }

        if(keyPressed == 'Escape') {
            wrong();
        }
    }
});


window.addEventListener('message', function(event){
    let action = event.data.action;
    switch(action) {
        case "start":
            draw(event.data.data);
            break;
        case "stop":
            stop();
            break;
    }
});