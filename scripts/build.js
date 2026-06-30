const fs = require('fs');
const path = require('path');

const distDir = path.join(__dirname, '..', 'dist');
const arquivos = [
  'index.html',
  'kickstrap.css',
  'mine.css',
  'Scripts',
  'Kickstrap'
];

console.log('>>> Iniciando build da aplicação MobEAD...');

if (fs.existsSync(distDir)) {
  fs.rmSync(distDir, { recursive: true, force: true });
}
fs.mkdirSync(distDir, { recursive: true });

arquivos.forEach((item) => {
  const origem = path.join(__dirname, '..', item);
  const destino = path.join(distDir, item);

  if (!fs.existsSync(origem)) {
    console.warn(`Aviso: ${item} não encontrado, pulando...`);
    return;
  }

  const stat = fs.statSync(origem);
  if (stat.isDirectory()) {
    fs.cpSync(origem, destino, { recursive: true });
  } else {
    fs.copyFileSync(origem, destino);
  }
  console.log(`  Copiado: ${item}`);
});

console.log('>>> Build concluído com sucesso! Artefatos em ./dist');
