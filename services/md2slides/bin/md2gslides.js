const fs = require('fs');
const path = require('path');
const { google } = require('googleapis');
const { JWT } = require('google-auth-library');

// Récupérer les arguments de la ligne de commande
const markdown = process.argv[2] || '# Titre\n\n## Slide 1';
const title = process.argv[3] || 'Nouvelle présentation';

function authorizeServiceAccount() {
  const credentialsPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;

  if (!credentialsPath || !fs.existsSync(credentialsPath)) {
    console.error(`❌ Variable GOOGLE_APPLICATION_CREDENTIALS non définie ou fichier introuvable : ${credentialsPath}`);
    process.exit(1);
  }

  const creds = JSON.parse(fs.readFileSync(credentialsPath, 'utf8'));

  return new JWT({
    email: creds.client_email,
    key: creds.private_key,
    scopes: ['https://www.googleapis.com/auth/presentations'],
  });
}

async function createPresentation(markdown, title) {
  const auth = authorizeServiceAccount();
  const slides = google.slides({ version: 'v1', auth });

  const presentation = await slides.presentations.create({
    requestBody: {
      title,
    },
  });

  const id = presentation.data.presentationId;
  console.log(`✅ Présentation créée : https://docs.google.com/presentation/d/${id}`);
}

createPresentation(markdown, title).catch((err) => {
  console.error('❌ Erreur :', err.message);
  process.exit(1);
});
