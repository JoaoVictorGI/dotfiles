let paragrafo = document.querySelector("#para1");

paragrafo.addEventListener("click", trocaTexto);

function trocaTexto() {
  paragrafo.style.background = "red";
}
