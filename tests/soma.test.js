const { expect } = require('chai');
const { somarNumeros, validarTitulo } = require('../lib/math');

describe('MobEAD - Testes automatizados', () => {
  describe('Somas', () => {
    it('soma de dois números - 2 e 3', () => {
      const resultado = somarNumeros(2, 3);
      expect(resultado).to.equal(5);
    });

    it('soma de números negativos - (-1) e 1', () => {
      const resultado = somarNumeros(-1, 1);
      expect(resultado).to.equal(0);
    });

    it('soma de decimais - 1.5 e 2.5', () => {
      const resultado = somarNumeros(1.5, 2.5);
      expect(resultado).to.equal(4);
    });
  });

  describe('Validação', () => {
    it('valida título não vazio', () => {
      expect(validarTitulo('MobEAD')).to.be.true;
    });

    it('rejeita título vazio', () => {
      expect(validarTitulo('')).to.be.false;
    });
  });
});
