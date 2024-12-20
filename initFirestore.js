const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');
const fs = require('fs');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Read the initial data structure
const initialData = JSON.parse(fs.readFileSync('./firestore_initial_data.json', 'utf8'));

async function createCollectionTemplate(collectionName, template) {
  try {
    // Create a template document with schema
    const templateDoc = template['schema'];
    if (templateDoc) {
      console.log(`Creating template for collection: ${collectionName}`);
      await db.collection(collectionName).doc('schema_template').set(templateDoc);
      console.log(`✓ Template created for ${collectionName}`);
    }
  } catch (error) {
    console.error(`Error creating template for ${collectionName}:`, error);
  }
}

async function initializeFirestore() {
  try {
    console.log('Starting Firestore initialization...');

    // Create templates for each collection
    const collections = Object.keys(initialData);
    for (const collection of collections) {
      await createCollectionTemplate(collection, initialData[collection]);
    }

    console.log('✓ Firestore initialization completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('Error initializing Firestore:', error);
    process.exit(1);
  }
}

// Run the initialization
initializeFirestore(); 