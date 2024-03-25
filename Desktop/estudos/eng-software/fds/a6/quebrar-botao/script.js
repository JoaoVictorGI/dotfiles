let botao = document.querySelector("#botao");
let estaQuebrado = false;
let qntCliques = 0;
botao.style.background = "blue";

botao.addEventListener("mouseover", (e) => {
  if (!estaQuebrado) botao.style.background = "green";
  botao.style.color = "white";
});

botao.addEventListener("mouseout", (e) => {
  if (!estaQuebrado) botao.style.background = "blue";
  botao.style.color = "white";
});

botao.addEventListener("click", (e) => {
  qntCliques++;
  if (qntCliques >= 10) {
    botao.style.background = "red";
    botao.innerHTML = "quebrei";
    estaQuebrado = true;
  }
});
