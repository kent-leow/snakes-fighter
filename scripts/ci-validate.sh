#!/bin/bash

# CI/CD Validation Script
# This script runs the same checks as CI/CD to validate local changes
# Usage: ./scripts/ci-validate.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Running CI/CD Validation Checks${NC}"

# Check if we're in project root
if [ ! -f "pubspec.yaml" ]; then
  echo -e "${RED}❌ No pubspec.yaml found. Run this from project root.${NC}"
  exit 1
fi

echo -e "${YELLOW}📦 Getting dependencies...${NC}"
flutter pub get

echo -e "${YELLOW}🎨 Checking code formatting...${NC}"
if dart format --page-width=80 --output=none --set-exit-if-changed .; then
  echo -e "${GREEN}✅ Code formatting is correct${NC}"
else
  echo -e "${RED}❌ Code formatting check failed${NC}"
  echo -e "${YELLOW}💡 Run './scripts/format.sh' to fix formatting${NC}"
  exit 1
fi

echo -e "${YELLOW}🔍 Analyzing code...${NC}"
if flutter analyze --fatal-infos; then
  echo -e "${GREEN}✅ Code analysis passed${NC}"
else
  echo -e "${RED}❌ Code analysis failed${NC}"
  exit 1
fi

echo -e "${YELLOW}📋 Checking import sorting...${NC}"
if dart run import_sorter:main --no-comments --exit-if-changed; then
  echo -e "${GREEN}✅ Import sorting is correct${NC}"
else
  echo -e "${RED}❌ Import sorting check failed${NC}"
  echo -e "${YELLOW}💡 Run 'dart run import_sorter:main --no-comments' to fix imports${NC}"
  exit 1
fi

echo -e "${YELLOW}🧪 Running tests...${NC}"
if flutter test --exclude-tags firebase --reporter=github; then
  echo -e "${GREEN}✅ All tests passed${NC}"
else
  echo -e "${RED}❌ Some tests failed${NC}"
  exit 1
fi

echo -e "${GREEN}🎉 All CI/CD validation checks passed!${NC}"
echo -e "${BLUE}📋 Your code is ready for CI/CD pipeline${NC}"
