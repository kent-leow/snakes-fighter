#!/bin/bash

# Production Security Validation Script
# Validates production environment security configuration

set -e

echo "🔒 Starting Production Security Validation"

# Configuration
PROJECT_ID="snakes-fight-prod"
RULES_FILE="database.rules.prod.json"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

VALIDATION_ERRORS=0

# Function to increment error counter
record_error() {
    VALIDATION_ERRORS=$((VALIDATION_ERRORS + 1))
    print_error "$1"
}

# Check if required tools are available
check_prerequisites() {
    echo "📋 Checking prerequisites..."
    
    if ! command -v firebase &> /dev/null; then
        record_error "Firebase CLI not found"
        return 1
    fi
    
    if ! command -v jq &> /dev/null; then
        print_warning "jq not found - some validations will be skipped"
    fi
    
    print_status "Prerequisites check completed"
}

# Validate security rules file
validate_security_rules() {
    echo "🛡️  Validating security rules..."
    
    if [ ! -f "$RULES_FILE" ]; then
        record_error "Security rules file $RULES_FILE not found"
        return 1
    fi
    
    # Check JSON syntax
    if ! jq empty "$RULES_FILE" 2>/dev/null; then
        record_error "Security rules JSON syntax is invalid"
        return 1
    fi
    
    # Check for required authentication
    if ! grep -q '"auth != null"' "$RULES_FILE"; then
        record_error "Security rules missing authentication requirements"
    else
        print_status "Authentication requirements found in rules"
    fi
    
    # Check for rate limiting
    if ! grep -q "rateLimiting" "$RULES_FILE"; then
        print_warning "Rate limiting not found in security rules"
    else
        print_status "Rate limiting configuration found"
    fi
    
    # Validate specific security patterns
    if grep -q '"\.read": "true"' "$RULES_FILE" || grep -q '"\.write": "true"' "$RULES_FILE"; then
        record_error "Found overly permissive rules (read/write: true)"
    else
        print_status "No overly permissive rules found"
    fi
    
    print_status "Security rules validation completed"
}

# Validate Firebase project configuration
validate_firebase_config() {
    echo "🔧 Validating Firebase configuration..."
    
    # Check if project exists and is accessible
    if ! firebase projects:list 2>/dev/null | grep -q "$PROJECT_ID"; then
        record_error "Production project $PROJECT_ID not accessible"
        return 1
    fi
    
    # Switch to production project
    firebase use "$PROJECT_ID" --config firebase.prod.json 2>/dev/null || {
        record_error "Cannot switch to production project"
        return 1
    }
    
    print_status "Firebase project configuration validated"
}

# Test security rules deployment
test_rules_deployment() {
    echo "🚀 Testing security rules deployment..."
    
    # Validate rules syntax with Firebase
    if ! firebase database:rules:validate --config firebase.prod.json 2>/dev/null; then
        record_error "Security rules failed Firebase validation"
        return 1
    fi
    
    print_status "Security rules passed Firebase validation"
}

# Check production functions security
validate_functions_security() {
    echo "⚡ Validating Functions security..."
    
    FUNCTIONS_DIR="functions/src"
    
    if [ ! -d "$FUNCTIONS_DIR" ]; then
        record_error "Functions directory not found"
        return 1
    fi
    
    # Check for admin verification in sensitive functions
    if ! grep -r "context.auth?.token.admin" "$FUNCTIONS_DIR" >/dev/null; then
        print_warning "Admin verification not found in functions"
    else
        print_status "Admin verification found in functions"
    fi
    
    # Check for proper error handling
    if ! grep -r "functions.https.HttpsError" "$FUNCTIONS_DIR" >/dev/null; then
        print_warning "Proper error handling not found in functions"
    else
        print_status "Proper error handling found in functions"
    fi
    
    # Check for input validation
    if ! grep -r "\.validate" "$FUNCTIONS_DIR" >/dev/null; then
        print_warning "Input validation patterns not found in functions"
    else
        print_status "Input validation patterns found"
    fi
    
    print_status "Functions security validation completed"
}

