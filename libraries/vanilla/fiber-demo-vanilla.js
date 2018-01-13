"use strict";

const startTime = new Date();
const targetSize = 25;
const dotSize = targetSize * 1.3;

/* MAIN */

const container = document.querySelector("#container");
container.style = `
    position: absolute;
    left: 50%;
    top: 50%;
    width: 10px;
    height: 10px;
    background: #eee;
    transform-origin: 0 0;
`;

// Create a wrapped triangle only to replicate the Elm implementation.
const wrappedTriangle = document.createElement("div");
container.appendChild(wrappedTriangle);

const dots = createDotList();
dots.forEach(dot => wrappedTriangle.appendChild(dot));

requestAnimationFrame(updateDOM);

/* UPDATE */

function updateDOM(oldText, oldHoveredDot) {
    const remainder = getElapsedSecond() % 10;
    const text = Math.floor(remainder);
    const hoveredDot = wrappedTriangle.querySelector(":hover");
    if (text !== oldText) {
        dots.forEach(dot => (dot.textContent = text));
    }
    if (hoveredDot) {
        hoveredDot.style.background = "#ff0";
        hoveredDot.textContent = `*${text}*`;
    }
    if (oldHoveredDot && hoveredDot !== oldHoveredDot) {
        oldHoveredDot.style.background = "#61dafb";
        oldHoveredDot.textContent = text;
    }
    transformContainer((1 + (5 - Math.abs(5 - remainder)) / 10) / 2.1);
    requestAnimationFrame(() => updateDOM(text, hoveredDot));
}

function getElapsedSecond() {
    return (new Date().getTime() - startTime.getTime()) / 1000;
}

function transformContainer(scaleXFactor) {
    container.style.transform = `scaleX(${scaleXFactor}) scaleY(0.7) translateZ(0.1px)`;
}

/* VIEW */

function createDotList(size = 1000, x = 0, y = 0) {
    if (size <= targetSize) {
        return [createDot(x - targetSize / 2, y - targetSize / 2)];
    }
    const newSize = size / 2;
    return createDotList(newSize, x, y - newSize / 2).concat(
        createDotList(newSize, x - newSize, y + newSize / 2),
        createDotList(newSize, x + newSize, y + newSize / 2)
    );
}

function createDot(x, y) {
    const dot = document.createElement("div");
    dot.style = `
        position: absolute;
        left: ${x}px;
        top: ${y}px;
        width: ${dotSize}px;
        height: ${dotSize}px;
        border-radius: 50%;
        background: #61dafb;
        font: normal 15px sans-serif;
        text-align: center;
        cursor: pointer;
        line-height: ${dotSize}px;
    `;
    return dot;
}
