#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
xcrun swiftc -parse-as-library -module-cache-path "$test_dir/cache" \
  AutoCare/Domain/Entities/SwiftData/Protocols/Syncable.swift \
  AutoCare/Domain/Entities/SwiftData/OdometerReminder.swift \
  Tools/Tests/OdometerReminderTests.swift -o "$test_dir/reminder-tests"
"$test_dir/reminder-tests"