# Check hosting security configuration
validate_hosting_security() {
    echo "🌐 Validating hosting security..."
    
    FIREBASE_JSON="firebase.prod.json"
    
    if [ ! -f "$FIREBASE_JSON" ]; then
        record_error "Production Firebase configuration not found"
        return 1
    fi
    
    # Check for security headers
    if ! grep -q "X-Content-Type-Options" "$FIREBASE_JSON"; then
        record_error "Missing X-Content-Type-Options header"
    else
        print_status "X-Content-Type-Options header configured"
    fi
    
    if ! grep -q "X-Frame-Options" "$FIREBASE_JSON"; then
        record_error "Missing X-Frame-Options header"
    else
        print_status "X-Frame-Options header configured"
    fi
    
    if ! grep -q "Strict-Transport-Security" "$FIREBASE_JSON"; then
        record_error "Missing HSTS header"
    else
        print_status "HSTS header configured"
    fi
    
    if ! grep -q "Content-Security-Policy" "$FIREBASE_JSON"; then
        record_error "Missing Content Security Policy"
    else
        print_status "Content Security Policy configured"
    fi
    
    print_status "Hosting security validation completed"
}

# Test backup system security
validate_backup_security() {
    echo "💾 Validating backup system security..."
    
    BACKUP_DIR="functions/src/backup"
    
    if [ ! -d "$BACKUP_DIR" ]; then
        record_error "Backup system not found"
        return 1
    fi
    
    # Check for admin-only backup functions
    if ! grep -q "context.auth?.token.admin" "$BACKUP_DIR"/*.ts; then
        record_error "Backup functions missing admin verification"
    else
        print_status "Backup functions have admin verification"
    fi
    
    # Check for checksum validation
    if ! grep -q "checksum" "$BACKUP_DIR"/*.ts; then
        print_warning "Checksum validation not found in backup system"
    else
        print_status "Checksum validation found in backup system"
    fi
    
    print_status "Backup security validation completed"
}

# Check monitoring system security
validate_monitoring_security() {
    echo "📊 Validating monitoring system security..."
    
    MONITORING_DIR="functions/src/monitoring"
    
    if [ ! -d "$MONITORING_DIR" ]; then
        record_error "Monitoring system not found"
        return 1
    fi
    
    # Check for proper alert handling
    if ! grep -q "severity.*critical" "$MONITORING_DIR"/*.ts; then
        print_warning "Critical alert handling not found"
    else
        print_status "Critical alert handling configured"
    fi
    
    # Check for secure logging
    if grep -q "console.log.*password\|console.log.*token" "$MONITORING_DIR"/*.ts; then
        record_error "Potential sensitive data logging found"
    else
        print_status "No sensitive data logging detected"
    fi
    
    print_status "Monitoring security validation completed"
}

# Generate security report
generate_security_report() {
    echo ""
    echo "📋 SECURITY VALIDATION REPORT"
    echo "=============================="
    echo "Project: $PROJECT_ID"
    echo "Timestamp: $(date)"
    echo "Validation Errors: $VALIDATION_ERRORS"
    echo ""
    
    if [ $VALIDATION_ERRORS -eq 0 ]; then
        print_status "🎉 All security validations PASSED"
        echo "The production environment meets security requirements."
        return 0
    else
        print_error "❌ Security validation FAILED with $VALIDATION_ERRORS errors"
        echo "Please address the errors above before deploying to production."
        return 1
    fi
}

# Main execution
main() {
    check_prerequisites
    validate_security_rules
    validate_firebase_config
    test_rules_deployment
    validate_functions_security
    validate_hosting_security
    validate_backup_security
    validate_monitoring_security
    
    generate_security_report
}

# Run main function
main "$@"
