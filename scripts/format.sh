#!/bin/bash

# Dart Code Formatter Script
# This script ensures consistent code formatting across all environments
# Usage: ./scripts/format.sh [options]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
CHECK_ONLY=false
PAGE_WIDTH=80
SHOW_HELP=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --check)
      CHECK_ONLY=true
      shift
      ;;
    --page-width)
      PAGE_WIDTH="$2"
      shift 2
      ;;
    --help|-h)
      SHOW_HELP=true
      shift
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      exit 1
      ;;
  esac
done

# Show help
if [ "$SHOW_HELP" = true ]; then
  echo -e "${BLUE}Dart Code Formatter Script${NC}"
  echo ""
  echo "Usage: ./scripts/format.sh [options]"
  echo ""
  echo "Options:"
  echo "  --check           Check formatting without making changes (CI mode)"
  echo "  --page-width N    Set line length to N characters (default: 80)"
  echo "  --help, -h        Show this help message"
  echo ""
  echo "Examples:"
  echo "  ./scripts/format.sh                    # Format all files with 80-char width"
  echo "  ./scripts/format.sh --check            # Check formatting for CI"
  echo "  ./scripts/format.sh --page-width 120   # Format with 120-char width"
  exit 0
fi

echo -e "${BLUE}🎨 Running Dart Code Formatter${NC}"
echo -e "${YELLOW}Page width: ${PAGE_WIDTH} characters${NC}"

# Check if dart is available
if ! command -v dart &> /dev/null; then
  echo -e "${RED}❌ Dart is not installed or not in PATH${NC}"
  exit 1
fi

# Check if we're in a Flutter project
if [ ! -f "pubspec.yaml" ]; then
  echo -e "${RED}❌ No pubspec.yaml found. Are you in a Flutter/Dart project root?${NC}"
  exit 1
fi

# Run formatter
if [ "$CHECK_ONLY" = true ]; then
  echo -e "${YELLOW}🔍 Checking code formatting...${NC}"
  if dart format --page-width="$PAGE_WIDTH" --output=none --set-exit-if-changed .; then
    echo -e "${GREEN}✅ All files are properly formatted${NC}"
  else
    echo -e "${RED}❌ Some files need formatting. Run without --check to fix them.${NC}"
    exit 1
  fi
else
  echo -e "${YELLOW}🔧 Formatting code files...${NC}"
  dart format --page-width="$PAGE_WIDTH" .
  echo -e "${GREEN}✅ Code formatting completed${NC}"
fi

echo -e "${BLUE}📊 Formatting summary completed${NC}"
