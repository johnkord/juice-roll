import { copyFile } from 'node:fs/promises';

await copyFile('staticwebapp.config.json', 'build/web/staticwebapp.config.json');
console.log('Staged staticwebapp.config.json in build/web.');