const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Initialize Firebase Admin
const serviceAccount = require('../serviceAccountKey.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Read the demo data
const demoData = JSON.parse(fs.readFileSync(path.join(__dirname, 'demo_data.json'), 'utf8'));

async function uploadCollection(collectionName, data) {
  console.log(`Uploading ${collectionName}...`);
  const batch = db.batch();
  
  for (const [docId, docData] of Object.entries(data)) {
    const docRef = db.collection(collectionName).doc(docId);
    batch.set(docRef, docData);
  }
  
  await batch.commit();
  console.log(`✓ ${collectionName} uploaded successfully`);
}

async function loadDemoData() {
  try {
    console.log('Starting demo data upload...');

    // Upload each collection
    for (const [collectionName, collectionData] of Object.entries(demoData)) {
      if (collectionName === 'social') {
        // Handle nested collections in social
        for (const [subCollectionName, subCollectionData] of Object.entries(collectionData)) {
          await uploadCollection(`social_${subCollectionName}`, subCollectionData);
        }
      } else {
        await uploadCollection(collectionName, collectionData);
      }
    }

    console.log('✓ Demo data upload completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('Error uploading demo data:', error);
    process.exit(1);
  }
}

// Run the upload
loadDemoData(); 