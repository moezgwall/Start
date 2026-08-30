#!/usr/bin/env bash
# Usage:
#   ./create-express-project.sh <project-name> [--ts|--js]
#   ./create-express-project.sh                    # current dir
#   ./create-express-project.sh my-app           # JS (default)
#   ./create-express-project.sh my-app --ts       # TypeScript



set -euo pipefail

PROJECT_NAME=""
LANG="js"

for arg in "$@"; do
  case "$arg" in
    --ts) LANG="ts" ;;
    --js) LANG="js" ;;
    *) PROJECT_NAME="$arg" ;;
  esac
done

if [ -n "$PROJECT_NAME" ]; then
  if [ -d "$PROJECT_NAME" ]; then
    echo "Error: directory '$PROJECT_NAME' already exists." >&2
    exit 1
  fi
  mkdir -p "$PROJECT_NAME"
  cd "$PROJECT_NAME"
  echo "Creating Express ($LANG) project structure in ./$PROJECT_NAME ..."
else
  echo "Creating Express ($LANG) project structure in current directory ..."
fi

EXT="js"
[ "$LANG" = "ts" ] && EXT="ts"

# --- Source folders -----------------------------------------------------
mkdir -p src/config
mkdir -p src/controllers
mkdir -p src/routes
mkdir -p src/services
mkdir -p src/models
mkdir -p src/middlewares
mkdir -p src/repositories
mkdir -p src/utils
mkdir -p src/validators
[ "$LANG" = "ts" ] && mkdir -p src/types

# --- Tests -----------------------------------------------------------------
mkdir -p tests/unit
mkdir -p tests/integration

# --- Misc top-level ----------------------------------------------------------
mkdir -p public
mkdir -p logs

# --- Placeholder files so empty dirs survive git -----------------------------
touch src/config/.gitkeep
touch src/controllers/.gitkeep
touch src/routes/.gitkeep
touch src/services/.gitkeep
touch src/models/.gitkeep
touch src/middlewares/.gitkeep
touch src/repositories/.gitkeep
touch src/utils/.gitkeep
touch src/validators/.gitkeep
[ "$LANG" = "ts" ] && touch src/types/.gitkeep
touch tests/unit/.gitkeep
touch tests/integration/.gitkeep
touch public/.gitkeep
touch logs/.gitkeep

# --- Root files ---------------------------------------------------------------
touch .env
touch .env.example
touch .gitignore
touch README.md

cat > .gitignore <<EOF
node_modules/
.env
logs/
*.log
EOF

if [ "$LANG" = "ts" ]; then
  cat >> .gitignore <<'EOF'
dist/
EOF
fi

# --- package.json ---
if [ "$LANG" = "ts" ]; then
  cat > package.json <<EOF
{
  "name": "${PROJECT_NAME:-express-app}",
  "version": "1.0.0",
  "description": "",
  "main": "dist/server.js",
  "scripts": {
    "dev": "nodemon --exec ts-node src/server.ts",
    "build": "tsc",
    "start": "node dist/server.js",
    "test": "jest"
  },
  "license": "ISC",
  "dependencies": {
    "express": "^4.19.2",
    "dotenv": "^16.4.5"
  },
  "devDependencies": {
    "typescript": "^5.5.4",
    "ts-node": "^10.9.2",
    "nodemon": "^3.1.4",
    "@types/express": "^4.17.21",
    "@types/node": "^20.14.15",
    "jest": "^29.7.0",
    "@types/jest": "^29.5.12",
    "ts-jest": "^29.2.4"
  }
}
EOF
else
  cat > package.json <<EOF
{
  "name": "${PROJECT_NAME:-express-app}",
  "version": "1.0.0",
  "description": "",
  "main": "src/server.js",
  "scripts": {
    "dev": "nodemon src/server.js",
    "start": "node src/server.js",
    "test": "jest"
  },
  "license": "ISC",
  "dependencies": {
    "express": "^4.19.2",
    "dotenv": "^16.4.5"
  },
  "devDependencies": {
    "nodemon": "^3.1.4"
  }
}
EOF
fi

# --- tsconfig.json (TS only) ---
if [ "$LANG" = "ts" ]; then
  cat > tsconfig.json <<'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true
  },
  "include": ["src/**/*.ts"],
  "exclude": ["node_modules", "dist", "tests"]
}
EOF
fi

# --- src/app.(js|ts) ---
if [ "$LANG" = "ts" ]; then
  cat > "src/app.ts" <<'EOF'
import express, { Application, Request, Response } from 'express';

const app: Application = express();

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.get('/', (req: Request, res: Response) => {
  res.send('OK');
});

export default app;
EOF
else
  cat > "src/app.js" <<'EOF'
const express = require('express');

const app = express();

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.get('/', (req, res) => {
  res.send('OK');
});

module.exports = app;
EOF
fi

# --- src/server.(js|ts) ---
if [ "$LANG" = "ts" ]; then
  cat > "src/server.ts" <<'EOF'
import app from './app';

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
EOF
else
  cat > "src/server.js" <<'EOF'
require('dotenv').config();
const app = require('./app');

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
EOF
fi

echo ""
echo "Done. Structure created:"
find . -not -path '*/node_modules*' -not -path './.git*' | sort

echo ""
echo "Next steps:"
[ -n "$PROJECT_NAME" ] && echo "  cd $PROJECT_NAME"
echo "  npm install"
echo "  npm run dev"