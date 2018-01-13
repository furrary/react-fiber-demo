import { html, render } from "lit-html";

const startTime = new Date();
const targetSize = 25;
const dotSize = targetSize * 1.3;

let hoveredDotId;
let dotInnerText;

/* MAIN */

const container = document.querySelector("#container");
requestAnimationFrame(renderToContainer);

document.addEventListener("mouseover", event => {
    const hoveredDot = event.target;
    if (hoveredDot && hoveredDot.id) {
        hoveredDotId = hoveredDot.id;
    } else {
        hoveredDotId = null;
    }
});

function renderToContainer() {
    render(view(), container);
    requestAnimationFrame(renderToContainer);
}

/* VIEW */

function view() {
    const remainder = getElapsedSecond() % 10;
    const scaleXFactor = (1 + (5 - Math.abs(5 - remainder)) / 10) / 2.1;
    const style = `
        position: absolute;
        left: 50%;
        top: 50%;
        width: 10px;
        height: 10px;
        background: #eee;
        transform-origin: 0 0;
        transform: scaleX(${scaleXFactor}) scaleY(0.7) translateZ(0.1px)
    `;
    dotInnerText = Math.floor(remainder);
    return html`<div style=${style}>${viewWrappedTriangle()}</div>`;
}

function viewWrappedTriangle() {
    return html`<div>${viewTriangle(1000, 0, 0)}</div>`;
}

function viewTriangle(size, x, y) {
    if (size <= targetSize) {
        return viewDot(x - targetSize / 2, y - targetSize / 2);
    }
    const newSize = size / 2;
    return html`
        ${viewTriangle(newSize, x, y - newSize / 2)}
        ${viewTriangle(newSize, x - newSize, y + newSize / 2)}
        ${viewTriangle(newSize, x + newSize, y + newSize / 2)}
    `;
}

function viewDot(x, y) {
    const id = String(x) + String(y);
    let background = "#61dafb";
    let text = dotInnerText;
    if (hoveredDotId && hoveredDotId === id) {
        text = `*${text}*`;
        background = "#ff0";
    }
    const style = `
        position: absolute;
        left: ${x}px;
        top: ${y}px;
        width: ${dotSize}px;
        height: ${dotSize}px;
        border-radius: 50%;
        background: ${background};
        font: normal 15px sans-serif;
        text-align: center;
        cursor: pointer;
        line-height: ${dotSize}px;
    `;
    return html`<div id=${id} style=${style}>${text}</div>`;
}

function getElapsedSecond() {
    return (new Date().getTime() - startTime.getTime()) / 1000;
}
