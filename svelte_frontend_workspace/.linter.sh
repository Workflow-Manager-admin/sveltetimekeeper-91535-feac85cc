#!/bin/bash
cd /home/kavia/workspace/code-generation/sveltetimekeeper-91535-feac85cc/svelte_frontend_workspace/svelte_frontend
npm run lint
ESLINT_EXIT_CODE=$?
npm run build
BUILD_EXIT_CODE=$?
if [ $ESLINT_EXIT_CODE -ne 0 ] || [ $BUILD_EXIT_CODE -ne 0 ]; then
   exit 1
fi

