const admin = require('firebase-admin');
const serviceAccount = require('./service-account-key.json'); // Chave de segurança que vamos gerar
const vortexContent = require('./vortex-content.json');

// Inicializa o app Firebase com as credenciais de administrador
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function importContent() {
  console.log('Iniciando a importação de conteúdo para o Firestore...');

  for (const day of vortexContent) {
    try {
      const docRef = db.collection('modules').doc(day.id);
      await docRef.set(day);
      console.log(`[SUCESSO] Documento ${day.id} importado.`);
    } catch (error) {
      console.error(`[ERRO] Falha ao importar ${day.id}:`, error);
    }
  }

  console.log('Importação de conteúdo concluída.');
}

importContent();