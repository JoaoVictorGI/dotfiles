#include <stdio.h>

int main(void) {
  /* Programa que calcula a média aritmética
    Obter duas notas
    Calcular média aritmética
    Se a média for maior que 7, o aluno foi aprovado
    Se a média for menor que 7, o aluno foi reprovado
  */

  // declaração de váriavel
  float nota1, nota2, media;

  // primeira nota
  printf("Digite a primeira nota: ");
  scanf("%f", &nota1);

  // segunda nota
  printf("Digite a segunda nota: ");
  scanf("%f", &nota2);

  // calcular média
  media = (nota1 + nota2) / 2;

  // mostrar o resultado | aprovado ou reprovado
  if (media >= 7) {
    printf("Aprovado \n");
  } else {
    printf("Reprovado \n");
  }
}
