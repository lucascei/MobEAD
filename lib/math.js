/**
 * Funções utilitárias da aplicação MobEAD
 */

function somarNumeros(a, b) {
  if (typeof a !== 'number' || typeof b !== 'number') {
    throw new TypeError('Os argumentos devem ser números');
  }
  return a + b;
}

function validarTitulo(titulo) {
  return typeof titulo === 'string' && titulo.length > 0;
}

module.exports = {
  somarNumeros,
  validarTitulo
};
