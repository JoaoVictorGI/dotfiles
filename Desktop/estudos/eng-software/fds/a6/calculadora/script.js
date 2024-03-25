const number1 = document.querySelector("#n1");
const number2 = document.querySelector("#n2");
const operacao = document.querySelector("#operacao");
const botao = document.querySelector("#igual");
let resultado = document.querySelector("#resultado");

botao.addEventListener("click", calcular);

function calcular() {
  const valor1 = parseInt(number1.value);
  const valor2 = parseInt(number2.value);
  const operacaoCalcular = operacao.value;
  let resposta;

  if (operacaoCalcular == "+") {
    resposta = valor1 + valor2;
  } else if (operacaoCalcular == "-") {
    resposta = valor1 - valor2;
  } else if (operacaoCalcular == "x") {
    resposta = valor1 * valor2;
  } else {
    resposta = valor1 / valor2;
  }

  alert(`O resultado é: ${resposta}`);
}
