const auth0 = require('auth0-deploy-cli');

const config = {
  AUTH0_DOMAIN: process.env.AUTH0_DOMAIN,
  AUTH0_CLIENT_SECRET: process.env.AUTH0_CLIENT_SECRET,
  AUTH0_CLIENT_ID: process.env.AUTH0_CLIENT_ID,
  AUTH0_EXPORT_IDENTIFIERS: false,
  AUTH0_ALLOW_DELETE: false,
  AUTH0_API_MAX_RETRIES: 10
};

// Export Tenant Config
auth0.dump({
  output_folder: './auth0-app-demo-dev', // Output directory
  config: config, // Option to sent in json as object
})
  .then(() => console.log('yey export was successful'))
  .catch(err => console.log(`Oh no, something went wrong. Error: ${err}`));

// Import tenant config
auth0.deploy({
  input_file: './auth0-app-demo-dev', // Input file for directory, change to .yaml for YAML
  config: config
})
  .then(() => console.log('yey deploy was successful'))
  .catch(err => console.log(`Oh no, something went wrong. Error: ${err}`));